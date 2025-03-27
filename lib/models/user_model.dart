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
    };
  }

// Convert Map to UserModel (for Firestore retrieving)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      companyName: map['companyName'],
      phone: map['phone'],
      address: map['address'],
      district: map['district'],
      city: map['city'],
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
    );
  }
}
