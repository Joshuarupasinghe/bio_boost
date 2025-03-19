import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/logo.png',
              height: 40, 
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search Bio Boost',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
                padding: EdgeInsets.zero, // Remove default padding
                onPressed: () {},
              ),
            ),
          ],
        ),
        toolbarHeight: 60, // Increase app bar height to accommodate larger logo
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      
      body: const Center(
        child: Text(
          'Content Area - Grid of Agricultural Waste Types',
          style: TextStyle(color: Colors.white),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check),
            label: 'Wanted',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Home selected
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}