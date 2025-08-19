

Perfect 👍 let’s build a **unified startup widget** that works in both **real** and **test** mode by toggling a flag.

---

### Step 1. Define a startup mode

```dart
enum StartupMode {
  normal, // real GPS + API
  test,   // fixed fake place
}
```

---

### Step 2. Provide the startup mode globally

```dart
final startupModeProvider = Provider<StartupMode>((ref) => StartupMode.normal);
```

When you want test mode:

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        startupModeProvider.overrideWithValue(StartupMode.test),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

### Step 3. Startup widget

```dart
class AppStartup extends ConsumerWidget {
  const AppStartup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(startupModeProvider);

    if (mode == StartupMode.test) {
      // Always load fixed fake place
      const testPlace = Place(id: 0, name: "Test Place");
      return MapScreen(placeId: testPlace.id);
    }

    // Normal startup flow: get nearest place from GPS
    final nearestPlaceAsync = ref.watch(
      nearestPlacesProvider(/* device position */),
    );

    return nearestPlaceAsync.when(
      data: (place) {
        if (place == null) return const Text("No nearby places found");
        return MapScreen(placeId: place.id);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}
```

---

### Step 4. Use inside your app

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppStartup(),
    );
  }
}
```

---

✅ This way:

* You **only write one UI flow** (`AppStartup`).
* **Normal mode**: GPS → nearest place → map.
* **Test mode**: fixed place → map.

---

Do you want me to also show how to **inject a fake map result** (so `MapScreen` doesn’t even call the repo in test mode), or do you prefer to keep the test mode going through the normal repository chain?
