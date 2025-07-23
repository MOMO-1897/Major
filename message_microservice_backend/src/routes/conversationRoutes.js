const express = require('express');
const router = express.Router();
const conversationController = require('../controllers/conversationControllers');
const messageController = require('../controllers/messageControllers');

router.post('/', conversationController.createOrFindConversation);
router.get('/:userId', conversationController.getChatListForUser);
//router.post('/:conversationId/message', conversationController.updateConversationAfterMessage);
router.get('/messages/:conversationId', messageController.getMessagesByConversationId);
router.get('/latest/messages', messageController.getLatestMessage);

module.exports = router;

