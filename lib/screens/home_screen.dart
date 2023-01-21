import 'package:flutter/material.dart';
import 'package:movies_app/providers/movies_provider.dart';
import 'package:movies_app/search/search_delegate.dart';
import 'package:movies_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Peliculas en cines'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: (() => showSearch(context: context, delegate: MovieSearchDelegate())),
              icon: const Icon(Icons.search_outlined),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CardSwiper(
                movies: moviesProvider.onDisplayMovies,
              ),
              const SizedBox(
                height: 20,
              ),
              MovieSlider(
                movies: moviesProvider.popularMovies,
                title: 'populares',
                onNextPage: () => moviesProvider.getPopularMovies(),
              ),
            ],
          ),
        ));
  }
}
