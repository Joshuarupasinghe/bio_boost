class UserProfile {
  String firstName;
  String lastName;
  String contactNumber;
  String? email;
  String district;
  String city;
  String? profileImagePath;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    this.email,
    required this.district,
    required this.city,
    this.profileImagePath,
  });

  // Convert UserProfile object to a map for storage (e.g., Firebase or local storage)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'contactNumber': contactNumber,
      'email': email,
      'district': district,
      'city': city,
      'profileImagePath': profileImagePath,
    };
  }

  // Create a UserProfile object from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'],
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      profileImagePath: map['profileImagePath'],
    );
  }
}
