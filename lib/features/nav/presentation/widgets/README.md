# Search Functionality

This directory contains the search functionality for POIs (Points of Interest) in the IndoorEasy app. The search system provides paginated results and can be used in various contexts like the main navigation page and routing pages.

## Components

### 1. SearchBarWidget
The main search bar widget used in the navigation page. It includes:
- Search input with debounced search
- Voice input button (placeholder)
- System menu button
- Search results display below the search bar
- Pagination support

**Usage:**
```dart
const SearchBarWidget(
  onPoiSelected: (poi) {
    // Handle POI selection
  },
  showResults: true, // Set to false to hide results
)
```

### 2. SearchResultsWidget
Displays search results with pagination. Features:
- Scrollable list of POI results
- Load more functionality
- POI type icons and colors
- Error handling and loading states

**Usage:**
```dart
const SearchResultsWidget(
  onPoiSelected: () {
    // Handle POI selection
  },
  showCloseButton: true,
)
```

### 3. PoiSearchInput
A reusable search input widget for POI selection. Features:
- Dropdown search results
- Configurable hint text and max results
- POI selection callback
- Clear functionality

**Usage:**
```dart
PoiSearchInput(
  hintText: 'Search POI...',
  initialValue: 'Initial POI name',
  onPoiSelected: (poi) {
    // Handle POI selection
  },
  onCleared: () {
    // Handle clear action
  },
  maxResults: 5,
  showResults: true,
)
```

### 4. RoutingInputWidget
A complete routing input form that uses PoiSearchInput for start and end point selection. Features:
- Start and end POI selection
- Swap points functionality
- Route planning button
- Route summary display

**Usage:**
```dart
RoutingInputWidget(
  onStartPoiSelected: (poi) {
    // Handle start POI selection
  },
  onEndPoiSelected: (poi) {
    // Handle end POI selection
  },
  onRouteRequested: () {
    // Handle route calculation request
  },
)
```

## Search Providers

### SearchController
Manages the search state and provides methods for:
- Searching POIs by name
- Pagination support
- Loading more results
- Clearing search results

**Key Methods:**
- `searchPois(String query, {bool reset = false})` - Search for POIs
- `loadMore()` - Load next page of results
- `clearSearch()` - Clear all search results

### SearchState
Holds the current search state including:
- Current search query
- Search results
- Loading state
- Pagination information
- Error messages

## Features

### 1. Pagination
- Results are loaded in pages (default: 10 items per page)
- "Load More" button appears when more results are available
- Preloading of next page for better user experience

### 2. Debounced Search
- Search is triggered 300ms after user stops typing
- Prevents excessive API calls during rapid typing

### 3. Relevance Sorting
- Exact matches appear first
- Partial matches starting with the query appear second
- Alphabetical sorting for remaining results

### 4. POI Type Visualization
- Color-coded POI types (parking, shop, elevator, etc.)
- Appropriate icons for each POI type
- Level information display

### 5. Error Handling
- Graceful handling of search errors
- Loading states for better UX
- Empty state messages

## Integration

### In Navigation Page
The search functionality is integrated into the main navigation page, allowing users to search for POIs and see them on the map.

### In Routing Pages
The search functionality can be used for selecting start and end points for route planning, with dedicated input widgets for each purpose.

### Reusability
All search widgets are designed to be reusable across different parts of the app, with configurable options for different use cases.

## Future Enhancements

1. **Voice Search**: Integration with speech recognition for hands-free searching
2. **Search History**: Remember recent searches for quick access
3. **Favorites**: Allow users to mark frequently used POIs
4. **Advanced Filters**: Filter by POI type, level, or other attributes
5. **Search Suggestions**: Auto-complete and search suggestions
6. **Offline Search**: Local search when network is unavailable
