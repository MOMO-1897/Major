class Message {
  final String id;
  final String? text;
  final String? imageUrl;
  final String senderId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      senderId: json['senderId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }


  //to convert message back to JSON when sending it to server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
