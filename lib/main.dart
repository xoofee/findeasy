import 'package:hive_flutter/hive_flutter.dart';
import 'package:trident/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trident/features/trade/domain/entities/candle.dart';
import 'package:trident/features/trade/domain/entities/kline_type.dart';
import 'package:trident/features/trade/domain/entities/macd.dart';
import 'package:trident/features/trade/domain/entities/kline_series.dart';
import 'package:trident/features/trade/application/services/kline_map_wrapper.dart';

import 'package:trident/injector.dart';

void main() async{
  // return;

  await Hive.initFlutter();

  Hive.registerAdapter(KLineSerieAdapter());
  Hive.registerAdapter(CandleAdapter());
  Hive.registerAdapter(MacdAdapter());
  Hive.registerAdapter(KLineTypeAdapter());
  Hive.registerAdapter(KLineMapWrapperAdapter());


  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,  // Transparent status bar
    systemNavigationBarColor: Colors.black.withOpacity(0.5),  // Dark overlay with some opacity (optional)
    statusBarIconBrightness: Brightness.light,  // Light icons for visibility
  ));
  
  WidgetsFlutterBinding.ensureInitialized();

  await init(); // injector setup

  runApp(const App());
}
