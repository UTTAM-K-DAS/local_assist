import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../models/service_model.dart';
import '../models/user_model.dart' as user_model; // Make sure this import is correct

class ServiceProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add a new service
  Future<String> addService(ServiceModel service) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('services')
          .add(service.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding service: $e');
      throw e;
    }
  }

  // Update service
  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update(data);
    } catch (e) {
      print('Error updating service: $e');
      throw e;
    }
  }

  // Delete service
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .delete();
    } catch (e) {
      print('Error deleting service: $e');
      throw e;
    }
  }

  // Get all services
  Stream<List<ServiceModel>> getServices() {
    return _firestore.collection('services').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  // Upload service image
  Future<String?> uploadServiceImage(File imageFile, String serviceId) async { // Modified to accept serviceId
    try {
      String fileName =
          'service_images/${serviceId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading service image: $e');
      return null;
    }
  }

  // Delete service image
  Future<void> deleteServiceImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Error deleting service image: $e');
    }
  }

  // Add a review to a service
  Future<void> addServiceReview(String serviceId, String userId,
      double rating, String comment) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .collection('reviews')
          .add({
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // After adding a review, update the service's average rating
      await _updateServiceRating(serviceId);
    } catch (e) {
      print('Error adding service review: $e');
      throw e;
    }
  }

  // Update service rating (private helper)
  Future<void> _updateServiceRating(String serviceId) async {
    try {
      QuerySnapshot reviews = await _firestore
          .collection('services')
          .doc(serviceId)
          .collection('reviews')
          .get();

      if (reviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviews.docs) {
          totalRating += (doc.data() as Map<String, dynamic>)['rating'];
        }

        double averageRating = totalRating / reviews.docs.length;

        await _firestore
            .collection('services')
            .doc(serviceId)
            .update({
          'rating': averageRating,
          'reviewCount': reviews.docs.length,
        });
      }
    } catch (e) {
      print('Error updating service rating: $e');
    }
  }

  // Get service reviews
  Stream<List<Map<String, dynamic>>> getServiceReviews(String serviceId) {
    return _firestore
        .collection('services')
        .doc(serviceId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList());
  }

  // Get user profile by UID (moved inside class)
  Future<user_model.UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return user_model.UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Add these new methods for favoriting services
  Future<bool> isServiceFavorited(String userId, String serviceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(serviceId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<void> toggleFavoriteService(String userId, String serviceId) async {
    try {
      DocumentReference favoriteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(serviceId);

      DocumentSnapshot doc = await favoriteRef.get();

      if (doc.exists) {
        await favoriteRef.delete(); // Remove from favorites
      } else {
        await favoriteRef.set({'addedAt': FieldValue.serverTimestamp()}); // Add to favorites
      }
    } catch (e) {
      print('Error toggling favorite service: $e');
      throw e;
    }
  }
}