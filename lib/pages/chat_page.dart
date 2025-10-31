import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/suggestion_chips.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/voice_emoji_service.dart';
import 'package:chat_app/services/ai_suggestion.dart';
import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserID;
  final String receiverUserEmail;
  final String receiverUserName;

  const ChatPage({
    super.key,
    required this.receiverUserID,
    required this.receiverUserEmail,
    required this.receiverUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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

    await _chatService.sendMessage(
      widget.receiverUserID,
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
          widget.receiverUserName,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.receiverUserID),
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

                List<Widget> messageWidgets = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isMe = data["senderId"] == currentUser.uid;
                  final message = data["message"] ?? "";

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  children: messageWidgets,
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
                    child: MyTextField(
                      controller: _messageController,
                      hintText: _isListening ? "Listening..." : "Type a message",
                      obscureText: false,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),

                  // Send Button
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Color(0xFF007AFF)),
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