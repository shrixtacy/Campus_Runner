import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/shop_repository.dart';

final shopRepositoryProvider = Provider((ref) => ShopRepository());
