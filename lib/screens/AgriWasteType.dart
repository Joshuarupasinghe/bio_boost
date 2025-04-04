import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/services/sales_service.dart';
import 'package:bio_boost/screens/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesListScreen extends StatefulWidget {
  final String? selectedCategory;

  const SalesListScreen({super.key, this.selectedCategory});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final SalesService _salesService = SalesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Sales> _salesList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchSales();
  }

  Future<void> _loadCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('currentUserId');
      });
    }
  }

  Future<void> _fetchSales() async {
    try {
      final sales = await _salesService.getSalesListings().first;
      setState(() {
        _salesList = sales
            .where((sale) => sale.isActive && 
                (widget.selectedCategory != null 
                    ? sale.type == widget.selectedCategory 
                    : true))
            .toList();
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
        title: Text(
          widget.selectedCategory ?? 'All Listings',
          style: const TextStyle(color: Colors.white),
        ),
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
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (_salesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              widget.selectedCategory != null
                  ? 'No ${widget.selectedCategory} listings available'
                  : 'No listings available',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _salesList.length,
      itemBuilder: (context, index) {
        final sale = _salesList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.grey[850],
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: sale.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sale.imageUrls.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported),
                  ),
            title: Text(
              sale.type,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sale.weight} kg',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '\$${sale.price}',
                  style: const TextStyle(color: Colors.teal),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
            ),
            onTap: () {
              if (_currentUserId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgriWasteDetailPage(
                      saleId: sale.id,
                      currentUserId: _currentUserId!,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}