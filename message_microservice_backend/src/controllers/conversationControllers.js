const conversationService = require('../services/conversationServices');

// POST /conversations - create or get conversation
exports.createOrFindConversation = async (req, res) => {
  try {
    const { participantIds } = req.body;
    if (!participantIds || participantIds.length !== 2) {
      return res.status(400).json({ error: 'Need exactly 2 participants' });
    }
    const conversation = await conversationService.findOrCreateConversation(participantIds[0], participantIds[1]);
    res.json(conversation);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// GET /conversations/:userId - get chat list for user
exports.getChatListForUser = async (req, res) => {
  try {
    const userId = req.params.userId;
    const chats = await conversationService.getChatListForUser(userId);
    res.json(chats);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// POST /conversations/:conversationId/message - add/update message (calls updateConversationAfterMessage)
exports.updateConversationAfterMessage = async (req, res) => {
  try {
    const conversationId = req.params.conversationId;
    const message = req.body; // expects { content, senderId, type? }
    await conversationService.updateConversationAfterMessage(conversationId, message);
    res.json({ success: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};
