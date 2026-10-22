

import 'package:etecsa_supervision/infraestructure/datasource/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etecsa_supervision/infraestructure/repositories/movie_repository_impl.dart';



// Es inmmutable no cambia

final moviereporsotoryProvider = Provider((ref) {

  return MovieRepositoryImpl(  source:  MoviedbDataSource());
  
  
});