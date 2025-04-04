import 'dart:async';
import 'package:bio_boost/screens/AgriWasteType.dart';
import 'package:flutter/material.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({super.key});

  @override
  _CompanyHomePageState createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  final List<String> imagePaths = ["images/add01.jpg", "images/add02.jpg"];

  final List<Map<String, String>> categories = [
    {'title': 'Paddy Husk & Straw', 'url': 'images/Paddy Husk & Straw.jpg'},
    {
      'title': 'Coconut Husks & Shells',
      'url': 'images/Coconut Husks & Shells.jpg',
    },
    {'title': 'Tea Waste', 'url': 'images/Tea Waste.jpg'},
    {
      'title': 'Rubber Wood & Latex Waste',
      'url': 'images/Rubber Wood & Latex Waste.jpg',
    },
    {
      'title': 'Fruit & Vegetable Waste',
      'url': 'images/Fruit & Vegetable Waste.jpg',
    },
    {'title': 'Sugarcane Bagasse', 'url': 'images/Sugarcane Bagasse.jpg'},
    {'title': 'Oil Cake & Residues', 'url': 'images/Oil Cake & Residues.jpeg'},
    {
      'title': 'Maize & Other Cereal Residues',
      'url': 'images/Maize & Other Cereal Residues.jpg',
    },
    {'title': 'Banana Plant Waste', 'url': 'images/Banana Plant Waste.jpg'},
    {'title': 'Other', 'url': 'images/others.jpeg'},
  ];

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? role = await _authService.getUserRole(user.uid);
        setState(() {
          _userRole = role;
          _isLoading = false;
        });

        if (role != 'Buyer') {
          setState(() {
            _errorMessage = 'You do not have permission to access this page.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user is signed in.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to check user role: $e';
      });
    }
  }

  late List<Widget> _pages;

  int _activePage = 0;

  final PageController _pageController = PageController(initialPage: 0);

  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (_pageController.page == imagePaths.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = List.generate(
      imagePaths.length,
      (index) => ImagePlaceholder(imagePath: imagePaths[index]),
    );
    startTimer();
    _checkUserRole();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text("Home", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userRole != 'Buyer') {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            "Access Denied",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "You do not have permission to access this page.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 170.0,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: imagePaths.length,
                          onPageChanged: (value) {
                            setState(() {
                              _activePage = value;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _pages[index];
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                              _pages.length,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor:
                                        _activePage == index
                                            ? Colors.teal
                                            : Colors.grey[850],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                child: Column(
                  children: [
                    Container(
                      height: 2, // Thickness of the border
                      color: Colors.grey[400], // Color of the border
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SalesListScreen(
                                selectedCategory: categories[index]['title']!,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Center(
                              child: Image.asset(
                                categories[index]['url']!,
                                height: 50,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            categories[index]['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final String imagePath;
  const ImagePlaceholder({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(imagePath, fit: BoxFit.cover);
  }
}
