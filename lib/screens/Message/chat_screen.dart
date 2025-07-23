import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:major/services/storage_service.dart';
import 'message.dart';
import 'message_bubble.dart';
import 'chat_input_field.dart';
import 'socket_service.dart';
import 'chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:major/screens/Maps/SpecialistsData.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:major/utils/constants.dart';

final chatProvider = StateNotifierProvider<ChatController, List<Message>>((
  ref,
) {
  return ChatController(ref);
});

class ChatScreen extends ConsumerStatefulWidget {
  final String specialistId;
  final String profilePictureUrl;
  final String fullName;
  final String phoneNumber;

  ChatScreen({
    Key? key,
    required this.specialistId,
    required this.profilePictureUrl,
    required this.fullName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? currentUserId;
  String? conversationId;

  @override
  void initState() {
    super.initState();
    printToken();
  }

  Future<void> printToken() async {
    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUserId = payload['sub'];
        print(currentUserId);
        print(widget.specialistId);

        await createOrFindConversation(currentUserId!, widget.specialistId);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }
  }

  Future<void> createOrFindConversation(
    String senderId,
    String receiverId,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.socketUrl}${ApiConstants.Conversation}',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'participantIds': [senderId, receiverId],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        conversationId = data['_id'];
      });
      ref.read(chatProvider.notifier).setConversationId(conversationId!);
      print("Conversation data: $data");
    } else {
      print(
        "Failed to create/find conversation: ${response.statusCode}, ${response.body}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    final filteredMessages = messages
        .where((msg) => msg.conversationId == conversationId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
            CircleAvatar(backgroundImage: NetworkImage(ApiConstants.baseUrl+widget.profilePictureUrl)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.fullName}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              printToken();
            },
            icon: Icon(Icons.call),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam)),
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
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final msg =
                    filteredMessages[filteredMessages.length - 1 - index];
                final isMe = msg.senderId.trim() == currentUserId?.trim();
                return MessageBubble(message: msg, isMe: isMe);
              },
            ),
          ),
          ChatInputField(
            onSend: ({String? text, String? imageUrl}) {
              ref
                  .read(chatProvider.notifier)
                  .sendMessage(
                    conversationId!,
                    currentUserId!,
                    widget.specialistId,
                    text,
                    imageUrl,
                  );
            },
          ),
        ],
      ),
    );
  }
}
