import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chat_detail.dart';
import '../services/chat_service.dart';
import 'user_search.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ChatService _chatService = ChatService();
  final String currentUserId = ChatService().currentUserId;

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(time);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat('E').format(time); // Weekday name
    } else {
      return DateFormat('M/d/yy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomId = chatRooms[index].id;
              final participants =
                  chatRoom['participants'] != null
                      ? List<String>.from(chatRoom['participants'])
                      : [];

              // Get the other user's ID (not the current user)
              final otherUserId =
                  participants.isNotEmpty
                      ? participants.firstWhere(
                        (id) => id != _chatService.currentUserId,
                        orElse: () => '',
                      )
                      : '';

              final unreadCount =
                  chatRoom.containsKey('unreadCounts') &&
                          chatRoom['unreadCounts'][_chatService.currentUserId] != null
                      ? chatRoom['unreadCounts'][_chatService.currentUserId]
                      : 0;

              if (!chatRoom.containsKey('participants') ||
                  chatRoom['participants'] == null) {
                return SizedBox.shrink(); // Skip this chat room if data is invalid
              }

              // Use FutureBuilder to get the other user's details
              return FutureBuilder<Map<String, dynamic>>(
                future: _chatService.getUserDetails(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: CircleAvatar(backgroundColor: Colors.grey),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final name =
                      '${userData['firstName']} ${userData['lastName']}';
                  final initials =
                      userData['firstName'][0] + userData['lastName'][0];
                  final lastMessage = chatRoom['lastMessage'] ?? '';
                  final lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
                    chatRoom['lastMessageTime'] ??
                        DateTime.now().millisecondsSinceEpoch,
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        initials,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight:
                            unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: TextStyle(
                        color:
                            unreadCount > 0 ? Colors.white : Colors.grey[400],
                        fontWeight:
                            unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(lastMessageTime),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (unreadCount > 0)
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      _chatService.markMessagesAsRead(
                        chatRoomId,
                        _chatService.currentUserId,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatDetailScreen(
                                name: name,
                                avatar: initials,
                                userId: otherUserId,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the UserSearchScreen when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserSearchScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.chat),
      ),
    );
  }
}
