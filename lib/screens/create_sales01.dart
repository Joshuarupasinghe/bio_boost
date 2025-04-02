import 'package:bio_boost/screens/create_sales02.dart';
import 'package:flutter/material.dart';

class CreateSales01 extends StatelessWidget {
  const CreateSales01({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Create Your Sales Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: wasteTypes.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateSales02(selectedCategory: wasteTypes[index]),
    ),
  );
},


              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 30, color: Colors.white70),
                  const SizedBox(height: 8),
                  Text(
                    wasteTypes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CreateSalesPage extends StatefulWidget {
  final String selectedCategory;
  const CreateSalesPage({super.key, required this.selectedCategory});

  @override
  _CreateSalesPageState createState() => _CreateSalesPageState();
}

class _CreateSalesPageState extends State<CreateSalesPage> {
  late String selectedCategory;
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
        title: const Text('Create Sale'),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Category', wasteTypes),
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

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
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
                  selectedCategory = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
