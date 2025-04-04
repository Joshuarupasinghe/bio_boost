import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/services/sales_service.dart';
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
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
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
          _errorMessage = 'Only sellers can view active sales';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your sales';
      });
    }
  }

  Future<void> _fetchSellerSales() async {
    if (_currentUserId == null) return;
    
    try {
      final salesList = await _salesService.getSalesListings().first;
      setState(() {
        _activeSales = salesList.where((sale) => 
          sale.ownerId == _currentUserId
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sales: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSale(String saleId) async {
    try {
      await _salesService.deleteSale(saleId);
      setState(() {
        _activeSales.removeWhere((sale) => sale.id == saleId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete sale: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleSaleStatus(Sales sale) async {
    try {
      final updatedSale = sale.copyWith(isActive: !sale.isActive);
      await _salesService.updateSale(updatedSale);
      await _fetchSellerSales();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale status updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Active Sales', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_activeSales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'You have no active sales',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create_sales01'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Create New Sale'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSellerSales,
      backgroundColor: Colors.grey[850],
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeSales.length,
        itemBuilder: (context, index) => _buildSaleCard(_activeSales[index]),
      ),
    );
  }

  Widget _buildSaleCard(Sales sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: sale.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            sale.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${sale.weight} kg • Rs.${sale.price}',
                        style: const TextStyle(color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sale.location,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: sale.isActive ? Colors.green[900] : Colors.red[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sale.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          color: sale.isActive ? Colors.green[100] : Colors.red[100],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        sale.isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: sale.isActive ? Colors.teal : Colors.grey,
                        size: 40,
                      ),
                      onPressed: () => _toggleSaleStatus(sale),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(sale.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String saleId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this sale?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSale(saleId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}