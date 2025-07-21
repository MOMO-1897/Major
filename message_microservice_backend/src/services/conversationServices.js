const Conversation = require('../models/conversation');
const axios = require('axios');

async function getUserInfo(userId) {
  console.log(userId);
  try {
    const res = await axios.get(`http://127.0.0.1:3000/users/${userId}`);
    return res.data;
  } catch (err) {
    console.error('Failed to fetch user info', err);
    return null; // or fallback
  }
}

async function findOrCreateConversation(senderId, receiverId) {
  try {
    let conversation = await Conversation.findOne({
      participants: { $all: [senderId, receiverId] },
    });

    if (!conversation) {
      conversation = new Conversation({
        participants: [senderId, receiverId],
        lastMessage: null,
        unreadCounts: {},
      });
      await conversation.save();
    }

    return conversation;
  } catch (error) {
    console.error('Error in findOrCreateConversation:', error);
    throw error; // rethrow so caller knows something went wrong
  }
}


async function updateConversationAfterMessage(conversationId, message) {
  try {
    const { content, senderId, type } = message;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) throw new Error('Conversation not found');

    conversation.lastMessage = {
      content,
      timestamp: new Date(),
      senderId,
      type: type || 'TEXT',
    };

    conversation.participants.forEach((participantId) => {
      if (participantId.toString() !== senderId.toString()) {
        const currentUnread = conversation.unreadCounts.get(participantId.toString()) || 0;
        conversation.unreadCounts.set(participantId.toString(), currentUnread + 1);
      }
    });

    await conversation.save();
  } catch (error) {
    console.error('Error in updateConversationAfterMessage:', error);
    throw error; // so the caller can handle it as needed
  }
}

async function getChatListForUser(userId) {
  // Find conversations with the user
  const conversations = await Conversation.find({
    participants: userId,
  })
    .sort({ updatedAt: -1 })
    .lean();

  const results = await Promise.all(
    conversations.map(async (conv) => {
      const otherParticipantId = conv.participants.find(
        (p) => p.toString() !== userId.toString()
      );

      const otherUser = await getUserInfo(otherParticipantId.toString());

      return {
        conversationId: conv._id,
        lastMessage: conv.lastMessage,
        unreadCount: conv.unreadCounts[userId.toString()] || 0,
        participant: otherUser,
        updatedAt: conv.updatedAt,
      };
    })
  );

  return results;
}

module.exports = { findOrCreateConversation, updateConversationAfterMessage, getChatListForUser };
