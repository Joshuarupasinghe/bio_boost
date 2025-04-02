import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/data/sales_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bio_boost/services/auth_service.dart';

class ActiveSales extends StatefulWidget {
  const ActiveSales({super.key});

  @override
  State<ActiveSales> createState() => _ActiveSalesState();
}

class _ActiveSalesState extends State<ActiveSales> {
  final SalesService _salesService = SalesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  List<Sales> _activeSales = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? role = await _authService.getUserRole(user.uid);
      setState(() {
        _currentUserId = user.uid;
        _userRole = role;
      });
      if (role == 'Seller') {
        _fetchSellerSales();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You do not have permission to view this page.';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user is signed in';
      });
    }
  }

  Future<void> _fetchSellerSales() async {
    if (_currentUserId == null) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final salesList = await _salesService.getSellerSales(_currentUserId!);
      setState(() {
        _activeSales = salesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sales: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'My Active Sales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        actions:
            _userRole == 'Seller'
                ? [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _navigateToAddSale(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchSellerSales,
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              )
              : _activeSales.isEmpty
              ? const Center(
                child: Text(
                  'You have no active sales',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchSellerSales,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeSales.length,
                  itemBuilder: (context, index) {
                    final sale = _activeSales[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.grey[850],
                      child: ListTile(
                        leading:
                            sale.s_mainImage.startsWith('http')
                                ? Image.network(
                                  sale.s_mainImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'images/bioWasteMain.jpg',
                                  width: 80,
                                  height: 80,
                                ),
                        title: Text(
                          'Type: ${sale.s_type}',
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location: ${sale.s_location}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Weight: ${sale.s_weight}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Price: ${sale.s_price}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Status: Active',
                              style: TextStyle(color: Colors.green[300]),
                            ),
                          ],
                        ),
                        trailing:
                            _userRole == 'Seller'
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed:
                                          () => _navigateToEditSale(
                                            context,
                                            sale,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed:
                                          () => _showDeleteConfirmation(
                                            context,
                                            sale,
                                          ),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
    );
  }

  void _navigateToAddSale(BuildContext context) {
    // TODO: Implement navigation to add sale page
  }

  void _navigateToEditSale(BuildContext context, Sales sale) {
    // TODO: Implement navigation to edit sale page
  }

  void _showDeleteConfirmation(BuildContext context, Sales sale) {
    // TODO: Implement delete confirmation
  }
}
