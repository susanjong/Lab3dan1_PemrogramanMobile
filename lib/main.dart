import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'providers/app_state_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: MaterialApp.router(
        title: 'AnimeVerse',
        theme: ThemeData(
          fontFamily: 'Urbanist',
        ),
        routerConfig: createRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}