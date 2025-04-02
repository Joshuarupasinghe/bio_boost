import 'package:bio_boost/screens/become_seller.dart';
import 'package:bio_boost/screens/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'sign_in.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key}); // Add this line
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "ishara2003",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCompanyProfilePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WishlistPage()),
                      );
                    },
                    child: Text("My Wishlist"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ishara Sandaruwan", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.location_pin),
                          SizedBox(width: 5),
                          Text(
                            "Pitipana, Colombo",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.call),
                          SizedBox(width: 5),
                          Text("077 xxxxxxx", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.email),
                          SizedBox(width: 5),
                          Text(
                            "ishara2003@gmail.com",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BecomeSellerPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text("Become a Seller"),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "My Wants",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2, // Replace with dynamic count
                itemBuilder: (context, index) {
                  return _buildWantedCard(
                    agriWasteType: "Agri Waste Type $index",
                    name: "Name $index",
                    location: "Location $index",
                    weight: "${index * 10}kg",
                    description: "Description for item $index",
                  );
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                    (route) => false, // Remove all routes
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWantedCard({
    required String agriWasteType,
    required String name,
    required String location,
    required String weight,
    required String description,
  }) {
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
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Needs $agriWasteType",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text("Name: $name", style: TextStyle(color: Colors.white)),
                Text(
                  "Location: $location",
                  style: TextStyle(color: Colors.white),
                ),
                Text("Weight: $weight", style: TextStyle(color: Colors.white)),
                Text(description, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // Call Icon
          const Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }
}

class EditCompanyProfilePage extends StatelessWidget {
  final List<String> locations = ['Colombo', 'Pitipana'];

  const EditCompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    String? selectedCity = locations.first;
    String? selectedArea = locations.last;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[400],
                child: Icon(Icons.edit, size: 30),
              ),
            ),
            SizedBox(height: 10),
            // User Name
            Center(
              child: Text(
                'ishara2003',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // Name Fields
            Text('Name'),
            TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'Ishara',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Sandaruwan',
              ),
            ),
            SizedBox(height: 10),
            // Location Dropdowns
            Text('Location'),
            DropdownButton<String>(
              value: selectedCity,
              items:
                  locations
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ),
                      )
                      .toList(),
              onChanged: (String? value) {
                selectedCity = value;
              },
            ),
            DropdownButton<String>(
              value: selectedArea,
              items:
                  locations
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ),
                      )
                      .toList(),
              onChanged: (String? value) {
                selectedArea = value;
              },
            ),
            SizedBox(height: 10),
            // Contact Fields
            TextField(
              decoration: InputDecoration(
                labelText: 'Contact Number',
                hintText: '077 xxxxxxx',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Add New Email (Optional)',
              ),
            ),
            SizedBox(height: 20),
            // Update Button
            ElevatedButton(
              onPressed: () {
                // Add functionality to update profile
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
