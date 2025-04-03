import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/data/sales_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgriWasteDetailPage extends StatefulWidget {
  final String saleId;
  final String currentUserId;

  const AgriWasteDetailPage({
    super.key,
    required this.saleId,
    required this.currentUserId,
  });

  @override
  _AgriWasteDetailPageState createState() => _AgriWasteDetailPageState();
}

class _AgriWasteDetailPageState extends State<AgriWasteDetailPage> {
  late Future<Sales?> _agriWasteFuture;
  final SalesService _salesService = SalesService();
  int _selectedImageIndex = -1;

  @override
  void initState() {
    super.initState();
    _agriWasteFuture = _salesService.getSalesDetailsById(widget.saleId);
  }

  Future<void> _addToWishlist(Sales agriWaste) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    String saleJson = jsonEncode({
      'id': agriWaste.documentId,
      'owner': agriWaste.s_ownerName,
      'location': agriWaste.s_location,
      'weight': agriWaste.s_weight,
      'type': agriWaste.s_type,
      'image': agriWaste.s_mainImage,
      'buyerId': widget.currentUserId,
    });

    if (!wishlist.contains(saleJson)) {
      wishlist.add(saleJson);
      await prefs.setStringList('wishlist', wishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Wishlist")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already in Wishlist")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agricultural Waste Details')),
      body: FutureBuilder<Sales?>(
        future: _agriWasteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final agriWaste = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(agriWaste),
                const SizedBox(height: 10),
                _buildDetailFields(agriWaste),
                const SizedBox(height: 16),
                _buildButtons(agriWaste),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(Sales agriWaste) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _selectedImageIndex == -1
              ? agriWaste.s_mainImage
              : agriWaste.s_otherImages[_selectedImageIndex],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailFields(Sales agriWaste) {
    final details = [
      {'label': 'Owner Name:', 'value': agriWaste.s_ownerName},
      {'label': 'Location:', 'value': agriWaste.s_location},
      {'label': 'Weight:', 'value': agriWaste.s_weight},
      {'label': 'Type:', 'value': agriWaste.s_type},
      {'label': 'Address:', 'value': agriWaste.s_address},
      {'label': 'Contact Number:', 'value': agriWaste.s_contactNumber},
      {'label': 'Price:', 'value': agriWaste.s_price},
      {'label': 'Description:', 'value': agriWaste.s_description},
    ];

    return Column(
      children: details.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  item['label']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['value']!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtons(Sales agriWaste) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/chatlist',
                arguments: {
                  'buyerId': widget.currentUserId,
                  'saleId': agriWaste.documentId,
                },
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _addToWishlist(agriWaste),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add To Wish List'),
          ),
        ),
      ],
    );
  }
}
