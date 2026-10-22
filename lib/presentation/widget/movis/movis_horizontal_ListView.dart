import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:etecsa_supervision/config/helper/human_format.dart';
import 'package:etecsa_supervision/domain/entities/movi.dart';

class MovisListview extends StatefulWidget {
  final List<Movie> listMovis;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovisListview({
    super.key,
    required this.listMovis,
    this.title,
    this.subTitle,
    this.loadNextPage,
  });

  @override
  State<MovisListview> createState() => _MovisListviewState();
}

class _MovisListviewState extends State<MovisListview> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.loadNextPage == null) return;
    
    if (!scrollController.hasClients) return;
    
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    final delta = 200.0;

    if (maxScroll > 0 && (currentScroll + delta) >= maxScroll) {
      widget.loadNextPage!();
      //print('Cargando nuevas peliculaaaa');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          _Title(title: widget.title, subtitle: widget.subTitle),
          Expanded(
            child: ListView.builder(
             
              itemCount: widget.listMovis.length,   
               controller: scrollController,          
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),

              itemBuilder: (context, index) {
                return _Slide(movie: widget.listMovis[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8 ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La imagen
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                width: 150,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null)
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  return FadeIn(child: child);
                },
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Text(movie.title, maxLines: 2, style: textStyle.titleSmall),
          ),
          SizedBox(
            width: 150,
            child: Row(
              children: [
                Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
                const SizedBox(width: 3),
                Text(
                  '${movie.voteAverage}',
                  style: textStyle.bodyMedium?.copyWith(
                    color: Colors.yellow.shade800,
                  ),
                ),
                //const SizedBox(width: 10,),
                Spacer(),
                Text(
                  HumanFormat.number(movie.popularity),
                  style: textStyle.bodySmall,
                ),
                //Text('${movie.popularity}',style: textStyle.bodySmall,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _Title({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final titlestyle = Theme.of(context).textTheme.titleLarge;

    return Container(
      padding: EdgeInsets.only(top: 10),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (title != null) Text(title!, style: titlestyle),
          const Spacer(),
          if (title != null)
            FilledButton.tonal(
              style: ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: () {},
              child: Text(subtitle!, style: titlestyle),
            ),
        ],
      ),
    );
  }
}
