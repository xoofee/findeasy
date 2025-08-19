Good question 👍 this is a **classic “override wrong detection” scenario** in apps like indoor maps.
Let’s walk through how you’d design it in Riverpod.

---

## 🏗️ Flow

1. **Startup flow** (normal case):

   * Get GPS → match nearest `Place` → load its map.

2. **Override flow** (user taps button):

   * Show a popup list of nearby places (from `nearestPlacesProvider`).
   * If user selects one → set it as the **current place** and reload the map.

---

## 🔑 Providers you need

```dart
// Holds the "currently selected" place (either auto-detected or manual override)
final currentPlaceProvider = StateProvider<Place?>((ref) => null);

// Nearby places fetched from repo
final nearbyPlacesProvider =
    FutureProvider.family<List<Place>, LatLng>((ref, center) async {
  final repo = ref.watch(placesRepositoryProvider);
  return repo.getPlaces(center);
});

// Map loader depends on the selected place
final mapLoaderProvider =
    FutureProvider<MapResult?>((ref) async {
  final place = ref.watch(currentPlaceProvider);
  if (place == null) return null;

  final repo = ref.watch(placeMapRepositoryProvider);
  return repo.getMap(place.id);
});
```

---

## 🖼️ UI usage

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final mapAsync = ref.watch(mapLoaderProvider);

  return Scaffold(
    appBar: AppBar(
      title: const Text("Indoor Map"),
      actions: [
        IconButton(
          icon: const Icon(Icons.place),
          onPressed: () async {
            // Show nearby places in a dialog
            final center = LatLng(35.68, 139.76); // Tokyo example
            final placesAsync = ref.read(nearbyPlacesProvider(center).future);

            final places = await placesAsync;
            if (context.mounted) {
              final selected = await showDialog<Place>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text("Select place"),
                  children: places
                      .map((p) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, p),
                            child: Text(p.name),
                          ))
                      .toList(),
                ),
              );

              if (selected != null) {
                ref.read(currentPlaceProvider.notifier).state = selected;
              }
            }
          },
        ),
      ],
    ),
    body: mapAsync.when(
      data: (map) =>
          map == null ? const Text("No map selected") : MapWidget(map: map),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text("Error: $err"),
    ),
  );
}
```

---

## ✨ Why this works well

* **Startup**: you set `currentPlaceProvider` to the detected nearest place → map loads.
* **Override**: user picks from popup → `currentPlaceProvider` updates → `mapLoaderProvider` reacts → new map loads.
* The UI **always depends only on `mapLoaderProvider`** → no duplication of logic.

---

👉 Do you want me to also show how to **auto-initialize `currentPlaceProvider` at startup** (from GPS → nearest place), so you don’t have to manually set it in `main()`?
