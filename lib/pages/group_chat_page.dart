import 'package:chat_app/components/suggestion_chips.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/voice_emoji_service.dart';
import 'package:chat_app/services/ai_suggestion.dart';
import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late VoiceEmojiService _voiceService;
  bool _isListening = false;
  final ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier([]);
  String _lastReceivedMessage = "";

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceEmojiService();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    bool initialized = await _voiceService.initialize();
    if (initialized) {
      await _voiceService.requestMicrophonePermission();
    } else {
      print("Voice recognition not available");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _chatService.sendGroupMessage(
      widget.groupId,
      _messageController.text.trim(),
    );

    _messageController.clear();
    _suggestionsNotifier.value = [];
  }

  void _generateSuggestions() {
    if (_lastReceivedMessage.isNotEmpty) {
      _suggestionsNotifier.value = getOfflineSuggestions(_lastReceivedMessage);
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _messageController.text = suggestion;
    _suggestionsNotifier.value = [];
  }

  void _toggleVoiceListening() {
    _voiceService.toggleListening(
      onResult: (convertedText) {
        setState(() {
          _messageController.text = convertedText;
        });
      },
      onListeningStarted: () {
        setState(() {
          _isListening = true;
        });
      },
      onListeningStopped: () {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    _suggestionsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.getCurrentUser()!;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: Text(
          widget.groupName,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getGroupMessages(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading messages",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF007AFF)),
                  );
                }

                // Find the most recent received message (since list is reversed, first non-user message is most recent)
                String lastReceived = "";
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final senderId = data["senderId"];
                  final message = data["message"] ?? "";
                  if (senderId != currentUser.uid && message.isNotEmpty) {
                    lastReceived = message;
                    break; // Since docs are in reverse chronological order, first match is most recent
                  }
                }

                // Update last received message for context in manual suggestions
                _lastReceivedMessage = lastReceived;

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data["senderId"] == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                data["senderName"] ?? "Unknown",
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              data["message"] ?? "",
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Suggestion Chips (shown only after button press)
          SuggestionChips(
            suggestionsNotifier: _suggestionsNotifier,
            onSuggestionSelected: _onSuggestionSelected,
          ),

          // input section with voice button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF1C1C1E),
              child: Row(
                children: [
                  // Suggest Button
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline, color: Color(0xFF007AFF)),
                    onPressed: _generateSuggestions,
                  ),
                  SizedBox(width: 8),

                  // Voice Button
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: _isListening ? Colors.red : Color(0xFF007AFF),
                    ),
                    onPressed: _toggleVoiceListening,
                  ),
                  SizedBox(width: 8),

                  // Message Input Field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _isListening ? "Listening..." : "Type a message...",
                        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  
                  // Send Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Color(0xFF007AFF)
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}