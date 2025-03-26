import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String avatar;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.avatar,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I\'m interested in your agricultural waste products',
      'isMe': false,
      'time': '10:20 AM',
    },
    {
      'text': 'Hi there! What type of waste are you looking for?',
      'isMe': true,
      'time': '10:22 AM',
    },
    {
      'text': 'I need coconut husks and shells for my composting project',
      'isMe': false,
      'time': '10:25 AM',
    },
    {
      'text': 'Great! I have about 500kg available. When do you need them?',
      'isMe': true,
      'time': '10:28 AM',
    },
    {
      'text': 'Next week would be perfect. What\'s your price per kg?',
      'isMe': false,
      'time': '10:30 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                widget.avatar,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(
              widget.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return Container(
      padding: EdgeInsets.only(
        left: message['isMe'] ? 64 : 16,
        right: message['isMe'] ? 16 : 64,
        top: 4,
        bottom: 4,
      ),
      alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: message['isMe'] ? Colors.teal : Colors.grey[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'],
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 4),
            Text(
              message['time'],
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[850],
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.teal),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                setState(() {
                  _messages.add({
                    'text': _messageController.text,
                    'isMe': true,
                    'time': '${DateTime.now().hour}:${DateTime.now().minute}',
                  });
                  _messageController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}