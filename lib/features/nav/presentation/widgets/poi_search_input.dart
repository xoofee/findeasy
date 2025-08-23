import 'package:findeasy/features/nav/presentation/utils/level_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/search_providers.dart' as search_providers;

/// Reusable POI search input widget for routing and other POI selection scenarios
class PoiSearchInput extends ConsumerStatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<Poi>? onPoiSelected;
  final VoidCallback? onCleared;
  final bool showResults;
  final int maxResults;
  final bool showBorder;

  const PoiSearchInput({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onPoiSelected,
    this.onCleared,
    this.showResults = true,
    this.maxResults = 5,
    this.showBorder = true,
  });

  @override
  ConsumerState<PoiSearchInput> createState() => _PoiSearchInputState();
}

class _PoiSearchInputState extends ConsumerState<PoiSearchInput> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialValue ?? '';
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final searchController = ref.read(search_providers.searchControllerProvider.notifier);
    
    if (query.isEmpty) {
      searchController.clearSearchAndInput();
    } else {
      // Debounce search to avoid too many API calls
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_searchController.text.trim() == query) {
          searchController.searchPois(query, reset: true);
        }
      });
    }
  }

  void _onPoiSelected(Poi poi) {
    _searchController.text = poi.name;
    _searchFocusNode.unfocus();
    ref.read(search_providers.searchControllerProvider.notifier).clearSearchAndInput();
    widget.onPoiSelected?.call(poi);
  }

  void _onCleared() {
    _searchController.clear();
    ref.read(search_providers.searchControllerProvider.notifier).clearSearchAndInput();
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(search_providers.searchControllerProvider);

    // Listen for changes in search query and clear input if query is cleared externally
    if (searchState.query.isEmpty && _searchController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.clear();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            border: widget.showBorder ? Border.all(
              color: _isFocused ? Colors.blue : Colors.grey.shade300,
              width: _isFocused ? 2 : 1,
            ) : null,

          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Icon(
                //   Icons.search,
                //   color: Colors.grey[600],
                //   size: 20,
                // ),
                // const SizedBox(width: 8),
                
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                // Clear button
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: _onCleared,
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Search results dropdown
        if (widget.showResults && _isFocused && searchState.query.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                minHeight: 50,
              ),
              child: _buildSearchResults(searchState),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(search_providers.SearchState searchState) {
    if (searchState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (searchState.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${searchState.error}',
          style: TextStyle(color: Colors.red[600], fontSize: 12),
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    // Limit results to maxResults
    final limitedResults = searchState.results.take(widget.maxResults).toList();
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: limitedResults.length,
      itemBuilder: (context, index) {
        final poi = limitedResults[index];
        return _buildPoiListItem(poi);
      },
    );
  }

  Widget _buildPoiListItem(Poi poi) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: _getPoiColor(poi.type),
        child: Icon(
          _getPoiIcon(poi.type),
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(
        poi.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${poi.type.name} • ${poi.level.displayName}',
        style: TextStyle(color: Colors.grey[600], fontSize: 11),
      ),
      onTap: () => _onPoiSelected(poi),
    );
  }

  Color _getPoiColor(PoiType type) {
    if (type == PoiType.parkingSpace) return Colors.blue;
    if (type == PoiType.shop) return Colors.green;
    if (type == PoiType.elevator) return Colors.orange;
    if (type == PoiType.toilet) return Colors.purple;
    if (type == PoiType.stairs) return Colors.brown;
    if (type == PoiType.escalator) return Colors.indigo;
    if (type == PoiType.entrance || type == PoiType.exit) return Colors.green;
    return Colors.grey;
  }

  IconData _getPoiIcon(PoiType type) {
    if (type == PoiType.parkingSpace) return Icons.local_parking;
    if (type == PoiType.shop) return Icons.shopping_bag;
    if (type == PoiType.elevator) return Icons.elevator;
    if (type == PoiType.toilet) return Icons.wc;
    if (type == PoiType.cafe) return Icons.restaurant;
    if (type == PoiType.restaurant) return Icons.restaurant;
    return Icons.place;
  }
}
