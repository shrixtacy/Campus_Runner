import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/campus_model.dart';

class CampusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CampusModel>> getCampuses() {
    return _firestore.collection('campuses').orderBy('name').snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) {
        return AppConstants.defaultCampuses
            .map(
              (seed) => CampusModel(
                id: seed['id'] ?? '',
                name: seed['name'] ?? '',
                city: seed['city'] ?? '',
                state: seed['state'] ?? '',
              ),
            )
            .toList();
      }

      return snapshot.docs
          .map((doc) => CampusModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addCampus(CampusModel campus) async {
    await _firestore.collection('campuses').add(campus.toMap());
  }
}
