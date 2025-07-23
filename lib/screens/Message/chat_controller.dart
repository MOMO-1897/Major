import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/screens/Message/chat_screen.dart';
import 'package:major/services/storage_service.dart';
import 'message.dart';
import 'socket_service.dart';
import 'package:major/utils/constants.dart';
import 'package:http/http.dart' as http;

class ChatController extends StateNotifier<List<Message>> {
  final SocketService _socketService = SocketService();
  bool _listenerAdded = false;
  String? _conversationId;

  ChatController(Ref ref) : super([]) {
    print('ChatController initialized');
    //_socketService.initSocket();
    //initSocketListener();
  }

  Future<void> setConversationId(String conversationId) async {
    if (_conversationId == conversationId) return; // already set
    _conversationId = conversationId;

    final messages= await fetchMessagesForConversation(conversationId);
    state = messages;

    if (!_listenerAdded) {
      await initSocketListener();
    }
  }

  Future<void> initSocketListener() async {
    await _socketService.initSocket();

    if (_listenerAdded) {
      print('Socket listener already added, skipping.');
      return;
    }

    _listenerAdded = true;

    _socketService.listenForMessages((data) {
      print('Raw data received in controller: $data');

      final newMessage = Message.fromJson(Map<String, dynamic>.from(data));

      if (!state.any((msg) => msg.id == newMessage.id)) {
        state = [...state, newMessage];
      }
    });
  }

  void sendMessage(String conversationId, String currentUserId, String receiverId, String? text, String? imageUrl) {
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

    final isImage = imageUrl != null;

    final newMessage = Message(
      id: DateTime.now().toIso8601String(),
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      type: isImage ? 'IMAGE' : 'TEXT',
      content: isImage ? null : text?.trim(),
      mediaUrl: isImage ? imageUrl : null,
      read: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _socketService.sendMessage(newMessage.toJson());
    state = [...state, newMessage];
  }

  Future<List<Message>> fetchMessagesForConversation(String conversationId) async {
    final url = Uri.parse('${ApiConstants.socketUrl}${ApiConstants.Conversation}messages/$conversationId');
    String? currentUserId;

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

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'User-Id': currentUserId ?? '',
      });
      print('UserId: $currentUserId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((json) => Message.fromJson(json)).toList();

        for (var msg in messages) {
          print('Fetched message: ${msg.toString()}');
        }

        return messages;
      } else {
        print('Failed to fetch messages. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

}
