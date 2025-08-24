import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/presentation/providers/search_providers.dart' as search_providers;
import 'dart:async'; // Added for Timer

/// Reusable POI search input widget for routing and other POI selection scenarios
/// Note: Search results are handled by SearchResultsWidget, not this widget
class PoiSearchInput extends ConsumerStatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<Poi>? onPoiSelected;
  final VoidCallback? onCleared;
  final bool showBorder;
  final FocusNode? focusNode;
  final TextEditingController? textController; // Add text controller parameter

  const PoiSearchInput({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onPoiSelected,
    this.onCleared,
    this.showBorder = true,
    this.focusNode,
    this.textController, // Add to constructor
  });

  @override
  ConsumerState<PoiSearchInput> createState() => _PoiSearchInputState();
}

class _PoiSearchInputState extends ConsumerState<PoiSearchInput> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isFocused = false;
  bool _isProgrammaticChange = false; // Flag to prevent search on programmatic changes
  String _lastUserInput = ''; // Track the last user input to distinguish from programmatic changes
  bool _shouldShowRed = true; // Flag to control when to show red text
  Timer? _colorChangeTimer; // Timer to delay color change

  @override
  void initState() {
    super.initState();
    _searchFocusNode = widget.focusNode ?? FocusNode();
    
    // Use external text controller if provided, otherwise create internal one
    if (widget.textController != null) {
      _searchController = widget.textController!;
    } else {
      _searchController = TextEditingController();
      _searchController.text = widget.initialValue ?? '';
    }
    
    _lastUserInput = _searchController.text;
    _shouldShowRed = true; // Start with red text color
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _colorChangeTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    
    // Only dispose if it's our internal controller
    if (widget.textController == null) {
      _searchController.dispose();
    }
    
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
      _shouldShowRed = true;
      _colorChangeTimer?.cancel();
      setState(() {});
    } else {
             // Only search if the query is different from the current search
       // This prevents searching when a POI name is selected
       final currentSearchQuery = ref.read(search_providers.searchControllerProvider).query;
       if (query != currentSearchQuery) {
         // Reset color change timer
         _colorChangeTimer?.cancel();
         
         // Only reset red color if we're starting a new search (not continuing to type)
         if (query.length > currentSearchQuery.length) {
           // User is adding characters, keep current color state
         } else {
           // User is changing/deleting characters, reset to black
           _shouldShowRed = true;
           setState(() {});
         }
         
         // Debounce search to avoid too many API calls
         Future.delayed(const Duration(milliseconds: 300), () {
           if (_searchController.text.trim() == query) {
             searchController.searchPois(query, reset: true);
             
             // Set a timer to check for exact match after search completes
             _colorChangeTimer = Timer(const Duration(milliseconds: 500), () {
               if (mounted && _searchController.text.trim() == query) {
                 _checkForExactMatch(query);
               }
             });
           }
         });
       }
    }
  }

  void _checkForExactMatch(String query) {
    if (!mounted) return;
    
    final searchResults = ref.read(search_providers.searchResultsProvider);
    final hasExactMatch = searchResults.any((poi) => poi.name.toLowerCase() == query.toLowerCase());
    
    setState(() {
      _shouldShowRed = !hasExactMatch;
    });
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
    _shouldShowRed = false; // Reset red color when POI is selected
    _colorChangeTimer?.cancel();
    // Reset flag after a short delay
    Future.delayed(const Duration(milliseconds: 50), () {
      _isProgrammaticChange = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 16,
                  color: _shouldShowRed ? Colors.red : Colors.black87,
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
