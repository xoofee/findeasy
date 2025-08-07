import 'package:flutter/material.dart';

import 'package:findeasy/injector.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

// class App extends StatelessWidget {
//   const App({super.key});

  @override
  Widget build(BuildContext context) {

    // MultiBlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<KLineBloc>()),    // ..add(KLineStarted()) after auth check
        BlocProvider(create: (_) => sl<ChartZoomBloc>() ),
        BlocProvider(create: (_) => sl<StockChartBloc>( )),
        BlocProvider(create: (_) => sl<AuthBloc>()..add(CheckAuthEvent()) ),
        BlocProvider(create: (_) => sl<TradingHistoryBloc>() ),
        BlocProvider(create: (_) => sl<StrategyBloc>() ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),        
        title: 'findeasy',

        debugShowCheckedModeBanner: false,
        home: const KLineScreen(),

      ),
    );

  }
}
