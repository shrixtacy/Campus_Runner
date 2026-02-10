import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addShop(ShopModel shop) async {
    await _firestore.collection('shops').add(shop.toMap());
  }

  String? currentUserId() => _auth.currentUser?.uid;
}
