import 'package:chat_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();

  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  // Search users by email
  Future<void> _searchUsers() async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await _userService.searchUsers(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching users: $e")),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Add a contact
  Future<void> _addContact(String userId) async {
    try {
      final alreadyContact = await _userService.isContact(userId);

      if (alreadyContact) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is already in your contacts")),
        );
        return;
      }

      await _userService.addContact(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding contact: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          "Add Contact",
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter email address",
                      hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: const Color(0xFF1C1C1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _searchUsers,
                  icon: const Icon(Icons.search, color: Color(0xFF007AFF)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Results
            if (_isSearching)
              const CircularProgressIndicator(color: Color(0xFF007AFF))
            else if (_searchResults.isEmpty)
              const Text(
                "No users found",
                style: TextStyle(color: Color(0xFF8E8E93)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final userDoc = _searchResults[index];
                    final userData =
                        userDoc.data() as Map<String, dynamic>? ?? {};

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF007AFF),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          userData["fullName"] ?? "Unknown",
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          userData["email"] ?? "",
                          style: const TextStyle(color: Color(0xFF8E8E93)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add,
                              color: Color(0xFF007AFF)),
                          onPressed: () => _addContact(userDoc.id),
                        ),
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