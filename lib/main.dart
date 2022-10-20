import 'package:flutter/material.dart';
import 'app/main_screen/main_screen.dart';
import 'app/AppTheme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Text Generator',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/main',
        routes: {
          '/main': (context) => MainScreen(),
        } 
        );
  }
}
