import 'package:major/services/storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  Future<void> initSocket() async {
    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found, cannot connect to socket");
      return;
    }

    if (_socket != null && _socket!.connected) {
      print("Socket already connected");
      return;
    }

    _socket = IO.io(
      'http://192.168.1.83:4000',
      //'http://192.168.20.160:4000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {
          'token': token,
        },
      },
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to socket server');
      print("Token used: $token");

      // print("Is socket connected: ${_socket?.connected}");
      // print("Listeners already on receive_message: ${_socket?.hasListeners('receive_message')}");
      // listenForMessages((data){
      //   print("Inline Listener: $data");
      // });
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    _socket!.onConnectError((data) {
      print('Connect error: $data');
    });

    _socket!.onError((data) {
      print('Socket error: $data');
    });
  }

  void sendMessage(Map<String, dynamic> messageData) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', messageData);
    } else {
      print("Cannot send message: Socket not connected");
    }
  }

  void listenForMessages(Function(dynamic) callback) {
    print("Setting up Listener");
    _socket?.on("receive_message", (data) {
      print('Received receive_message event with data: $data');
      callback(data);
    });
  }

  void dispose() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
      print("Socket connection disposed");
    }
  }

  bool get isConnected => _socket?.connected ?? false;
}

