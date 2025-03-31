import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/service_request_service.dart'; // Ensure this service handles Firebase fetching

class WantedPage extends StatefulWidget {
  const WantedPage({super.key});

  @override
  _WantedPageState createState() => _WantedPageState();
}

class _WantedPageState extends State<WantedPage> {
  // Example of Sri Lankan districts and their cities
  final Map<String, List<String>> districtCities = {
    "Colombo": [
      "Colombo",
      "Dehiwala-Mount Lavinia",
      "Sri Jayawardenepura Kotte",
      "Moratuwa",
      "Kolonnawa",
    ],
    "Gampaha": ["Negombo", "Gampaha", "Ja-Ela", "Minuwangoda", "Kaduwela"],
    "Kalutara": ["Kalutara", "Panadura", "Horana", "Matugama", "Beruwala"],
    "Kandy": ["Kandy", "Katugastota", "Peradeniya", "Gampola", "Kundasale"],
    "Matale": ["Matale", "Dambulla", "Sigiriya", "Rattota", "Galewela"],
    "Nuwara Eliya": [
      "Nuwara Eliya",
      "Hatton",
      "Talawakelle",
      "Ginigathena",
      "Kandapola",
    ],
    "Galle": ["Galle", "Ambalangoda", "Hikkaduwa", "Elpitiya", "Baddegama"],
    "Hambantota": [
      "Hambantota",
      "Tangalle",
      "Ambalantota",
      "Tissamaharama",
      "Beliatta",
    ],
    "Jaffna": ["Jaffna", "Chavakachcheri", "Nallur", "Point Pedro", "Kopay"],
    "Kilinochchi": ["Kilinochchi", "Paranthan", "Pallai", "Iranamadu"],
    "Mannar": ["Mannar", "Pesalai", "Madhu", "Nanattan"],
    "Mullaitivu": ["Mullaitivu", "Puthukkudiyiruppu", "Oddusuddan"],
    "Vavuniya": ["Vavuniya", "Cheddikulam", "Nedunkeni"],
    "Trincomalee": ["Trincomalee", "Kantale", "Kinniya", "Muttur"],
    "Batticaloa": ["Batticaloa", "Kalkudah", "Valaichchenai", "Eravur"],
    "Ampara": ["Ampara", "Kalmunai", "Akkaraipattu", "Pottuvil"],
    "Kurunegala": ["Kurunegala", "Kuliyapitiya", "Narammala", "Polgahawela"],
    "Puttalam": ["Puttalam", "Chilaw", "Dankotuwa", "Wennappuwa"],
    "Anuradhapura": ["Anuradhapura", "Mihintale", "Kekirawa", "Medawachchiya"],
    "Polonnaruwa": ["Polonnaruwa", "Hingurakgoda", "Kaduruwela", "Bakamuna"],
    "Badulla": ["Badulla", "Bandarawela", "Haputale", "Welimada"],
    "Monaragala": ["Monaragala", "Wellawaya", "Bibile", "Buttala"],
    "Ratnapura": ["Ratnapura", "Balangoda", "Embilipitiya", "Pelmadulla"],
    "Kegalle": ["Kegalle", "Mawanella", "Rambukkana", "Warakapola"],
    // Add other districts and cities here as per your need
  };

  String? selectedDistrict;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          "Wanted Sales",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 10),
            const Divider(color: Colors.white, thickness: 2),
            Expanded(
              child: StreamBuilder(
                stream: ServiceRequestService().fetchServiceRequests(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No wanted services found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  final services =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return (selectedDistrict == null ||
                                data['location'] == selectedDistrict) &&
                            (selectedCity == null ||
                                data['city'] == selectedCity);
                      }).toList();

                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service =
                          services[index].data() as Map<String, dynamic>;
                      return _buildWantedCard(service);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDistrictDropdown(),
          const SizedBox(height: 5),
          _buildCityDropdown(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to right
            children: [
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white, // White text color
                ),
                child: const Text("Filter"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[800],
      value: selectedDistrict,
      hint: const Text(
        "Select District",
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items:
          districtCities.keys
              .map(
                (district) =>
                    DropdownMenuItem(value: district, child: Text(district)),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          selectedDistrict = value;
          selectedCity = null; // Reset city when district changes
        });
      },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[800],
      value: selectedCity,
      hint: const Text("Select City", style: TextStyle(color: Colors.white)),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items:
          selectedDistrict != null
              ? districtCities[selectedDistrict]!
                  .map(
                    (city) => DropdownMenuItem(
                      value: city,
                      child: Text(city, style: TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList()
              : [],
      onChanged: (value) => setState(() => selectedCity = value),
    );
  }

  Widget _buildWantedCard(Map<String, dynamic> service) {
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
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Location: ${service['location']}, ${service['city']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Weight: ${service['weight']} kg",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Description: ${service['description']}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Icon(Icons.call, color: Colors.white),
        ],
      ),
    );
  }

  void _applyFilters() {
    // This method will handle the applying of filters
    setState(() {
      // Trigger re-build after filter selection
    });
  }
}
