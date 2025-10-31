import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isMe ? const Color(0xFF007AFF) : const Color(0xFF2C2C2E),
      ),
      
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}