import 'package:flutter/material.dart';

class CostumeAppBar extends StatelessWidget {
  const CostumeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final color=Theme.of(context).colorScheme;
    final estilo_titulo=Theme.of(context).textTheme.titleMedium;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            
            children: [
              Icon(Icons.movie_outlined,color: color.primary,),
              const SizedBox(width: 5),
          Text("Cine",style: estilo_titulo,),
          Spacer(),
          IconButton(
            onPressed:() {}, 
            icon: Icon(Icons.search))
              
              ]),
            
        ),
      ),
    );
  }
}
