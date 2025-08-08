// import 'package:hive_flutter/hive_flutter.dart';
import 'package:findeasy/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  
  WidgetsFlutterBinding.ensureInitialized();

  // await init(); // injector setup

  runApp(const ProviderScope(child: App()));
}
