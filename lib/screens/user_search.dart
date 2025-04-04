import 'package:bio_boost/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with all users except the current user
    _performSearch('');
  }

Future<void> _performSearch(String searchText) async {
  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore.collection('users');

    // Exclude the current user
    query = query.where('email', isNotEqualTo: FirebaseAuth.instance.currentUser!.email);

    if (searchText.isNotEmpty) {
      query = query
          .where('firstName', isGreaterThanOrEqualTo: searchText)
          .where('firstName', isLessThanOrEqualTo: '$searchText\uf8ff');
    }

    QuerySnapshot querySnapshot = await query.get();

    setState(() {
      _searchResults = querySnapshot.docs;
      _isLoading = false;
    });
  } catch (error) {
    print('Error searching users: $error');
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('New Chat'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
              ? Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final userData =
                      _searchResults[index].data() as Map<String, dynamic>;
                  final userId = userData['uid'];
                  final firstName = userData['firstName'] ?? '';
                  final lastName = userData['lastName'] ?? '';
                  final companyName = userData['companyName'] ?? '';
                  final role = userData['role'] ?? 'seller';
                  final initials =
                      firstName.isNotEmpty && lastName.isNotEmpty
                          ? firstName[0] + lastName[0]
                          : '??';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        initials,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '$firstName $lastName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: role == 'buyer' ? Colors.blue : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // In UserSearchScreen.dart, modify the onTap function:
                    onTap: () async {
                      try {
                        final chatService = ChatService();

                        // Use either the document ID or the uid field, whichever is correct
                        final userId =
                            _searchResults[index].id;

                        final chatRoomId = await chatService.createChatRoom(userId);

                        if (chatRoomId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatDetailScreen(
                                    name: '$firstName $lastName',
                                    avatar: initials,
                                    userId: userId,
                                  ),
                            ),
                          );
                        } else {
                          // Show error if chat room creation returned empty ID
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create chat room'),
                            ),
                          );
                        }
                      } catch (error) {
                        print('Error creating chat room: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    },
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
