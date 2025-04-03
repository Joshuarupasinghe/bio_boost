import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/active_sales_service.dart';

class ActiveSales extends StatefulWidget {
  const ActiveSales({super.key});

  @override
  State<ActiveSales> createState() => _ActiveSalesState();
}

class _ActiveSalesState extends State<ActiveSales> {
  final ActiveSalesService _salesService = ActiveSalesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Sales> _activeSales = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        await _fetchAllSales();
      } else {
        setState(() {
          _errorMessage = 'Not signed in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllSales() async {
    try {
      List<Sales> sales = await _salesService.getAllSales();
      setState(() {
        _activeSales = sales;
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
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this sale?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await _salesService.deleteSale(documentId);
    
    if (success) {
      setState(() {
        _activeSales.removeWhere((sale) => sale.documentId == documentId);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale deleted successfully')),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete sale')),
      );
    }
  }

  Future<void> _toggleSaleStatus(String documentId, String currentStatus) async {
    String newStatus = currentStatus == 'Active' ? 'Inactive' : 'Active';
    
    setState(() {
      _isLoading = true;
    });
    
    bool success = await _salesService.updateSaleStatus(documentId, newStatus);
    
    if (success) {
      setState(() {
        // Update the local list status
        final index = _activeSales.indexWhere((s) => s.documentId == documentId);
        if (index != -1) {
          final sale = _activeSales[index];
          _activeSales[index] = Sales(
            documentId: sale.documentId,
            s_ownerName: sale.s_ownerName,
            s_location: sale.s_location,
            s_weight: sale.s_weight,
            s_type: sale.s_type,
            s_address: sale.s_address,
            s_contactNumber: sale.s_contactNumber,
            s_price: sale.s_price,
            s_description: sale.s_description,
            s_mainImage: sale.s_mainImage,
            s_otherImages: sale.s_otherImages,
            uid: sale.uid,
            s_status: newStatus,
          );
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update sale status')),
      );
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
      body: _isLoading
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
                  : RefreshIndicator(
                      onRefresh: _fetchAllSales,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activeSales.length,
                        itemBuilder: (context, index) {
                          final sale = _activeSales[index];
                          return Card(
                            color: Colors.grey[850],
                            margin: EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading:
                                  sale.s_mainImage.startsWith('http')
                                      ? Image.network(
                                          sale.s_mainImage,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'images/bioWasteMain.jpg',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'images/bioWasteMain.jpg',
                                          width: 80,
                                          height: 80,
                                        ),
                              title: Text(
                                'Type: ${sale.s_type}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text(
                                    'Weight: ${sale.s_weight}',
                                    style: const TextStyle(color: Colors.teal),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Price: Rs. ${sale.s_price}',
                                    style: const TextStyle(color: Colors.teal),
                                  ),
                                  SizedBox(height: 12),
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
                                      Switch(
                                        value: sale.s_status == 'Active',
                                        activeColor: Colors.green,
                                        onChanged: (value) => _toggleSaleStatus(
                                          sale.documentId,
                                          sale.s_status,
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
                    ),
    );
  }
}
