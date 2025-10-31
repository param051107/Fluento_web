// lib/services/user_service.dart
import 'package:chat_app/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Return currently logged in user's UID (empty string if none)
  String getCurrentUserId() {
    final user = _authService.getCurrentUser();
    return user?.uid ?? '';
  }

  // Return currently logged in user's email (empty string if none)
  String getCurrentUserEmail() {
    final user = _authService.getCurrentUser();
    return user?.email ?? '';
  }

  // -----------------------
  // One-time search by email (used by AddContactPage)
  // Returns a List of DocumentSnapshot (can be awaited)
  // -----------------------
  Future<List<DocumentSnapshot>> searchUsers(String emailQuery) async {
    final queryEmail = emailQuery.trim().toLowerCase();
    if (queryEmail.isEmpty) return [];

    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: queryEmail)
        .get();

    final currentUid = getCurrentUserId();

    // Filter out the current user if present
    final results = querySnapshot.docs
        .where((doc) => doc.id != currentUid)
        .toList();

    return results;
  }

  // -----------------------
  // Stream of contacts (used by HomePage)
  // Path: /contacts/{currentUserId}/userContacts/{contactId}
  // -----------------------
  Stream<QuerySnapshot> getContacts() {
    final user = _authService.getCurrentUser();
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('contacts')
        .doc(user.uid)
        .collection('userContacts')
        .snapshots();
  }

  // -----------------------
  // Add a contact (creates document at /contacts/{uid}/userContacts/{contactId})
  // -----------------------
  Future<void> addContact(String contactId) async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    await _firestore
        .collection('contacts')
        .doc(user.uid)
        .collection('userContacts')
        .doc(contactId)
        .set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // -----------------------
  // Check whether a userId is already in current user's contacts
  // -----------------------
  Future<bool> isContact(String userId) async {
    final user = _authService.getCurrentUser();
    if (user == null) return false;

    final doc = await _firestore
        .collection('contacts')
        .doc(user.uid)
        .collection('userContacts')
        .doc(userId)
        .get();

    return doc.exists;
  }

  // -----------------------
  // Get user document by uid
  // -----------------------
  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // -----------------------
  // Helper to create user doc (if you need it elsewhere)
  // -----------------------
  Future<void> createUserDocument({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}