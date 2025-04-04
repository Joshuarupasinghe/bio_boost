import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // Create or get a chat room between two users
  Future<String> createChatRoom(String otherUserId) async {
    try {
      // Sort IDs to ensure consistent chat room IDs
      final List<String> ids = [currentUserId, otherUserId]..sort();
      final String chatRoomId = ids.join('_');

      // Check if the chat room already exists
      final chatRoomDoc =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        // Verify both users exist before creating chat room
        final currentUserDoc =
            await _firestore.collection('users').doc(currentUserId).get();
        final otherUserDoc =
            await _firestore.collection('users').doc(otherUserId).get();

        if (!currentUserDoc.exists || !otherUserDoc.exists) {
          print(
            'One of the users does not exist: currentUser=${currentUserDoc.exists}, otherUser=${otherUserDoc.exists}',
          );
          return '';
        }

        // Create new chat room
        await _firestore.collection('chatRooms').doc(chatRoomId).set({
          'participants': ids,
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return chatRoomId;
    } catch (error) {
      print('Error in createChatRoom: $error');
      return '';
    }
  }

  // Send a message
  Future<void> sendMessage(
    String chatRoomId,
    String receiverId,
    String message,
  ) async {
    // Reference to the messages collection for this chat room
    final messagesRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages');

    // Current timestamp
    final timestamp = DateTime.now();

    //Get chat room document
    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    final chatRoomDoc = await chatRoomRef.get();

    Map<String, dynamic> unreadCounts = {};
    if (chatRoomDoc.exists && chatRoomDoc.data()!.containsKey('unreadCounts')){
      unreadCounts = Map<String, dynamic>.from(chatRoomDoc['unreadCounts']);
    }

    unreadCounts[receiverId] = (unreadCounts[receiverId] ?? 0) + 1;
    // Add the message to Firestore
    await messagesRef.add({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'read' : false,
    });

    // Update the chat room with the last message info
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp.millisecondsSinceEpoch,
      'unreadCounts': unreadCounts,
    });
  }

  // Stream of messages for a specific chat room
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream of chat rooms for the current user
  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Get user details by ID
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  // Mark messages as read (optional)
  Future<void> markMessagesAsRead(String chatRoomId, String otherUserId) async {
  final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
  
  // Reset unread count for the current user
  await chatRoomRef.update({
    'unreadCounts.$currentUserId': 0,
  });

  // Mark all messages from the other user as read
  final batch = _firestore.batch();
  final querySnapshot = await chatRoomRef
      .collection('messages')
      .where('senderId', isEqualTo: otherUserId)
      .where('read', isEqualTo: false)
      .get();

  for (var doc in querySnapshot.docs) {
    batch.update(doc.reference, {'read': true});
  }

  await batch.commit();
  }

  Stream<int> getUnreadChatCount() {
  return _firestore
      .collection('chatRooms')
      .where('participants', arrayContains: currentUserId)
      .snapshots()
      .map((snapshot) {
        int totalUnread = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data.containsKey('unreadCounts') &&
              data['unreadCounts'][currentUserId] != null) {
            totalUnread += (data['unreadCounts'][currentUserId] as int);
          }
        }
        return totalUnread;
      });
}

}
