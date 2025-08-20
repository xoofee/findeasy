/*

normally when app start it get position from device and fetch places nearby and select the first (nearest) one to render. User may manual select one from the places nearby in case of wrong location.

for test purpose use fake data sources and trigger load a fixed place map at startup

*/


import 'package:findeasy/app.dart';
import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
 
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,  // Transparent status bar
  //   systemNavigationBarColor: Colors.black.withOpacity(0.5),  // Dark overlay with some opacity (optional)
  //   statusBarIconBrightness: Brightness.light,  // Light icons for visibility
  // ));
  
  WidgetsFlutterBinding.ensureInitialized();    // enable getApplicationDocumentsDirectory

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    print('Using fallback configuration values');
  }

  // await init(); // injector setup

  runApp(
    const ProviderScope(
      child: LifecycleWatcher(child: App()),
    ),
  );
}

class LifecycleWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const LifecycleWatcher({super.key, required this.child});

  @override
  ConsumerState<LifecycleWatcher> createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends ConsumerState<LifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshDevicePosition(ref);      
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}