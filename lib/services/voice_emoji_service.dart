import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceEmojiService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  
  // ===== Emoji Map =====
  final Map<String, String> _emojiMap = {
    // Faces
    "smile": "😊",
    "laugh": "😂",
    "wink": "😉",
    "angry": "😡",
    "sad": "😢",
    "cry": "😭",
    "kiss": "😘",
    "thinking": "🤔",
    "cool": "😎",

    // Hearts
    "heart": "❤️",
    "red heart": "❤️",
    "blue heart": "💙",
    "green heart": "💚",
    "yellow heart": "💛",
    "black heart": "🖤",

    // Drinks
    "water bottle": "🍼",
    "wine": "🍷",
    "beer": "🍺",
    "beers": "🍻",
    "cocktail": "🍸",
    "tropical drink": "🍹",
    "champagne": "🍾",
    "soda": "🥤",
    "milk": "🥛",
    "coffee": "☕",
    "tea": "🍵",

    // Food
    "burger": "🍔",
    "pizza": "🍕",
    "fries": "🍟",
    "hotdog": "🌭",
    "sandwich": "🥪",
    "taco": "🌮",
    "burrito": "🌯",
    "spaghetti": "🍝",
    "rice": "🍚",
    "sushi": "🍣",
    "cake": "🎂",
    "chocolate": "🍫",
    "ice cream": "🍦",
    "donut": "🍩",
    "cookie": "🍪",

    // Sports
    "football": "⚽",
    "basketball": "🏀",
    "tennis": "🎾",
    "cricket": "🏏",
    "baseball": "⚾",
    "rugby": "🏉",
    "trophy": "🏆",

    // Travel
    "car": "🚗",
    "bike": "🚲",
    "bus": "🚌",
    "train": "🚆",
    "plane": "✈️",
    "ship": "🚢",
    "rocket": "🚀",

    // Nature
    "rose": "🌹",
    "sun": "☀️",
    "moon": "🌙",
    "tree": "🌳",
    "flower": "🌸",
    "fire": "🔥",
    "star": "⭐",
  };

  VoiceEmojiService() {
    _speech = stt.SpeechToText();
  }

  /// Initialize speech recognition
  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  /// Request microphone permission
  Future<void> requestMicrophonePermission() async {
    await Permission.microphone.request();
  }

/// Start listening for voice input and convert to emoji text
void startListening({
  required Function(String) onResult,
  required Function() onListeningStarted,
  required Function() onListeningStopped,
}) {
  if (!_isListening) {
    _isListening = true;
    onListeningStarted();
    
    _speech.listen(
      onResult: (val) {
        String spoken = val.recognizedWords.toLowerCase();
        String converted = _convertToEmoji(spoken);
        onResult(converted);
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

}
  /// Stop listening
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  /// Convert spoken text to emoji text
  String _convertToEmoji(String text) {
    // Clean the text
    String cleanedText = text.toLowerCase();
    cleanedText = cleanedText.replaceAll(RegExp(r'[^\w\s]'), ' ');
    cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();

    String converted = cleanedText;

    // Sort keys by length descending to handle multi-word emojis first
    var sortedKeys = _emojiMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (var key in sortedKeys) {
      final pattern = RegExp(key.toLowerCase(), caseSensitive: false);
      converted = converted.replaceAll(pattern, _emojiMap[key]!);
    }

    return converted;
  }

  /// Toggle listening state
void toggleListening({
  required Function(String) onResult,
  required Function() onListeningStarted,
  required Function() onListeningStopped,
}) {
  if (_isListening) {
    stopListening();
    onListeningStopped();
  } else {
    startListening(
      onResult: onResult,
      onListeningStarted: onListeningStarted,
      onListeningStopped: onListeningStopped,
    );
  }
}

  /// Add custom emoji mapping
  void addCustomEmoji(String word, String emoji) {
    _emojiMap[word.toLowerCase()] = emoji;
  }

  /// Remove emoji mapping
  void removeEmoji(String word) {
    _emojiMap.remove(word.toLowerCase());
  }

  /// Get all available emoji keywords
  List<String> getAvailableKeywords() {
    return _emojiMap.keys.toList();
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get the emoji map (read-only)
  Map<String, String> get emojiMap => Map.unmodifiable(_emojiMap);
}