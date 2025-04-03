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

  Future<void> _deleteSale(String documentId) async {
    bool success = await _salesService.deleteSale(documentId);
    if (success) {
      setState(() {
        _activeSales.removeWhere((sale) => sale.documentId == documentId);
      });
    }
  }

  void _changeSaleStatus(String documentId, String newStatus) async {
    bool success = await _salesService.updateSale(documentId, {
      's_status': newStatus,
    });
    if (success) {
      _fetchSellerSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Active Sales'),
        backgroundColor: Colors.grey[850],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
              )
              : _activeSales.isEmpty
              ? const Center(
                child: Text(
                  'You have no active sales',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activeSales.length,
                itemBuilder: (context, index) {
                  final sale = _activeSales[index];
                  return Card(
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
                        style: TextStyle(
                          color: Colors.white, // Darker teal
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location: ${sale.s_location}',
                            style: const TextStyle(color: Colors.teal),
                          ),
                          Text(
                            'Weight: ${sale.s_weight}',
                            style: const TextStyle(color: Colors.teal),
                          ),
                          Text(
                            'Price: ${sale.s_price}',
                            style: const TextStyle(color: Colors.teal),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${sale.s_status}',
                                style: TextStyle(
                                  color:
                                      sale.s_status == 'Active'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  sale.s_status == 'Active'
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: Colors.amberAccent,
                                  size: 30,
                                ),
                                onPressed:
                                    () => _changeSaleStatus(
                                      sale.documentId,
                                      sale.s_status == 'Active'
                                          ? 'Inactive'
                                          : 'Active',
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteSale(sale.documentId),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
