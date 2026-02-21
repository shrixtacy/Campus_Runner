import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/app_mode.dart';
import '../models/shop_model.dart';

class ShopRepository {
  static final List<ShopModel> _demoShops = [];

  Future<void> addShop(ShopModel shop) async {
    if (!AppMode.backendEnabled) {
      _demoShops.add(shop);
      return;
    }

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('shops').add(shop.toMap());
  }

  String? currentUserId() =>
      AppMode.backendEnabled ? FirebaseAuth.instance.currentUser?.uid : 'demo-user';
}
