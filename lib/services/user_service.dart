import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _providers = [];
  List<UserModel> get providers => _providers;

  Future<void> loadProviders() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isProvider', isEqualTo: true)
          .get();
      
      _providers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
      
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }
}