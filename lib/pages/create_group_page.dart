import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<String> _selectedMembers = [];
  List<Map<String, dynamic>> _contacts = []; // Changed to store data directly
  bool _isLoading = false;
  bool _loadingContacts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _loadingContacts = false;
        });
        return;
      }

      // Try different approaches to get users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: currentUser.uid) // Exclude current user
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        setState(() {
          _contacts = usersSnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
          _loadingContacts = false;
        });
      } else {
        // Fallback: try to get all users
        final allUsersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .get();

        setState(() {
          _contacts = allUsersSnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
          _loadingContacts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading contacts: $e';
          _loadingContacts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleMemberSelection(String userId) {
    setState(() {
      if (_selectedMembers.contains(userId)) {
        _selectedMembers.remove(userId);
      } else {
        _selectedMembers.add(userId);
      }
    });
  }

  void _createGroup() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure creator is in the group
      final allMembers = [..._selectedMembers];
      if (!allMembers.contains(currentUser.uid)) {
        allMembers.add(currentUser.uid);
      }

      String groupId = await _chatService.createGroup(
        groupName,
        allMembers,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, groupId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'Create Group',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF007AFF),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: Color(0xFF007AFF),
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              onPressed: _createGroup,
              icon: const Icon(Icons.check, color: Color(0xFF007AFF)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Group Name Input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF007AFF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: const Color(0xFF1C1C1E),
                filled: true,
              ),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            const SizedBox(height: 20),

            // Selected Members Count
            Text(
              'Selected: ${_selectedMembers.length} members',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            // Error message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            // Contacts List
            Expanded(
              child: _loadingContacts
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF007AFF),
                      ),
                    )
                  : _contacts.isEmpty
                      ? const Center(
                          child: Text(
                            'No contacts available',
                            style: TextStyle(color: Color(0xFF8E8E93)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            final contactId = contact['id'] ?? contact['uid'] ?? '';
                            final userName = contact['fullName'] ?? 
                                           contact['displayName'] ?? 
                                           contact['email']?.split('@').first ?? 
                                           'Unknown User';
                            final userEmail = contact['email'] ?? 'No email';
                            final isSelected = _selectedMembers.contains(contactId);

                            // Get first character safely
                            final initial = userName.isNotEmpty 
                                ? userName[0].toUpperCase() 
                                : '?';

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: const Color(0xFF007AFF), width: 2)
                                    : null,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF007AFF),
                                  child: Text(
                                    initial,
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
                                  ),
                                ),
                                subtitle: Text(
                                  userEmail,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                                trailing: Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                                ),
                                onTap: () => _toggleMemberSelection(contactId),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}