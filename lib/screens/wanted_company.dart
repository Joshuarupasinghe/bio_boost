import 'package:bio_boost/screens/Add_MyServices.dart';
import 'package:bio_boost/services/service_request_service.dart';
import 'package:flutter/material.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WantedCompanyPage extends StatefulWidget {
  const WantedCompanyPage({super.key});

  @override
  _WantedCompanyPageState createState() => _WantedCompanyPageState();
}

class _WantedCompanyPageState extends State<WantedCompanyPage> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  List<Map<String, dynamic>> _serviceRequests = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  // District and City filter data
  final Map<String, List<String>> districtCities = {
    "Colombo": [
      "Colombo",
      "Dehiwala-Mount Lavinia",
      "Sri Jayawardenepura Kotte",
    ],
    "Gampaha": ["Negombo", "Gampaha", "Ja-Ela"],
    "Kandy": ["Kandy", "Katugastota", "Peradeniya"],
    "Galle": ["Elpitiya"],
  };

  String? selectedDistrict;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchServiceRequests();
    });
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? role = await _authService.getUserRole(user.uid);
        setState(() {
          _userRole = role;
          _isLoading = false;
        });

        if (role != 'Buyer') {
          setState(() {
            _errorMessage = 'You do not have permission to access this page.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user is signed in.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to check user role: $e';
      });
    }
  }

  Future<void> _fetchServiceRequests() async {
    try {
      final requests = await _serviceRequestService.getServiceRequests();
      setState(() {
        _serviceRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load service requests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text("Wanted", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userRole != 'Buyer') {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            "Access Denied",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "You do not have permission to access this page.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMyServicesPage()),
          );

          if (result == true) {
            _fetchServiceRequests(); // Refresh the list after adding a service
          }
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildFilters(),
                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredServiceRequests().length,
                        itemBuilder: (context, index) {
                          return _buildWantedCard(
                            _filteredServiceRequests()[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Filter Section
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
          const SizedBox(height: 10),
          _buildCityDropdown(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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
          selectedCity = null;
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
                    (city) => DropdownMenuItem(value: city, child: Text(city)),
                  )
                  .toList()
              : [],
      onChanged: (value) => setState(() => selectedCity = value),
    );
  }

  List<Map<String, dynamic>> _filteredServiceRequests() {
    return _serviceRequests.where((request) {
      final location = request['location'] ?? '';
      final city = request['city'] ?? '';
      return (selectedDistrict == null || location == selectedDistrict) &&
          (selectedCity == null || city == selectedCity);
    }).toList();
  }
}

Widget _buildWantedCard(Map<String, dynamic> data) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              "Needs ${data['serviceType'] ?? '(Agri waste type)'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
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
                    "Name: ${data['name'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Location: ${data['location'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Weight: ${data['weight'] ?? 'N/A'} kg",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    data['description'] ?? 'No description provided',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 180, 175, 175),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [const Icon(Icons.call, color: Colors.white, size: 30)],
            ),
          ],
        ),
      ],
    ),
  );
}
