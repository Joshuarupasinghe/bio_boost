import 'package:flutter/material.dart';
import 'chat_detail.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample chat data
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'John Smith',
        'lastMessage': 'Do you have paddy husk available?',
        'time': '10:30 AM',
        'unread': 2,
        'avatar': 'JS',
      },
      {
        'name': 'Maria Garcia',
        'lastMessage': 'I can supply coconut husks next week',
        'time': 'Yesterday',
        'unread': 0,
        'avatar': 'MG',
      },
      {
        'name': 'Ahmed Kumar',
        'lastMessage': 'Price looks good, let\'s discuss further',
        'time': 'Yesterday',
        'unread': 0,
        'avatar': 'AK',
      },
      {
        'name': 'Green Energy Co.',
        'lastMessage': 'We need 5 tons of sugarcane bagasse',
        'time': 'Mon',
        'unread': 5,
        'avatar': 'GE',
      },
      {
        'name': 'Eco Solutions',
        'lastMessage': 'Can you deliver the banana plant waste?',
        'time': 'Sun',
        'unread': 0,
        'avatar': 'ES',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                chat['avatar'],
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              chat['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              chat['lastMessage'],
              style: TextStyle(color: Colors.grey[400]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                if (chat['unread'] > 0)
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat['unread']}',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    name: chat['name'],
                    avatar: chat['avatar'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: Icon(Icons.chat),
      ),
    );
  }
}