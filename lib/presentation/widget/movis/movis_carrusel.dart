

import 'package:card_swiper/card_swiper.dart';
import 'package:etecsa_supervision/domain/entities/movi.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CarruselPeliculas extends StatelessWidget {
  List<Movie> movies;

  CarruselPeliculas(
    {super.key, required this.movies
    });

  @override
  Widget build(BuildContext context) {
     final color=Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Swiper(
       viewportFraction: 0.8,
       scale: 0.9,
       itemCount: movies.length,
       pagination: SwiperPagination(
        margin: EdgeInsets.only(top: 0),
        
     
        builder: DotSwiperPaginationBuilder(
          
          activeColor: color.primary,
          color: color.secondary
        )
       ),
       autoplay: true,
       itemBuilder: (context, index) => _Vistas(movie: movies[index]),

    ) 
    
    
    
    
                                            //Swuiper
     );                                       //SizedBox
  }



}

class _Vistas extends StatelessWidget {

   final Movie movie;
  const _Vistas({required this.movie});

  @override
  Widget build(BuildContext context) {
     final decorador=BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0,10)
        )
      ],
     );


    return Padding(padding:   EdgeInsets.only(bottom: 30),
              child: DecoratedBox(
                decoration: decorador,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                            movie.backdropPath,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) => loadingProgress==null
                            ? child  : Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                              ),
                            ),
                          ),
                )
              ));
  }} 