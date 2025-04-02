import 'package:bio_boost/screens/profile_company.dart';
import 'package:bio_boost/screens/seller_profile.dart';
import 'package:bio_boost/screens/wanted_company.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // Assign profile page dynamically based on user role
    List<Widget> screens = [
      WantedCompanyPage(),
      Center(
          child: Text('Wishlist Screen',
              style: TextStyle(color: Colors.white))),
      BenefitsPage(),
      ChatList(),
      widget.userRole == 'Buyer'
          ? CompanyProfilePage()
          : SellerProfilePage(), // Dynamic Profile Page
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _currentIndex == 3
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
                      icon:
                          const Icon(Icons.search, color: Colors.white, size: 20),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fact_check), label: 'Wanted'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
