class Sales {
  final String id;
  final String ownerName;
  final String location;
  final double weight;
  final String type;
  final String address;
  final String contactNumber;
  final double price;
  final String description;
  final List<String> imageUrls;
  final double? rating;
  final bool isInWishlist;
  final DateTime? postedDate;

  Sales({
    required this.id,
    required this.ownerName,
    required this.location,
    required this.weight,
    required this.type,
    required this.address,
    required this.contactNumber,
    required this.price,
    required this.description,
    required this.imageUrls,
    this.rating,
    this.isInWishlist = false,
    this.postedDate,
  });

  // Factory constructor to create from Map (Firestore)
  factory Sales.fromMap(Map<String, dynamic> map, String id) {
    return Sales(
      id: id,
      ownerName: map['ownerName'] ?? '',
      location: map['location'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      isInWishlist: map['isInWishlist'] ?? false,
      postedDate: map['postedDate']?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'location': location,
      'weight': weight,
      'type': type,
      'address': address,
      'contactNumber': contactNumber,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'rating': rating,
      'isInWishlist': isInWishlist,
      'postedDate': postedDate,
    };
  }

  Sales copyWith({
    String? id,
    String? ownerName,
    String? location,
    double? weight,
    String? type,
    String? address,
    String? contactNumber,
    double? price,
    String? description,
    List<String>? imageUrls,
    double? rating,
    bool? isInWishlist,
  }) {
    return Sales(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      location: location ?? this.location,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      isInWishlist: isInWishlist ?? this.isInWishlist,
    );
  }
}
