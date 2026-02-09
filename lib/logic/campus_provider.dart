import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/campus_model.dart';
import '../data/repositories/campus_repository.dart';

final campusRepositoryProvider = Provider((ref) => CampusRepository());

final campusesStreamProvider = StreamProvider<List<CampusModel>>((ref) {
  return ref.watch(campusRepositoryProvider).getCampuses();
});
