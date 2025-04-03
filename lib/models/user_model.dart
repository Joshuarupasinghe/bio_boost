class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String phone;
  final String address;
  final String district;
  final String city;
  final List<String> roles; // Now supports multiple roles (buyer & seller)

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    required this.phone,
    required this.address,
    required this.district,
    required this.city,
    required this.roles,
  });

  // Convert UserModel to Map (for Firestore storing)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'companyName': companyName,
      'phone': phone,
      'address': address,
      'district': district,
      'city': city,
      'roles': roles, // List of roles
    };
  }

  // Convert Map to UserModel (for Firestore retrieving)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Safely extract values with fallback defaults
    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      companyName: map['companyName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      roles: List<String>.from(map['roles'] ?? ['buyer']), // Default role is 'buyer'
    );
  }

  // Create a new instance of UserModel with updated values
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? companyName,
    String? phone,
    String? address,
    String? district,
    String? city,
    List<String>? roles,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      district: district ?? this.district,
      city: city ?? this.city,
      roles: roles ?? this.roles,
    );
  }

  // Method to add a new role
  UserModel addRole(String newRole) {
    if (!roles.contains(newRole)) {
      return copyWith(roles: [...roles, newRole]);
    }
    return this;
  }
}
