class Sales {
  final String id;
  final String ownerId;
  final String ownerName;
  final String location;
  final double weight;
  final String type;
  final String address;
  final String contactNumber;
  final double price;
  final String description;
  final List<String> imageUrls;
  final bool isActive;  // Add this field
  final bool isInWishlist;
  final double? rating;
  final DateTime? postedDate;

  Sales({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.location,
    required this.weight,
    required this.type,
    required this.address,
    required this.contactNumber,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.isActive,  // Add to constructor
    this.isInWishlist = false,
    this.rating,
    this.postedDate,
  });

  factory Sales.fromMap(Map<String, dynamic> map, String id) {
    return Sales(
      id: id,
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      location: map['location'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isActive: map['isActive'] ?? true,  // Default to true if not specified
      isInWishlist: map['isInWishlist'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      postedDate: map['postedDate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'location': location,
      'weight': weight,
      'type': type,
      'address': address,
      'contactNumber': contactNumber,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'isActive': isActive,  // Include in toMap
      'isInWishlist': isInWishlist,
      'rating': rating,
      'postedDate': postedDate,
    };
  }

  Sales copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? location,
    double? weight,
    String? type,
    String? address,
    String? contactNumber,
    double? price,
    String? description,
    List<String>? imageUrls,
    bool? isActive,
    bool? isInWishlist,
    double? rating,
    DateTime? postedDate,
  }) {
    return Sales(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      location: location ?? this.location,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      rating: rating ?? this.rating,
      postedDate: postedDate ?? this.postedDate,
    );
  }
}