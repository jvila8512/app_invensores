

import 'package:etecsa_supervision/domain/entities/movi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'movis_provider.dart';

final moviesproviderCarrusel= Provider<List<Movie>>((ref) {

  
   final nowplayingMovies = ref.watch(nowplayingProvider) ;
   
   if(nowplayingMovies.isEmpty) {
     return [];
   }
  return  nowplayingMovies.sublist( 0, 6);
} );