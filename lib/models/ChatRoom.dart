class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime lastMessageTime;
  final String lastMessage;
  final Map<String, int> unreadCounts;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.unreadCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'unreadCounts': unreadCounts,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants']),
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'],
      ),
      lastMessage: map['lastMessage'],
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }
}
