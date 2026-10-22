


import 'package:dio/dio.dart';
import 'package:etecsa_supervision/config/constants/environment.dart';
import 'package:etecsa_supervision/domain/datasources/movis_datasources.dart';
import 'package:etecsa_supervision/domain/entities/movi.dart';
import 'package:etecsa_supervision/infraestructure/mapper/movie_mapper.dart';
import 'package:etecsa_supervision/infraestructure/model/moviedb/moviedb_response.dart';

class MoviedbDataSource implements MovisDatasources   {

 final dio=Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      "api_key": Environment.theMovieDbKey,
      'language': 'es-ES'
    }
    ));
   


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
     final respuesta= await dio.get(
      "/movie/now_playing", 
      queryParameters: {'page': page}
        
      );
     final movieDbreponse=  MovieDbResponse.fromJson(respuesta.data);
     final List<Movie>  movies= movieDbreponse.results.map((e)=>
     MovieMapper.moviedbToEntity(e)
     
     
     ).toList();
   return movies;
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) async{
   final respuesta= await dio.get(
      "/movie/popular", 
      queryParameters: {'page': page}
        
      );
     final movieDbreponse=  MovieDbResponse.fromJson(respuesta.data);
     final List<Movie>  movies= movieDbreponse.results.map((e)=>
     MovieMapper.moviedbToEntity(e)
     
     
     ).toList();
   return movies;
  }
  
  @override
  Future<List<Movie>> getTopRated({int page = 1}) {
    // TODO: implement getTopRated
    throw UnimplementedError();
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    // TODO: implement getUpcoming
    throw UnimplementedError();
  }






  
}