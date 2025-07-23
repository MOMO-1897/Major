const Message = require('../models/message');
const mongoose = require('mongoose');
const Conversation = require('../models/conversation');

async function saveMessage(data) {
  try {
    if (data._id) delete data._id;

    if (!data.conversationId) throw new Error("conversationId is required");
    if (!data.senderId) throw new Error("senderId is required");
    if (!data.receiverId) throw new Error("receiverId is required");

    if (data.type === 'TEXT' && !data.content) {
      throw new Error("Content is required for text messages");
    }
    if (data.type === 'IMAGE' && !data.mediaUrl) {
      throw new Error("mediaUrl is required for image messages");
    }

    const newMessage = new Message({
      conversationId: data.conversationId,
      senderId: data.senderId,
      receiverId: data.receiverId,
      type: data.type || 'TEXT',
      content: data.content,
      mediaUrl: data.mediaUrl,
      read: data.read || false,
    });

    const savedMessage = await newMessage.save();
    return savedMessage;
  } catch (error) {
    console.error("Error saving message:", error);
    throw error;
  }
}

async function getMessagesByConversationId(conversationId, userId) {
  if (!conversationId) throw new Error("conversationId is required");

  try {
    if (userId) {
      await Message.updateMany(
        {
          conversationId: new mongoose.Types.ObjectId(conversationId),
          receiverId: new mongoose.Types.ObjectId(userId),
          read: false
        },
        {
          $set: { read: true }
        }
      );
    }

    const messages = await Message.find({
      conversationId: new mongoose.Types.ObjectId(conversationId)
    }).sort({ createdAt: 1 });
    return messages;
  } catch (error) {
    console.error("Error fetching messages:", error);
    throw error;
  }
}

async function getLatestMessageById(userId) {
  if (!userId) throw new Error("userId is required");

  try {
    const conversations = await Conversation.find({
      participants: new mongoose.Types.ObjectId(userId)
    }).select('_id');

    if (conversations.length === 0) {
      return [];
    }

    const conversationIds = conversations.map(conv => conv._id);

    const latestMessages = await Message.aggregate([
      {
        $match: {
          conversationId: { $in: conversationIds }
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $group: {
          _id: "$conversationId",
          latestMessage: { $first: "$$ROOT" }
        }
      },
      {
        $replaceRoot: { newRoot: "$latestMessage" }
      },
      {
        $sort: { createdAt: -1 }
      }
    ]);
    return latestMessages;
  } catch (error) {
    console.error("Error fetching messages:", error);
    throw error;
  }
}

module.exports = {
  saveMessage,
  getMessagesByConversationId,
  getLatestMessageById,
};

