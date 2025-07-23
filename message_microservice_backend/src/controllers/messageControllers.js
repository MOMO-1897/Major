const messageService = require('../services/messageServices');

exports.getMessagesByConversationId = async (req, res) => {
  try {

    console.log("User ID:", req.headers['user-id']);
    const conversationId = req.params.conversationId;

    console.log("=== ALL INCOMING HEADERS ===");
    console.log(JSON.stringify(req.headers, null, 2));
    console.log("=============================");

    const userId = req.headers['user-id'];


    console.log("User ID:", userId);
    console.log("Conversation ID:", conversationId);

    if (!conversationId) {
      return res.status(400).json({ error: 'conversationId is required' });
    }

    const messages = await messageService.getMessagesByConversationId(conversationId.toString(), userId.toString());

    console.log("Messages found:", messages);
    res.status(200).json(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: error.message });
  }
};

exports.getLatestMessage = async (req, res) => {
  try {
    const userId = req.headers['user-id'];
    console.log(userId);
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const messages = await messageService.getLatestMessageById(userId.toString());
    console.log("Messages found:", messages);
    res.status(200).json(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: error.message });
  }
}
