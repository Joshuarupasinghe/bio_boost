import 'package:flutter/material.dart';

class CreateSales02 extends StatefulWidget {
  final String selectedCategory;

  const CreateSales02({super.key, required this.selectedCategory});

  @override
  _CreateSales02State createState() => _CreateSales02State();
}


class _CreateSales02State extends State<CreateSales02> {
  String? selectedCategory;

  final List<String> wasteTypes = [
    'Paddy Husk & Straw',
    'Coconut Husks and Shells',
    'Tea Waste',
    'Rubber Wood and Latex Waste',
    'Fruit and Vegetable Waste',
    'Sugarcane Bagasse',
    'Oil Cake and Residues',
    'Maize and Other Cereal Residues',
    'Banana Plant Waste',
    'Other',
  ];

  @override
void initState() {
  super.initState();
  selectedCategory = widget.selectedCategory;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 40, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search Sales',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {},
              ),
            ),
          ],
        ),
        toolbarHeight: 60,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Product Name', 'Enter your product name'),
            _buildDropdownField('Category', wasteTypes),
            _buildDetailField('Price', 'Enter price'),
            _buildDetailField('Quantity', 'Enter quantity'),
            _buildDetailField('Description', 'Enter product description'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CREATE SALE', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[800],
                value: selectedCategory,
                hint: const Text('Select category', style: TextStyle(color: Colors.grey)),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}