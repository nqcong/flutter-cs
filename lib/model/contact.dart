// lib/models/contact.dart
import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String avatarColor;
  final String? phone;
  final bool isFavorite;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.avatarColor,
    this.phone,
    this.isFavorite = false,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? avatarColor,
    String? phone,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Proper JSON serialization
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatarColor': avatarColor,
      'phone': phone,
      'isFavorite': isFavorite,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      avatarColor: json['avatarColor'] as String? ?? 'blue',
      phone: json['phone'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, avatarColor, phone, isFavorite];

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phone: $phone}';
  }
}