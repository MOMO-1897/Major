class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String type;
  final String? content;
  final String? mediaUrl;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.read = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      type: json['type'] ?? 'TEXT',
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  @override
  String toString() {
    return 'Message(from: $senderId, to: $receiverId, content: $content, type: $type)';
  }
}
