import 'package:bio_boost/screens/profile_company.dart';
import 'package:bio_boost/screens/seller_profile.dart';
import 'package:bio_boost/screens/wanted_company.dart';
import 'package:flutter/material.dart';
import 'chat_list.dart';
import 'benefits.dart';
import 'wishlist.dart';

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
    // Debug print to check the user role
    print('Current user role: ${widget.userRole}');
    
    // Normalize the role to lowercase for comparison
    final normalizedRole = widget.userRole?.toLowerCase() ?? '';
    print('Normalized role: $normalizedRole');

    // Assign screens based on user role
    final List<Widget> screens = [
      normalizedRole == 'seller' 
          ? const WantedCompanyPage() 
          : const Center(child: Text('Access Denied - Only for Sellers', style: TextStyle(color: Colors.white))),
      const WishlistPage(),
      const BenefitsPage(),
      const ChatList(),
      normalizedRole == 'buyer'
          ? const CompanyProfilePage()
          : normalizedRole == 'seller'
              ? const SellerProfilePage()
              : const CompanyProfilePage(), // Default to CompanyProfilePage if role is null or unknown
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _currentIndex == 3 ? null : AppBar(
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
                  style: const TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search Bio Boost',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.fact_check),
            label: normalizedRole == 'seller' ? 'Wanted' : 'Sales',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile'
          ),
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
