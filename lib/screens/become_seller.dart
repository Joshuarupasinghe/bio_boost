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
  bool isLoading = false;
  String authStatus = "";
  bool isAlreadySeller = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySeller();
  }

  Future<void> _checkIfAlreadySeller() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var sellerDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (sellerDoc.exists &&
          sellerDoc.data()?['roles']?.contains('seller') == true) {
        setState(() {
          isAlreadySeller = true;
          authStatus = "✅ You are already a registered seller!";
        });
      }
    }
  }

  Future<void> _registerSeller() async {
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

    setState(() => isLoading = true);

    try {
      // Check if the username already exists as a seller
      var existingUser =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .where('roles', arrayContains: 'seller')
              .get();

      if (existingUser.docs.isNotEmpty) {
        setState(() {
          authStatus = "❌ You are already registered as a seller!";
          isAlreadySeller = true;
        });
        return;
      }

      // Register new seller in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: "$username@sellers.com", // Fake email for authentication
            password: password,
          );

      User? user = userCredential.user;
      if (user != null) {
        // Store seller details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'roles': ['seller'],
          'email': user.email,
          'createdAt': Timestamp.now(),
        });

        setState(() {
          authStatus = "✅ Registration successful! Redirecting to Home...";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered! Redirecting...'),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        // Navigate to homepage
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => authStatus = "❌ Registration failed: ${e.toString()}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
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
                      if (isAlreadySeller)
                        Text(
                          authStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (!isAlreadySeller) ...[
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
                            onPressed: isLoading ? null : _registerSeller,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      "Become a Seller",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (authStatus.isNotEmpty && !isAlreadySeller)
                        Text(
                          authStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
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