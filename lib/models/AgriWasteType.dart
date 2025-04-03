class AgriWaste {
  final String id;
  final String owner;
  final String location;
  final String wasteType;
  final double weight;
  final double price;
  final double rating;
  final String imageUrl;
  final String contactNumber;

  AgriWaste({
    required this.id,
    required this.owner,
    required this.location,
    required this.wasteType,
    required this.weight,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.contactNumber,
  });

  factory AgriWaste.fromJson(Map<String, dynamic> json) {
    return AgriWaste(
      id: json['id'],
      owner: json['owner'],
      location: json['location'],
      wasteType: json['wasteType'],
      weight: json['weight'].toDouble(),
      price: json['price'].toDouble(),
      rating: json['rating'].toDouble(),
      imageUrl: json['imageUrl'],
      contactNumber: json['contactNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'location': location,
      'wasteType': wasteType,
      'weight': weight,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'contactNumber': contactNumber,
    };
  }
}
