import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/seller_auth_service.dart';

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
  final SellerAuthService _sellerAuthService = SellerAuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Track the status messages
  String authStatus = "";
  String sellerDataStatus = "";

  /// **Register Seller**
  void _registerSeller() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

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

    // Show initial message
    setState(() {
      authStatus = "Attempting sign-up for: $username";
    });

    await Future.delayed(Duration(milliseconds: 500)); // Allow UI update

    // Expecting a `User?` instead of a `String?`
    User? user = await _sellerAuthService.signUpSeller(username, password);

    if (user != null) {
      // Show success message and delay before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller registered successfully!')),
      );

      await Future.delayed(Duration(seconds: 2)); // Delay before navigating
      Navigator.pushReplacementNamed(context, '/profile_company');
    } else {
      // If sign-up fails, update status
      setState(() {
        authStatus = "❌ Registration failed. Try again!";
      });
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
          // Wrapped in SingleChildScrollView
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

                // Box containing the form
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
                          setState(() {
                            _isPasswordVisible = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildPasswordField(
                        "Confirm Password",
                        _confirmPasswordController,
                        _isConfirmPasswordVisible,
                        (value) {
                          setState(() {
                            _isConfirmPasswordVisible = value;
                          });
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
                      // Display the status messages
                      if (authStatus.isNotEmpty)
                        Text(
                          authStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      if (sellerDataStatus.isNotEmpty)
                        Text(
                          sellerDataStatus,
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

  // Helper method to build a password field with visibility toggle
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
          onPressed: () {
            onVisibilityChanged(!isPasswordVisible);
          },
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
