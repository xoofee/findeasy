import 'package:get_it/get_it.dart';


// Global GetIt instance
final GetIt sl = GetIt.instance;    // service locator

// Initialize dependency injection
Future<void> init() async {

//   final config = AppConfig(
//     futureCode: 'HK.MHImain',
//     stockCode: 'HK.800000',
//     kLineTypes: [KLineType.k1m, KLineType.k5m, KLineType.k15m, KLineType.kHour],
//     // kLineTypes: [KLineType.k1m, KLineType.kHour],
//     defaultLoadDays: 7,
//     autoPool: true,
//     fields: ['datetime', 'open', 'high', 'low', 'close'],
//     baseUrl: "https://xoofee.top/trident-api",
//     loadByDay: false,
//     countWave: true,
//   );

//   sl.registerSingleton<ConfigService>(ConfigService(config: config));

//   final dioClient = DioClient();
//   await dioClient.init();
//   sl.registerSingleton<DioClient>(dioClient);
//   // sl.registerSingleton<DioClient>(DioClient());  // configureDioAdapter is async which cannot make asure it is configured before access remoteDataSource.client.dio.options.extra['cookieJar']; in auth_repository_impl.dart

//   sl.registerLazySingleton<LoggerService>(() => LoggerService());

// // Register Connectivity as a lazy singleton
//   sl.registerLazySingleton<Connectivity>(() => Connectivity());

//   // Register http.Client as a lazy singleton
//   sl.registerLazySingleton<http.Client>(() => http.Client());

//   /*
//   BLoCs (e.g., auth_bloc.dart, stock_bloc.dart) where network status is relevant. 
//   Start monitoring by calling startMonitoring() when needed 
//   (e.g., in a BLoC's initialization or a screen's initState).
//   */
//   sl.registerLazySingleton<NetworkMonitor>(() => NetworkMonitor(
//         healthCheckUrl: 'https://xoofee.top/trident-api/health',
//         // ignore: avoid_print
//         onNetworkUp: () => print('Network is up'),        // TODO: inject to bloc
//         // ignore: avoid_print
//         onNetworkDown: () => print('Network is down'),
//       ));

//   // --- Auth Feature ---
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//       () => AuthRemoteDataSource(baseUrl: config.baseUrl, client: sl()));

//   // Repository
//   sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
//         remoteDataSource: sl() ));

//   // Use Cases
//   sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(repository: sl()));
//   sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(repository: sl()));

//   // BLoC
//   sl.registerLazySingleton(() => AuthBloc(    // registerFactory is more common for bloc, but the auth is better to be singleton
//         loginUseCase: sl(),
//         logoutUseCase: sl(),
//         authRepository: sl(),
//         dioClient: sl(),
//       ));

//   // --- Trade Feature ---


//   // --- Services ---
//   // Register ApiService as a lazy singleton
//   sl.registerLazySingleton<HistoryKLineRemoteDataSource>(() => HistoryKLineRemoteDataSource(
//         baseUrl: config.baseUrl,
//         client: sl(),
//       ));

//   // Register WebSocketService as a lazy singleton
//   sl.registerLazySingleton<RealtimeKLineWebSocketDataSource>(() => RealtimeKLineWebSocketDataSource(
//         wsUrl: 'wss://xoofee.top/trident-api/ws/realtime_kline',
//       ));

//   sl.registerLazySingleton(() => KLineRepositoryImpl(remoteHistorySource: sl(), realtimeSource: sl() ) );


//   // final end = DateTime.now();
//   // final start = end.subtract(Duration(days: config.defaultLoadDays));

//   // final klineParamsList = config.kLineTypes.map((e) => (
//   //   KLineHistoryParams(
//   //     code: config.futureCode,
//   //     start: start,
//   //     end: end,
//   //     ktype: e,
//   //     fields: config.fields,

//   //   )
//   // )).toList();

//   sl.registerLazySingleton<StrategyBloc>( () => StrategyBloc(klineStore: sl()) );

//   sl.registerLazySingleton(() => KLineBloc(     // registerFactory is more common for bloc
//         fetchUseCase: sl(),
//       ));

//   sl.registerLazySingleton(() => ChartZoomBloc(sl()) );
//   sl.registerLazySingleton(() => StockChartBloc(config.kLineTypes.length) );

//   sl.registerLazySingleton<KLineStore>(() => KLineStore());

//   // Use Cases
//   sl.registerLazySingleton(() => FetchKLineHistoryUseCase(repository: sl<KLineRepositoryImpl>(), store: sl<KLineStore>()));

// // Data sources
//   sl.registerLazySingleton<TradingHistoryRemoteDataSource>(
//     () => TradingHistoryRemoteDataSourceImpl(baseUrl: config.baseUrl, client: sl()),
//   );

//   // Repositories
//   sl.registerLazySingleton<TradingHistoryRepository>(
//     () => TradingHistoryRepositoryImpl(remoteDataSource: sl()),
//   );

//   // Use cases
//   sl.registerLazySingleton(() => FetchTradingHistoryUsecase(repository: sl()));

//   // Blocs
//   sl.registerFactory(() => TradingHistoryBloc(fetchTradingHistory: sl()));

}