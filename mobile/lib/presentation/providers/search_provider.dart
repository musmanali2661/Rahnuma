import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/place_model.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import 'service_providers.dart';

/// State for the search screen.
class SearchState {
  const SearchState({
    this.results = const [],
    this.recentSearches = const [],
    this.isLoading = false,
    this.query = '',
    this.error,
  });

  final List<PlaceModel> results;
  final List<String> recentSearches;
  final bool isLoading;
  final String query;
  final String? error;

  SearchState copyWith({
    List<PlaceModel>? results,
    List<String>? recentSearches,
    bool? isLoading,
    String? query,
    String? error,
  }) =>
      SearchState(
        results: results ?? this.results,
        recentSearches: recentSearches ?? this.recentSearches,
        isLoading: isLoading ?? this.isLoading,
        query: query ?? this.query,
        error: error,
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._api) : super(const SearchState()) {
    _loadRecent();
  }

  final ApiService _api;

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final recent =
        prefs.getStringList(AppConstants.prefRecentSearches) ?? [];
    state = state.copyWith(recentSearches: recent);
  }

  Future<void> search(
    String query, {
    double? lat,
    double? lon,
  }) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], query: '');
      return;
    }

    state = state.copyWith(isLoading: true, query: query, error: null);
    try {
      final results = await _api.search(query, lat: lat, lon: lon);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addRecentSearch(String query) async {
    final updated = [
      query,
      ...state.recentSearches.where((r) => r != query),
    ].take(5).toList();
    state = state.copyWith(recentSearches: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.prefRecentSearches, updated);
  }

  void clearResults() {
    state = state.copyWith(results: [], query: '');
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref.watch(apiServiceProvider)),
);
