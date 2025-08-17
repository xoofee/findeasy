// import 'package:hive_flutter/hive_flutter.dart';
import 'package:findeasy/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  // return;

  // await Hive.initFlutter();

  // Hive.registerAdapter(KLineSerieAdapter());
  // Hive.registerAdapter(CandleAdapter());
  // Hive.registerAdapter(MacdAdapter());
  // Hive.registerAdapter(KLineTypeAdapter());
  // Hive.registerAdapter(KLineMapWrapperAdapter());


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

  runApp(const ProviderScope(child: App()));
}
