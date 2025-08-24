import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/search_providers.dart' as search_providers;

/// Reusable POI search input widget for routing and other POI selection scenarios
/// Note: Search results are handled by SearchResultsWidget, not this widget
class PoiSearchInput extends ConsumerStatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<Poi>? onPoiSelected;
  final VoidCallback? onCleared;
  final bool showBorder;
  final FocusNode? focusNode;

  const PoiSearchInput({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onPoiSelected,
    this.onCleared,
    this.showBorder = true,
    this.focusNode,
  });

  @override
  ConsumerState<PoiSearchInput> createState() => _PoiSearchInputState();
}

class _PoiSearchInputState extends ConsumerState<PoiSearchInput> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  bool _isFocused = false;
  bool _isProgrammaticChange = false; // Flag to prevent search on programmatic changes
  String _lastUserInput = ''; // Track the last user input to distinguish from programmatic changes

  @override
  void initState() {
    super.initState();
    _searchFocusNode = widget.focusNode ?? FocusNode();
    _searchController.text = widget.initialValue ?? '';
    _lastUserInput = _searchController.text;
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    // Only dispose if it's our internal focus node
    if (widget.focusNode == null) {
      _searchFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchChanged() {
    final currentText = _searchController.text;
    
    // Check if this is a programmatic change (like POI selection)
    if (_isProgrammaticChange) {
      _lastUserInput = currentText; // Update last user input
      return;
    }
    
    // Check if this is a real user input change
    if (currentText == _lastUserInput) {
      return; // No actual change
    }
    
    // This is a real user input change
    _lastUserInput = currentText;
    
    final query = currentText.trim();
    final searchController = ref.read(search_providers.searchControllerProvider.notifier);
    
    if (query.isEmpty) {
      searchController.clearSearchAndInput();
    } else {
      // Only search if the query is different from the current search
      // This prevents searching when a POI name is selected
      final currentSearchQuery = ref.read(search_providers.searchControllerProvider).query;
      if (query != currentSearchQuery) {
        // Debounce search to avoid too many API calls
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_searchController.text.trim() == query) {
            searchController.searchPois(query, reset: true);
          }
        });
      }
    }
  }

  void _onCleared() {
    _searchController.clear();
    _lastUserInput = '';
    ref.read(search_providers.searchControllerProvider.notifier).clearSearchAndInput();
    widget.onCleared?.call();
  }

  /// Update the text without triggering search (used when POI is selected from search results)
  void updateTextWithoutSearch(String text) {
    _isProgrammaticChange = true;
    _searchController.text = text;
    _lastUserInput = text;
    // Reset flag after a short delay
    Future.delayed(const Duration(milliseconds: 50), () {
      _isProgrammaticChange = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in initialValue and update the text controller
    if (widget.initialValue != null && _searchController.text != widget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateTextWithoutSearch(widget.initialValue!);
      });
    }

    return Container(
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
    );
  }
}
