import 'package:bio_boost/screens/benefits.dart';
import 'package:bio_boost/screens/create_sales01.dart';
import 'package:bio_boost/screens/wanted_sales.dart';
import 'package:flutter/material.dart';
import 'package:bio_boost/services/service_request_service.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  List<Map<String, dynamic>> _serviceRequests = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  final List<Map<String, String>> categories = [
    {'title': 'Paddy Husk & Straw', 'url': 'images/Paddy Husk & Straw.jpg'},
    {
      'title': 'Coconut Husks & Shells',
      'url': 'images/Coconut Husks & Shells.jpg',
    },
    {'title': 'Tea Waste', 'url': 'images/Tea Waste.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchServiceRequests();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? role = await _authService.getUserRole(user.uid);
        setState(() {
          _userRole = role;
          _isLoading = false;
        });

        if (role != 'Seller') {
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

  Future<void> _fetchServiceRequests() async {
    try {
      final requests = await _serviceRequestService.getServiceRequests();
      setState(() {
        _serviceRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load service requests: $e')),
      );
    }
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

    if (_userRole != 'Seller') {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20.0),
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                            builder: (context) => CreateSales01(),
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
              ),
              _buildDivider(),
              _buildRecentWantedSales(),
              _buildSeeMoreButton(),
              _buildDivider(),
              _buildBenefitsHeader(),
              _buildBenefitsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text("Create Your Own Sales Post", style: TextStyle(fontSize: 20)),
          ],
        ),
        Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateSales01()),
                );
              },
              child: Text(
                "See All...",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
          child: Container(height: 2, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildRecentWantedSales() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text("Recent Wanted Sales", style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 20),
        Column(
          children:
              _serviceRequests
                  .take(3)
                  .map((data) => _buildWantedCard(data))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSeeMoreButton() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WantedPage()),
              );
            },
            child: Text(
              "See More...",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Benefits of recycling", style: TextStyle(fontSize: 20.0)),
            Text("and composting", style: TextStyle(fontSize: 20.0)),
          ],
        ),
        Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BenefitsPage()),
                );
              },
              child: Text(
                "See All...",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildBenefitCard(
          title: "Resource Conservation",
          description:
              "Recycling reduces the need for raw materials and preserves natural resources such as trees, water, and minerals.",
        ),
        const SizedBox(height: 10),
        _buildBenefitCard(
          title: "Energy Savings",
          description:
              "Recycling uses less energy than producing new products, lowering greenhouse gas emissions.",
        ),
      ],
    );
  }

  Widget _buildWantedCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                "Needs ${data['serviceType'] ?? '(Agri waste type)'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${data['name'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Location: ${data['location'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Weight: ${data['weight'] ?? 'N/A'} kg",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      data['description'] ?? 'No description provided',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 180, 175, 175),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.call, color: Colors.white, size: 30),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required String title,
    required String description,
  }) {
    return BenefitTile(title: title, description: description);
  }
}

class BenefitTile extends StatefulWidget {
  final String title;
  final String description;

  const BenefitTile({
    required this.title,
    required this.description,
    super.key,
  });

  @override
  State<BenefitTile> createState() => _BenefitTileState();
}

class _BenefitTileState extends State<BenefitTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isExpanded ? Colors.teal : Colors.white,
              fontSize: 16,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[700]!,
                    Colors.grey[800]!,
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.33, 0.66, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
