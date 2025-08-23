import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/search_providers.dart' as search_providers;

/// Widget for displaying search results with pagination
class SearchResultsWidget extends ConsumerStatefulWidget {
  final VoidCallback? onPoiSelected;
  final bool showCloseButton;

  const SearchResultsWidget({
    super.key,
    this.onPoiSelected,
    this.showCloseButton = true,
  });

  @override
  ConsumerState<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends ConsumerState<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is within 200 pixels of the bottom
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() async {
    final searchState = ref.read(search_providers.searchControllerProvider);
    final searchController = ref.read(search_providers.searchControllerProvider.notifier);
    
    if (!_isLoadingMore && searchState.hasMore && !searchState.isLoading) {
      setState(() {
        _isLoadingMore = true;
      });
      
      await searchController.loadMore();
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(search_providers.searchControllerProvider);
    final searchController = ref.read(search_providers.searchControllerProvider.notifier);

    // Don't show if no search query or no results
    if (searchState.query.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          if (widget.showCloseButton)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    '搜索結果 (${searchState.totalResults})',
                    // '搜索結果 (${searchState.results.length}/${searchState.totalResults})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // if (searchState.hasMore)
                  //   Text(
                  //     '還有 ${searchState.totalResults - searchState.results.length} 項結果',
                  //     style: TextStyle(
                  //       color: Colors.grey[600],
                  //       fontSize: 12,
                  //     ),
                  //   ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => searchController.clearSearch(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),

          // Results list
          if (searchState.results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
                minHeight: 50,
              ),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: searchState.results.length + (searchState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == searchState.results.length) {
                    // Loading indicator at bottom
                    return _buildLoadingIndicator(searchState);
                  }
                  
                  final poi = searchState.results[index];
                  return _buildPoiListItem(context, poi, searchController);
                },
              ),
            )
          else if (searchState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (searchState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${searchState.error}',
                style: TextStyle(color: Colors.red[600]),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '未找到',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPoiListItem(BuildContext context, Poi poi, search_providers.SearchController searchController) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPoiColor(poi.type),
        child: Icon(
          _getPoiIcon(poi.type),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        poi.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poi.type.name,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            'Level ${poi.level.displayName}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
      onTap: () {
        widget.onPoiSelected?.call();
        // You can add additional logic here like selecting the POI
      },
    );
  }

  Widget _buildLoadingIndicator(search_providers.SearchState searchState) {
    if (!searchState.hasMore) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (searchState.isLoading || _isLoadingMore)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              searchState.isLoading || _isLoadingMore 
                ? '載入中...' 
                : '滑動載入更多',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPoiColor(PoiType type) {    // TODO: eliminate duplication with poi_search_input.dart
    if (type == PoiType.parkingSpace) return Colors.blue;
    if (type == PoiType.shop) return Colors.green;
    if (type == PoiType.elevator) return Colors.orange;
    if (type == PoiType.toilet) return Colors.purple;
    if (type == PoiType.cafe || type == PoiType.restaurant) return Colors.red;
    return Colors.grey;
  }

  IconData _getPoiIcon(PoiType type) {
    if (type == PoiType.parkingSpace) return Icons.local_parking;
    if (type == PoiType.shop) return Icons.shopping_bag;
    if (type == PoiType.elevator) return Icons.elevator;
    if (type == PoiType.toilet) return Icons.wc;
    if (type == PoiType.cafe || type == PoiType.restaurant) return Icons.restaurant;
    return Icons.place;
  }
}
