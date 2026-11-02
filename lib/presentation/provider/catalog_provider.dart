// lib/presentation/provider/catalog_provider.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catalogo completo de inversores (spec §2).
///
/// Una sola lectura de `GET /api/inversors/all` (nunca el endpoint
/// paginado): el dashboard agrupa y filtra en memoria sobre los ~300
/// inversores del parque.
final inverterCatalogProvider = FutureProvider<List<Inversor>>((ref) {
  return ref.watch(inverterRepositoryProvider).fetchAll();
});
