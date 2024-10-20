import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eye_of_freshness/globals.dart' as globals;

import 'home.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Eye of freshness',
            theme: ThemeData(
              fontFamily: "Lexend",
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF004C93),
                background: const Color(0xFFF9F9F9),
              ),
              useMaterial3: true,
            ),
            home: const HomePage(),
          );
  }
}

