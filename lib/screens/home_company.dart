import 'dart:async';
import 'package:bio_boost/screens/AgriWasteType.dart';
import 'package:flutter/material.dart';

class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({super.key});

  @override
  _CompanyHomePageState createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
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
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
                              (context) => AgriWasteTypePage(
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
