import 'package:flutter/material.dart';
import 'dart:io'; // needed for FileImage
import 'message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final hasText = message.text != null && message.text!.isNotEmpty;
    final hasImage = message.imageUrl != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasImage)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            child: Center(
                              child: Image.file(File(message.imageUrl!)),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 20,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white, size: 28),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(message.imageUrl!),
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (hasImage && hasText)
              SizedBox(height: 8),
            if (hasText)
              Text(
                message.text!,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
