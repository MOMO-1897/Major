const express = require('express');
const router = express.Router();
const conversationController = require('../controllers/conversationControllers');
const messageController = require('../controllers/messageControllers');

router.post('/', conversationController.createOrFindConversation);           // create/find conversation
router.get('/:userId', conversationController.getChatListForUser);            // get chat list
//router.post('/:conversationId/message', conversationController.updateConversationAfterMessage); // add message/update last message
router.get('/messages/:conversationId', messageController.getMessagesByConversationId);

module.exports = router;

