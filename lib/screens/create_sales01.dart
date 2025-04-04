import 'package:bio_boost/screens/create_sales02.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateSales01 extends StatefulWidget {
  const CreateSales01({super.key});

  @override
  State<CreateSales01> createState() => _CreateSales01State();
}

class _CreateSales01State extends State<CreateSales01> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? role = await _authService.getUserRole(user.uid);
        setState(() {
          _isLoading = false;
        });

        if (role != 'Seller') {
          setState(() {
            _errorMessage = 'Only sellers can create sales posts.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please sign in to create sales posts.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error verifying user permissions.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.grey[850],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> wasteTypes = [
      {'name': 'Paddy Husk & Straw', 'icon': Icons.grass},
      {'name': 'Coconut Husks and Shells', 'icon': Icons.nature},
      {'name': 'Tea Waste', 'icon': Icons.emoji_food_beverage},
      {'name': 'Rubber Wood and Latex Waste', 'icon': Icons.park},
      {'name': 'Fruit and Vegetable Waste', 'icon': Icons.food_bank},
      {'name': 'Sugarcane Bagasse', 'icon': Icons.agriculture},
      {'name': 'Oil Cake and Residues', 'icon': Icons.cake},
      {'name': 'Maize and Other Cereal Residues', 'icon': Icons.grain},
      {'name': 'Banana Plant Waste', 'icon': Icons.eco},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Select Waste Type',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
          ),
          itemCount: wasteTypes.length,
          itemBuilder: (context, index) {
            final item = wasteTypes[index];
            return Card(
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateSales02(
                            wasteType: item['name'], // Changed to wasteType
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 40, color: Colors.teal),
                      const SizedBox(height: 10),
                      Text(
                        item['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
