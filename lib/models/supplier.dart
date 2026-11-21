class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.productCount,
  });

  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final int productCount;

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      );
}
