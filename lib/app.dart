import 'package:flutter/material.dart';

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
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),        
      title: 'findeasy',

      debugShowCheckedModeBanner: false,
      home: const Text('Hello World'),

    );

  }
}
