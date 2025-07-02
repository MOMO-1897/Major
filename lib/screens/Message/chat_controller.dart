
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'message.dart';
import 'socket_service.dart';

class ChatController extends StateNotifier<List<Message>> {
  final SocketService _socketService = SocketService();

  ChatController(Ref ref) : super([]) {
    print('ChatController initialized');
    _socketService.initSocket();
    initSocketListener();
  }

  void initSocketListener(){
    _socketService.listenForMessages((data) {
      print('Raw data: $data');

      final newMessage = Message.fromJson(Map<String, dynamic>.from(data));

      state = [...state, newMessage];
    });
  }

  void sendMessage(String? text, String? imageUrl) {
    if ((text==null || text.trim().isEmpty) && (imageUrl==null)) {
      return;
    }
    final newMessage = Message(
      id: DateTime.now().toIso8601String(),
      text: text?.trim(),
      imageUrl: imageUrl,
      senderId: 'user123',
      timestamp: DateTime.now(),
    );
    _socketService.sendMessage(newMessage.toJson());
    state = [...state, newMessage];
  }
}
