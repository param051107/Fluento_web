// lib/services/chat_service.dart
import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String getCurrentUserId() {
    final user = _authService.getCurrentUser();
    return user?.uid ?? '';
  }

  // -----------------------
  // Send a private message
  // -----------------------
  Future<void> sendMessage(String receiverId, String message) async {
    final sender = _authService.getCurrentUser();
    if (sender == null) return;

    final String senderId = sender.uid;
    final String senderEmail = sender.email ?? '';

    // Create a sorted chat room id for sender+receiver
    final ids = [senderId, receiverId]..sort();
    final chatRoomId = ids.join('_');

    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // -----------------------
  // Stream of private chat messages between current user and otherUserId
  // -----------------------
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUid = getCurrentUserId();
    if (currentUid.isEmpty) return const Stream.empty();

    final ids = [currentUid, otherUserId]..sort();
    final chatRoomId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // -----------------------
  // GROUP MESSAGES
  // -----------------------
  Future<void> sendGroupMessage(String groupId, String message) async {
    final sender = _authService.getCurrentUser();
    if (sender == null) return;

    try {
      // Get user's display name
      final userDoc = await _firestore.collection('users').doc(sender.uid).get();
      
      String senderName = 'Unknown';
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        senderName = data['fullName'] ?? 
                    data['displayName'] ?? 
                    sender.email?.split('@').first ?? 
                    'Unknown';
      } else if (sender.email != null) {
        senderName = sender.email!.split('@').first;
      }

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'senderId': sender.uid,
        'senderEmail': sender.email ?? '',
        'senderName': senderName, // Added this field
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending group message: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // -----------------------
  // Groups for current user
  // -----------------------
  Stream<QuerySnapshot> getUserGroups() {
    final user = _authService.getCurrentUser();
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('groups')
        .where('participants', arrayContains: user.uid)
        .snapshots();
  }

  Future<String> createGroup(String name, List<String> participantIds) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    
    try {
      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'participants': participantIds,
        'createdBy': user.uid, // Added this field
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }
}