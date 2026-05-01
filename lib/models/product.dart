class Product {
  final dynamic id;
  final String? name;
  final String? category;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  Product({
    required this.id,
    this.name,
    this.category,
    required this.details,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // If 'details' is null or not a Map, default to empty map
    Map<String, dynamic> parsedDetails = {};
    if (json['details'] != null && json['details'] is Map) {
      parsedDetails = Map<String, dynamic>.from(json['details']);
    }

    return Product(
      id: json['id'],
      name: json['name']?.toString(),
      category: json['category']?.toString(),
      details: parsedDetails,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
