import 'package:etecsa_supervision/domain/entities/movi.dart';
import 'package:etecsa_supervision/presentation/provider/movis/movis_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final nowplayingProvider = StateNotifierProvider<MovieNotifier, List<Movie>>((
  ref,
) {
  final fechMOreMovies = ref.watch(moviereporsotoryProvider).getNowPlaying;
  return MovieNotifier(fechMOreMovies);
});


final popularMovisProvider = StateNotifierProvider<MovieNotifier, List<Movie>>((
  ref,
) {
  final fechMOreMovies = ref.watch(moviereporsotoryProvider).getPopular;
  return MovieNotifier(fechMOreMovies);
});



typedef MovieCallback = Future<List<Movie>> Function({int page});

class MovieNotifier extends StateNotifier<List<Movie>> {
  var currePage = 0;
  bool isloading = false;
  MovieCallback? loadNextPageCallback;

  MovieNotifier(this.loadNextPageCallback) : super([]);

  void setNowPlaying(List<Movie> movies) {
    state = movies;
  }

  Future<void> loadNextPage() async {
    if (isloading) return;
    isloading = true;
    print('Loading more movis ${isloading}');
    currePage++;
    final movies = await loadNextPageCallback?.call(page: currePage) ?? [];
    state = [...state, ...movies];
    await Future.delayed(const Duration(milliseconds: 300));
    isloading = false;
  }
}
