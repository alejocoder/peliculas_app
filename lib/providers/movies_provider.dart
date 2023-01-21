import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';
import 'package:movies_app/models/models.dart';
import 'package:movies_app/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = '6107a6f57c4da48d7dc4fe711a477f04';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie?>? onDisplayMovies = [];
  List<Movie?>? popularMovies = [];

  Map<int, List<Cast?>?>? moviesCast;

  int _popularPage = 0;

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie?>?> _suggestionsStreameController =
      StreamController.broadcast();

  Stream<List<Movie?>?> get suggestionsStream =>
      _suggestionsStreameController.stream;

  MoviesProvider() {
    print('moviesprovider inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'languaje': _language,
      'page': '$page',
    });
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromRawJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('/3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromRawJson(jsonData);

    popularMovies = [...?popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast?>?> getMovieCast(int movieId) async {
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromRawJson(jsonData);

    moviesCast?[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie?>?> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'languaje': _language,
      'query': query,
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromRawJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionsStreameController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
