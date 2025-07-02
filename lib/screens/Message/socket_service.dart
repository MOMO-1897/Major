import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;

  void initSocket() {
    socket = IO.io(
      'http://192.168.1.83:4000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );


    if (socket == null){
      return;
    }else {
      socket.connect();
    }

    socket.onConnect((_) {
      print('✅ Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('❌ Disconnected from socket server');
    });

    socket.onConnectError((data) {
      print('⚠️ Connect error: $data');
    });

    socket.onError((data) {
      print('⚠️ Socket error: $data');
    });
  }

  void sendMessage(Map<String, dynamic> messageData) {
    socket.emit('send_message', messageData);
  }

  void listenForMessages(Function(dynamic) callback) {
    socket.on('receive_message', callback);
  }

  void dispose() {
    socket.dispose();
  }
}
