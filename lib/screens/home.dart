import 'package:bio_boost/screens/home_company.dart';
import 'package:bio_boost/screens/home_seller.dart';
import 'package:bio_boost/screens/profile_company.dart';
import 'package:bio_boost/screens/seller_profile.dart';
import 'package:bio_boost/screens/wanted_company.dart';
import 'package:bio_boost/screens/create_sales01.dart';
import 'package:bio_boost/screens/create_sales02.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_list.dart';
import 'benefits.dart';

class HomePage extends StatefulWidget {
  final String? userRole;
  const HomePage({super.key, required this.userRole});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Start with Home selected
  int _unreadChatCount = 0;


  @override
  Widget build(BuildContext context) {
    // Assign profile page dynamically based on user role
    List<Widget> screens = [
      WantedCompanyPage(),
      Center(
        child: Text('Wishlist Screen', style: TextStyle(color: Colors.white)),
      ),
      widget.userRole == 'Buyer'
        ? CompanyHomePage()
        :SellerHomePage(),
      ChatList(),
      //CreateSales01(),
      widget.userRole == 'Buyer'
          ? CompanyProfilePage()
          : SellerProfilePage(), // Dynamic Profile Page
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar:
          _currentIndex == 3
              ? null
              : AppBar(
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
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
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                toolbarHeight: 60,
                backgroundColor: Colors.grey[850],
                elevation: 0,
              ),
      body: screens[_currentIndex],
      bottomNavigationBar: StreamBuilder<int>(
  stream: ChatService().getUnreadChatCount(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      _unreadChatCount = snapshot.data!;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[850],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'Wanted',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.question_answer),
              if (_unreadChatCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadChatCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  },
),

    );
  }
}
