import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter and FastAPI"),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: fetchMessage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return Text(snapshot.data ?? "No message");
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<String> fetchMessage() async {
  // Make a GET request to your FastAPI backend
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['message'];  // This should return "Hello from FastAPI"
  } else {
    throw Exception('Failed to load message');
  }
}