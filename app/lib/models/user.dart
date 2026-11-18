import '../utils/format.dart';

class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.businessName,
    this.createdAt,
  });

  final int id;
  final String fullName;
  final String email;
  final String? businessName;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['id'] as num).toInt(),
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        businessName: json['business_name'] as String?,
        createdAt: json['created_at'] == null ? null : parseApiDate(json['created_at'] as String),
      );

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  String get initial => fullName.trim().isEmpty ? '?' : fullName.trim()[0].toUpperCase();
}
