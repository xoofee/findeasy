import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/search_providers.dart' as search_providers;

/// Widget for displaying search results with pagination
class SearchResultsWidget extends ConsumerWidget {
  final VoidCallback? onPoiSelected;
  final bool showCloseButton;

  const SearchResultsWidget({
    super.key,
    this.onPoiSelected,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (showCloseButton)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    '搜索結果 (${searchState.results.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
                shrinkWrap: true,
                itemCount: searchState.results.length + (searchState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == searchState.results.length) {
                    // Load more button
                    return _buildLoadMoreButton(searchController, searchState);
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
                'Error: ${searchState.error}',
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
            poi.type.replaceAll('amenity:', '').replaceAll('shop:', ''),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            'Level ${poi.level.value}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
      onTap: () {
        onPoiSelected?.call();
        // You can add additional logic here like selecting the POI
      },
    );
  }

  Widget _buildLoadMoreButton(search_providers.SearchController searchController, search_providers.SearchState searchState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: searchState.isLoading ? null : () => searchController.loadMore(),
          child: searchState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Load More'),
        ),
      ),
    );
  }

  Color _getPoiColor(String type) {
    if (type.contains('parking')) return Colors.blue;
    if (type.contains('shop')) return Colors.green;
    if (type.contains('elevator')) return Colors.orange;
    if (type.contains('toilet')) return Colors.purple;
    if (type.contains('cafe') || type.contains('restaurant')) return Colors.red;
    return Colors.grey;
  }

  IconData _getPoiIcon(String type) {
    if (type.contains('parking')) return Icons.local_parking;
    if (type.contains('shop')) return Icons.shopping_bag;
    if (type.contains('elevator')) return Icons.elevator;
    if (type.contains('toilet')) return Icons.wc;
    if (type.contains('cafe') || type.contains('restaurant')) return Icons.restaurant;
    return Icons.place;
  }
}
