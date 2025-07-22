import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:major/screens/Message/chat_screen.dart';
import 'package:major/screens/Message/socket_service.dart';
import 'package:major/screens/Message/chat_controller.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    ref.read(chatProvider.notifier).initSocketListener();
  }

  final List<Map<String, String>> messages = List.generate(10, (index) {
    return {
      "name": "Ronald Richards",
      "message": "So, what's your plan this weekend?",
      "time": "15:41",
      "avatarUrl": "https://randomuser.me/api/portraits/men/75.jpg",
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final chat = messages[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chat["avatarUrl"]!),
              radius: 24,
            ),
            title: Text(
              chat["name"]!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(chat["message"]!),
            trailing: Text(
              chat["time"]!,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(chatName: chat["name"]!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class ChatDetailScreen extends StatelessWidget {
  final String chatName;

  ChatDetailScreen({required this.chatName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chatName)),
      body: Center(child: Text("Conversation with $chatName")),
    );
  }
}
