
import 'package:etecsa_supervision/presentation/provider/provider.dart';
import 'package:etecsa_supervision/presentation/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeScreen extends StatelessWidget {
  static const name= "home-screen";
  
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: _HomeView(),
      bottomNavigationBar: const BarraNavegacion(),



    );
  }
}

class _HomeView extends ConsumerStatefulWidget {
  const _HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<_HomeView> {

@override
  void initState() {
    
   ref.read(nowplayingProvider.notifier).loadNextPage();
   ref.read(popularMovisProvider.notifier).loadNextPage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

   final nowplayingMovies = ref.watch(nowplayingProvider) ;
   final nowplayingMovies1 = ref.watch(moviesproviderCarrusel) ;
   final popularMovis = ref.watch(popularMovisProvider) ;

   if(nowplayingMovies1.isEmpty) return Center(child: CircularProgressIndicator());

    return CustomScrollView (



      slivers:[
                SliverAppBar(
                  
                  floating: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: CostumeAppBar(),

                  ),

                )
                
                ,
                SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                  
                   return Column(
        children: [
         // CostumeAppBar(),
      
          CarruselPeliculas(movies:   nowplayingMovies1 ),
          MovisListview(
            listMovis: nowplayingMovies,
            title: 'En cines',
            subTitle: 'Lunes 23',
            loadNextPage:  () {
      
              ref.read(nowplayingProvider.notifier).loadNextPage();
            }
                          
            
            
            ),
             MovisListview(
            listMovis: popularMovis,
            title: 'Populares',
            subTitle: 'Activas',
            loadNextPage:  () {
      
              ref.read(popularMovisProvider.notifier).loadNextPage();
            }
                          
            
            
            )
      
      
      
                ],
      );


                },
                childCount: 1
                  
                  
                
                  
                  
                  ))



      ]
       
    );
  }
}