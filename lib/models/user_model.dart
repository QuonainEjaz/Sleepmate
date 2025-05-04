import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final String gender;
  final double weight;
  final double height;
  final List<String> healthConditions;
  final bool isAdmin;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    required this.height,
    required this.healthConditions,
    this.isAdmin = false,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      healthConditions: List<String>.from(data['healthConditions'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'weight': weight,
      'height': height,
      'healthConditions': healthConditions,
      'isAdmin': isAdmin,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    List<String>? healthConditions,
    bool? isAdmin,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      healthConditions: healthConditions ?? this.healthConditions,
      isAdmin: isAdmin ?? this.isAdmin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 