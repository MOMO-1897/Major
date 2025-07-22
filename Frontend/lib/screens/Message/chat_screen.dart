import 'package:flutter/material.dart';
import 'message.dart';
import 'message_bubble.dart';
import 'chat_input_field.dart';
import 'socket_service.dart';
import 'chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatProvider = StateNotifierProvider<ChatController, List<Message>>((ref) {
  return ChatController(ref);
});

class ChatScreen extends ConsumerWidget {
  final String currentUserId = 'user123';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {},
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage('assets/profile.jpeg')),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Shanks', style: TextStyle(fontSize: 16)),
              Text('Active 11m ago', style: TextStyle(fontSize: 12)),
            ])
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam))
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.senderId == currentUserId;
                return MessageBubble(message: msg, isMe: isMe);
              },
            ),
          ),
          ChatInputField(onSend: ({String? text, String? imageUrl}) {
            ref.read(chatProvider.notifier).sendMessage(text, imageUrl);
          }),
        ],
      ),
    );
  }
}
