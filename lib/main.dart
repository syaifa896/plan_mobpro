import 'package:flutter/material.dart';
import 'package:plan/dashboard.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/login.dart';
import 'package:plan/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseSvc.instance.database;
  Map<String, dynamic>? uname = await DatabaseSvc.instance.getUserLogin();
  runApp(MainApp(unamenya: uname));
}

class MainApp extends StatelessWidget {
  final Map<String, dynamic>? unamenya;
  MainApp({super.key, this.unamenya});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: unamenya != null
          ? Dashboard(username: unamenya!['username'])
          : SplashScreen(),
      title: 'Plan',
      routes: {
        '/login': (context) => LoginPage(),
      },
    );
  }
}
