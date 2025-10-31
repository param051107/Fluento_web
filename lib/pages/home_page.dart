import 'package:chat_app/auth/auth_service.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/add_contact_page.dart';
import 'package:chat_app/pages/create_group_page.dart';
import 'package:chat_app/pages/group_chat_page.dart';
import 'package:chat_app/pages/offline_sms.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 0 = Contacts, 1 = Groups
  int _currentIndex = 0; 

  // Sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  // Message button tap handler
  void _onMessageButtonTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HybridVoiceSMSPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),

        title: Text(
          _currentIndex == 0 ? 'Contacts' : 'Groups',
          style: const TextStyle(color: Color(0xFFFFFFFF)),
        ),

        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout, color: Color(0xFF007AFF)),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),

            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _currentIndex = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: _currentIndex == 0
                          ? const Color(0xFF007AFF)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'Contacts',
                      style: TextStyle(
                        color: _currentIndex == 0
                            ? Colors.white
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _currentIndex == 1
                          ? const Color(0xFF007AFF)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'Groups',
                      style: TextStyle(
                        color: _currentIndex == 1
                            ? Colors.white
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: _currentIndex == 0 ? _buildContactList() : _buildGroupList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Message Button
          if (_auth.currentUser != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16, right: 16),
              child: FloatingActionButton(
                onPressed: _onMessageButtonTap,
                backgroundColor: const Color(0xFF007AFF),
                mini: true,
                child: const Icon(
                  Icons.message,
                  color: Colors.white,
                ),
              ),
            ),
          // Original Plus Button
          if (_auth.currentUser != null)
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _currentIndex == 0
                        ? const AddContactPage()
                        : const CreateGroupPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF007AFF),
              child: Icon(
                _currentIndex == 0 ? Icons.add : Icons.group_add,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  //CONTACTS
  Widget _buildContactList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return _buildAuthError();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _userService.getContacts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorText(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingSpinner();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No contacts yet. Add some friends to chat with!',
              style: TextStyle(color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: snapshot.data!.docs
              .map((doc) => _buildContactListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildContactListItem(DocumentSnapshot document) {
    String contactId = document.id;

    return FutureBuilder<DocumentSnapshot>(
      future: _userService.getUserById(contactId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingContactTile();
        }

        if (userSnapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        Map<String, dynamic> userData =
            userSnapshot.data!.data() as Map<String, dynamic>;

        String userName = userData['fullName'] ?? 
                         userData['displayName'] ?? 
                         userData['email']?.split('@').first ?? 
                         'Unknown User';
        String userEmail = userData['email'] ?? 'No email';
        String userId = userData['uid'] ?? contactId;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: _tileBoxDecoration(),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF007AFF),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            title: Text(
              userName,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w500,
              ),
            ),

            subtitle: Text(
              userEmail,
              style: const TextStyle(color: Color(0xFF8E8E93)),
            ),

            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF8E8E93),
              size: 20,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: userEmail,
                    receiverUserID: userId,
                    receiverUserName: userName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //GROUPS
  Widget _buildGroupList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return _buildAuthError();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getUserGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorText(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingSpinner();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No groups yet. Create your first group!',
              style: TextStyle(color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: snapshot.data!.docs
              .map((doc) => _buildGroupListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildGroupListItem(DocumentSnapshot document) {
    Map<String, dynamic> groupData =
        document.data() as Map<String, dynamic>? ?? {};
    String groupId = document.id;
    String groupName = groupData['name'] ?? 'Unnamed Group';
    List<dynamic> participants = groupData['participants'] ?? [];
    int memberCount = participants.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: _tileBoxDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: CircleAvatar(
          backgroundColor: const Color(0xFF007AFF),
          child: Text(
            groupName.isNotEmpty ? groupName[0].toUpperCase() : 'G',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        title: Text(
          groupName,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),

        subtitle: Text(
          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
          style: const TextStyle(color: Color(0xFF8E8E93)),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF8E8E93),
          size: 20,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupChatPage(
                groupId: groupId,
                groupName: groupName,
              ),
            ),
          );
        },
      ),
    );
  }

  //HELPERS
  Widget _errorText(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $message',
            style: const TextStyle(color: Color(0xFFFF3B30)),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _buildAuthError() => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please sign in to view contacts and groups',
            style: TextStyle(color: Color(0xFFFF3B30)),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _loadingSpinner() => const Center(
        child: CircularProgressIndicator(color: Color(0xFF007AFF)),
      );

  Widget _loadingContactTile() => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: _tileBoxDecoration(),
        child: const ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF2C2C2E),
            child: Icon(Icons.person, color: Color(0xFF8E8E93)),
          ),
          title: Text('Loading...', style: TextStyle(color: Color(0xFF8E8E93))),
        ),
      );

  BoxDecoration _tileBoxDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1C1C1E),
      );
}