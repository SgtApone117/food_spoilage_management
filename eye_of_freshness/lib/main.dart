import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter and FastAPI"),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: sendFoodType(FoodItem(foodtype: "pizza")), // Pass FoodItem here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
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

class FoodItem {
  final String foodtype;

  FoodItem({required this.foodtype});

  // Factory method to create a FoodItem object from a JSON map
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodtype: json['foodtype'],
    );
  }

  // Method to convert FoodItem object to JSON
  Map<String, dynamic> toJson() {
    return {
      'foodtype': foodtype,
    };
  }
}

Future<String> sendFoodType(FoodItem foodItem) async {
  final url = Uri.parse('http://127.0.0.1:8000/start'); // FastAPI backend URL
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode(foodItem.toJson()); // Convert FoodItem to JSON

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'No message returned from server'; // Ensure non-null
    } else {
      return 'Failed to load message: ${response.statusCode}'; // Ensure non-null on failure
    }
  } catch (e) {
    // Handle any errors like connection issues
    return 'Error: $e'; // Ensure non-null on exception
  }
}





