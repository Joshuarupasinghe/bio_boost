import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  _BecomeSellerPageState createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String authStatus = "";

  Future<void> _registerSeller() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required!')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }

    if (user == null) {
      setState(() => authStatus = "❌ User not authenticated!");
      return;
    }

    try {
      // Update Firestore to add 'seller' role
      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDoc.update({
        'roles': FieldValue.arrayUnion(['seller']), // Add 'seller' role
        'username': username, // Set seller username
      });

      setState(() => authStatus = "✅ You are now a seller!");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You are now a seller!')));

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/profile_company');
    } catch (e) {
      setState(() => authStatus = "❌ Registration failed: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Try again!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(backgroundColor: Colors.grey[850]),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Become a Seller",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create a new username to become a seller",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField("Username", _usernameController),
                      const SizedBox(height: 15),
                      _buildPasswordField(
                        "Password",
                        _passwordController,
                        _isPasswordVisible,
                        (value) {
                          setState(() => _isPasswordVisible = value);
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildPasswordField(
                        "Confirm Password",
                        _confirmPasswordController,
                        _isConfirmPasswordVisible,
                        (value) {
                          setState(() => _isConfirmPasswordVisible = value);
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerSeller,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Become a Seller",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (authStatus.isNotEmpty)
                        Text(
                          authStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isPasswordVisible,
    Function(bool) onVisibilityChanged,
  ) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () => onVisibilityChanged(!isPasswordVisible),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
