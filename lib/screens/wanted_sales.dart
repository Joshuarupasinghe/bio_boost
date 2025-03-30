import 'package:flutter/material.dart';

class WantedPage extends StatefulWidget {
  const WantedPage({super.key});

  @override
  _WantedPageState createState() => _WantedPageState();
}

class _WantedPageState extends State<WantedPage> {
  // Districts and corresponding cities
  final Map<String, List<String>> districtCities = {
    "Colombo": ["Colombo 1", "Colombo 2", "Colombo 3"],
    "Gampaha": ["Negombo", "Gampaha", "Ja-Ela"],
    "Kandy": ["Peradeniya", "Katugastota", "Pilimathalawa"],
    "Galle": ["Unawatuna", "Hikkaduwa", "Ambalangoda"],
    "Jaffna": ["Nallur", "Chavakachcheri", "Point Pedro"],
  };

  // Sample list of wanted waste types
  final List<Map<String, String>> allWantedItems = [
    {
      "title": "Organic Waste",
      "name": "John",
      "district": "Colombo",
      "city": "Colombo 1",
    },
    {
      "title": "Plastic Waste",
      "name": "Sarah",
      "district": "Gampaha",
      "city": "Negombo",
    },
    {
      "title": "Metal Waste",
      "name": "Mike",
      "district": "Kandy",
      "city": "Peradeniya",
    },
    {
      "title": "Agri Waste",
      "name": "Raj",
      "district": "Jaffna",
      "city": "Nallur",
    },
    {
      "title": "Electronic Waste",
      "name": "Ali",
      "district": "Galle",
      "city": "Unawatuna",
    },
  ];

  // Filtered waste types
  List<Map<String, String>> filteredItems = [];

  // Selected district and city
  String? selectedDistrict;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(allWantedItems); // Show all items initially
  }

  void filterItems() {
    setState(() {
      filteredItems =
          allWantedItems.where((item) {
            return (selectedDistrict == null ||
                    item["district"] == selectedDistrict) &&
                (selectedCity == null || item["city"] == selectedCity);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          "Wanted",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // District Dropdown
                  _buildDistrictDropdown(),
                  const SizedBox(height: 5),

                  // City Dropdown
                  _buildCityDropdown(),
                  const SizedBox(height: 5),

                  // Filter Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: filterItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Filter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Divider(color: Colors.white, thickness: 2),
            const SizedBox(height: 10),

            // Filtered Waste Types List
            Expanded(
              child:
                  filteredItems.isNotEmpty
                      ? ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildWantedCard(filteredItems[index]);
                        },
                      )
                      : const Center(
                        child: Text(
                          "No waste types found",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown for selecting district
  Widget _buildDistrictDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "District",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[800],
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(color: Colors.white),
            value: selectedDistrict,
            hint: const Text(
              "Select District",
              style: TextStyle(color: Colors.white),
            ),
            items:
                districtCities.keys.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
                selectedCity =
                    null; // Reset city selection when district changes
              });
            },
          ),
        ),
      ],
    );
  }

  // Dropdown for selecting city
  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("City", style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[800],
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(color: Colors.white),
            value: selectedCity,
            hint: const Text(
              "Select City",
              style: TextStyle(color: Colors.white),
            ),
            items:
                selectedDistrict != null
                    ? districtCities[selectedDistrict]!.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList()
                    : [],
            onChanged: (value) {
              setState(() {
                selectedCity = value;
              });
            },
          ),
        ),
      ],
    );
  }

  // Waste Type Card
  Widget _buildWantedCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Placeholder
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),

          // Waste Type Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Requested by: ${item["name"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Location: ${item["district"]}, ${item["city"]}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Call Icon
          const Icon(Icons.call, color: Colors.white),
        ],
      ),
    );
  }
}
