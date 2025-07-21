const messageService = require('../services/messageServices');

exports.getMessagesByConversationId = async (req, res) => {
  try {
    const conversationId = req.params.conversationId;

    console.log(conversationId);

    if (!conversationId) {
      return res.status(400).json({ error: 'conversationId is required' });
    }

    const messages = await messageService.getMessagesByConversationId(conversationId.toString());

    console.log("Messages found:", messages);
    res.status(200).json(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: error.message });
  }
};
