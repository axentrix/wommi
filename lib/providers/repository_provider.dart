import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/wommi_repository.dart';

final databaseProvider = Provider<WommiDatabase>((ref) {
  final db = WommiDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final repositoryProvider = Provider<WommiRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WommiRepository(db);
});
