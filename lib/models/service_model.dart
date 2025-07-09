// lib/models/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String providerEmail;
  final String providerImage;
  final List<String> serviceImages;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> location;
  final List<String> serviceAreas;
  final Map<String, dynamic> availability; // Example: {'monday': true, 'startTime': '09:00', 'endTime': '17:00'}

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.providerEmail,
    required this.providerImage,
    required this.serviceImages,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.serviceAreas,
    required this.availability,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhone: data['providerPhone'] ?? '',
      providerEmail: data['providerEmail'] ?? '',
      providerImage: data['providerImage'] ?? '',
      serviceImages: List<String>.from(data['serviceImages'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      availability: Map<String, dynamic>.from(data['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerEmail': providerEmail,
      'providerImage': providerImage,
      'serviceImages': serviceImages,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'location': location,
      'serviceAreas': serviceAreas,
      'availability': availability,
    };
  }
}