import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:major/screens/Message/chat_screen.dart';
import 'package:major/screens/Message/socket_service.dart';
import 'package:major/screens/Message/chat_controller.dart';
import 'package:major/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/utils/constants.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? role;
  final VoidCallback? specialistMap;

  const ChatListScreen({Key? key, this.specialistMap, this.role}) : super(key: key);

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final SocketService _socketService = SocketService();
  String? currentUserId;

  String formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatList();
    ref.read(chatProvider.notifier).initSocketListener();
  }

  final List<Map<String, dynamic>> messages = [];

  Future<void> fetchChatList() async {
    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUserId= payload['sub'];
        print(currentUserId);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }
    final response = await http.get(
        Uri.parse('${ApiConstants.socketUrl}${ApiConstants.Conversation}$currentUserId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        messages.clear();
        messages.addAll(data.map((item) {
          final participant = item['participant'];
          final user = participant['user'];

          return {
            "name": user['fullName'],
            "avatarUrl": user['profilePictureUrl'],
            "message": item['lastMessage']?['content'] ?? '',
            "time": formatDate(item['updatedAt']),
            "conversationId": item['conversationId'],
            "specialistId": user['_id'],
            "number": user['phoneNumber'],
            "latestMessage": null,
          };
        }));
      });

      await getLatestMessage();
    } else {
      print("Failed to fetch chat list: ${response.statusCode}");
    }
  }

  Future<void> getLatestMessage() async{
    final token = await StorageService.getToken();
    String? currentUserId;
    if (token != null) {
      final payload = JwtDecoder.decode(token);
      currentUserId = payload['sub'];
    }

    if (currentUserId == null) return;

    final response = await http.get(
      Uri.parse('${ApiConstants.socketUrl}${ApiConstants.Conversation}latest/messages'),
      headers: {
        'Content-Type': 'application/json',
        'User-Id': currentUserId,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> latestMessagesData = jsonDecode(response.body);
      print("Latest messages fetched: $latestMessagesData");

      setState(() {
        for (var convo in messages) {
          final latestMsg = latestMessagesData.firstWhere(
                (msg) => msg['conversationId'] == convo['conversationId'],
            orElse: () => null,
          );

          if (latestMsg != null) {
            convo['latestMessage'] = {
              'conversationId': latestMsg['conversationId'],
              'type': latestMsg['type'],
              'content': latestMsg['content'],
              'mediaUrl': latestMsg['mediaUrl'],
              'read': latestMsg['read'],
              'createdAt': latestMsg['createdAt'],
            };
          }
        }
      });
      print(messages);
    } else {
      print("Failed to fetch latest messages: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(fontFamily: 'Inter', color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:  messages.isEmpty
          ? Center(
        child: GestureDetector(
          onTap: widget.specialistMap,
          child: Text(
            'Talk to a nearby specialist to start a conversation.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final chat = messages[index];
          final avatarUrl = chat["avatarUrl"] ?? '';
          final name = chat["name"] ?? 'Unknown';
          //final time = chat["time"] ?? '';
          final specialid= chat["specialistId"] ?? '';
          final number= chat["number"] ?? '';
          final latestMessage = chat["latestMessage"];
          final message = latestMessage != null ? (latestMessage['content'] ?? '') : '';
          final messagePhoto = latestMessage != null ? (latestMessage['mediaUrl'] ?? '') : '';
          final messageType = latestMessage != null ? (latestMessage['type'] ?? '') : '';
          final messageStatus = latestMessage != null ? (latestMessage['read'] ?? false) : false;

          String formattedTime = '';
          if (latestMessage != null && latestMessage['createdAt'] != null) {
            try {
              final dateTime = DateTime.parse(latestMessage['createdAt']);
              final hours = dateTime.hour.toString().padLeft(2, '0');
              final minutes = dateTime.minute.toString().padLeft(2, '0');
              formattedTime = '$hours:$minutes';
            } catch (e) {
              formattedTime = '';
            }
          } else {
            formattedTime = '';
          }

          String subtitleText;
          TextStyle subtitleStyle = TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey[600],
          );

          if (messageType == 'TEXT') {
            subtitleText = message;
          } else if (messageType == 'PHOTO' || (messagePhoto.isNotEmpty)) {
            subtitleText = 'Sent a photo';
            subtitleStyle = subtitleStyle.copyWith(fontStyle: FontStyle.italic);
          } else {
            subtitleText = message;
          }

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(ApiConstants.baseUrl+avatarUrl)
                      : const AssetImage('assets/icons/sample_profile_pic.png') as ImageProvider,
                  radius: 24,
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  subtitleText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontStyle: messageType == 'PHOTO' ? FontStyle.italic : FontStyle.normal,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        specialistId: specialid,
                        profilePictureUrl: avatarUrl,
                        fullName: name,
                        phoneNumber: number,
                      ),
                    ),
                  );
                },
              ),
              // Removed Divider
            ],
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
