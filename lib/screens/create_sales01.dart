import 'package:bio_boost/screens/create_sales02.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateSales01 extends StatefulWidget {
  const CreateSales01({super.key});

  @override
  _CreateSales01State createState() => _CreateSales01State();
}

class _CreateSales01State extends State<CreateSales01> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? role = await _authService.getUserRole(user.uid);
      setState(() {
        _userRole = role;
        _isLoading = false;
      });

      if (role != 'Seller') {
        setState(() {
          _errorMessage = 'You do not have permission to create sales.';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user is signed in.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.grey[850],
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<String> wasteTypes = [
      'Paddy Husk & Straw',
      'Coconut Husks and Shells',
      'Tea Waste',
      'Rubber Wood and Latex Waste',
      'Fruit and Vegetable Waste',
      'Sugarcane Bagasse',
      'Oil Cake and Residues',
      'Maize and Other Cereal Residues',
      'Banana Plant Waste',
      'Other',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Create Your Sales Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: wasteTypes.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateSales02(selectedCategory: wasteTypes[index]),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 30, color: Colors.white70),
                  const SizedBox(height: 8),
                  Text(
                    wasteTypes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
