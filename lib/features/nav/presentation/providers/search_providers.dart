import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

/// Search state class to hold search query and results
class SearchState {
  final String query;
  final List<Poi> results;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final int totalResults;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.pageSize = 10,
    this.totalResults = 0,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Poi>? results,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    int? totalResults,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalResults: totalResults ?? this.totalResults,
      error: error ?? this.error,
    );
  }
}

/// Search controller that manages POI search with pagination
class SearchController extends StateNotifier<SearchState> {
  final Ref _ref;
  
  SearchController(this._ref) : super(const SearchState());

  /// Search for POIs by name with pagination
  Future<void> searchPois(String query, {bool reset = false}) async {
    if (query.isEmpty) {
      state = state.copyWith(
        query: '',
        results: [],
        currentPage: 0,
        hasMore: false,
        error: null,
      );
      return;
    }

    if (reset) {
      state = state.copyWith(
        query: query,
        results: [],
        currentPage: 0,
        hasMore: true,
        error: null,
        isLoading: true,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Get POI manager from the current place
      final poiManager = _ref.read(poiManagerProvider);
      if (poiManager == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No map loaded',
        );
        return;
      }

      // Get all POIs and filter by name
      final allPois = poiManager.poisById.values.toList();
      final filteredPois = allPois.where((poi) {
        final poiName = poi.name.toLowerCase();
        final searchQuery = query.toLowerCase();
        return poiName.contains(searchQuery);
      }).toList();

      // Sort by relevance (exact matches first, then partial matches)
      filteredPois.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        query = query.toLowerCase();
        
        final aExact = aName == query;
        final bExact = bName == query;
        
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        
        final aStartsWith = aName.startsWith(query);
        final bStartsWith = bName.startsWith(query);
        
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;
        
        return aName.compareTo(bName);
      });

      // Apply pagination
      final startIndex = reset ? 0 : state.results.length;
      final endIndex = startIndex + state.pageSize;
      final pageResults = filteredPois.skip(startIndex).take(state.pageSize).toList();

      final hasMore = endIndex < filteredPois.length;
      final newResults = reset ? pageResults : [...state.results, ...pageResults];

      state = state.copyWith(
        query: query,
        results: newResults,
        currentPage: reset ? 0 : state.currentPage + 1,
        hasMore: hasMore,
        totalResults: filteredPois.length,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Load more results (next page)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.query.isEmpty) return;
    
    await searchPois(state.query, reset: false);
  }

  /// Clear search results
  void clearSearch() {
    state = const SearchState();
  }

  /// Get current search results
  List<Poi> get currentResults => state.results;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there are more results to load
  bool get hasMore => state.hasMore;

  /// Get current search query
  String get currentQuery => state.query;
}

/// Provider for search controller
final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>(
  (ref) => SearchController(ref),
);

/// Provider for search results (for easy access to results)
final searchResultsProvider = Provider<List<Poi>>((ref) {
  return ref.watch(searchControllerProvider).results;
});

/// Provider for search loading state
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchControllerProvider).isLoading;
});

/// Provider for search has more state
final searchHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(searchControllerProvider).hasMore;
});

/// Provider for search total results count
final searchTotalResultsProvider = Provider<int>((ref) {
  return ref.watch(searchControllerProvider).totalResults;
});
