import 'package:etecsa_supervision/domain/datasources/movis_datasources.dart';
import 'package:etecsa_supervision/domain/entities/movi.dart';
import 'package:etecsa_supervision/domain/repository/movis_repository.dart';

class MovieRepositoryImpl extends MovisRepository{
  
final MovisDatasources source;

  MovieRepositoryImpl({required this.source});
  
  
  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {


    return source.getNowPlaying(page: page);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    return source.getPopular(page: page); 
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