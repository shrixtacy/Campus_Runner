import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../core/config/app_mode.dart';
import '../../core/constants/app_constants.dart';
import '../models/campus_model.dart';

class CampusRepository {
  static final List<CampusModel> _demoCampuses = AppConstants.defaultCampuses
      .map(
        (seed) => CampusModel(
          id: seed['id'] ?? '',
          name: seed['name'] ?? '',
          city: seed['city'] ?? '',
          state: seed['state'] ?? '',
        ),
      )
      .toList();
  static final StreamController<int> _demoCampusTicker =
      StreamController<int>.broadcast();

  Stream<List<CampusModel>> getCampuses() {
    if (!AppMode.backendEnabled) {
      return Stream<List<CampusModel>>.multi((controller) {
        controller.add(List<CampusModel>.from(_demoCampuses));
        final sub = _demoCampusTicker.stream.listen((_) {
          controller.add(List<CampusModel>.from(_demoCampuses));
        });
        controller.onCancel = sub.cancel;
      });
    }

    final firestore = FirebaseFirestore.instance;
    return firestore.collection('campuses').orderBy('name').snapshots().map((
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
    if (!AppMode.backendEnabled) {
      _demoCampuses.add(
        CampusModel(
          id: 'demo-campus-${DateTime.now().millisecondsSinceEpoch}',
          name: campus.name,
          city: campus.city,
          state: campus.state,
        ),
      );
      _demoCampusTicker.add(_demoCampuses.length);
      return;
    }

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('campuses').add(campus.toMap());
  }
}
