import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eye_of_freshness/globals.dart' as globals;

import 'model/FoodItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = "Eye of Freshness";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  String bruh = "";

  @override
  initState() {
    super.initState();
    getStart();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  getStart() async {
    print("bruh");
    print("bruh");
    FoodItem foodItem = FoodItem(foodtype: "pizza");
    final url = Uri.parse('${globals.backendIP}start'); // FastAPI backend URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(foodItem.toJson()); // Convert FoodItem to JSON


    final response = await http.post(url, headers: headers, body: body);
    // print(response.statusCode);
    // final data = jsonDecode(response.body);
    // print(data);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // for (Map<String, dynamic> item in data) {
      //   if (["j", "k"].contains(foodGroup.fineGroupId)) {
      //     if (item["value"] > 0.501) {
      //       if (item["notes"] != "") {
      //         foodItemsHelpful
      //             .add(item["foodItemDisplayAs"] + ": " + item["notes"]);
      //       } else {
      //         foodItemsHelpful.add(item["foodItemDisplayAs"]);
      //       }
      //     }
      //   } else {
      //     if (item["notes"] != "") {
      //       foodItemsHelpful
      //           .add(item["foodItemDisplayAs"] + ": " + item["notes"]);
      //     } else {
      //       foodItemsHelpful.add(item["foodItemDisplayAs"]);
      //     }
      //   }
      // }
      setState(() {
        bruh = data['foodtype'];
      });
    } else {
      throw Exception('Failed to load start.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(globals.appColor),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20
          ),
          title: Text("Eye of freshness"),
        ),
        body: SafeArea(child: Builder(
          builder: (context) {
            if (true) {
              if (_selectedIndex == 0) {
                  return Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Center(
                              child: CircularProgressIndicator(
                                color: Color(globals.appColor),
                              )),
                        ],
                      ));
              } else if (_selectedIndex == 1) {
                if (bruh == ""){
                  return Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Center(
                              child: CircularProgressIndicator(
                                color: Color(globals.appColor),
                              )),
                        ],
                      ));
                }
                return Container(
                    child: Text(bruh));
              } else {
                return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Center(
                            child: CircularProgressIndicator(
                              color: Color(globals.appColor),
                            )),
                      ],
                    ));
              }
            }
          },
        )),
        bottomNavigationBar: Builder(builder: (context) {
            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  label: 'Notes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.newspaper),
                //   label: "What's new?",
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
              currentIndex: _selectedIndex,
              unselectedFontSize: 14,
              selectedFontSize: 16,
              selectedLabelStyle: const TextStyle(
                fontFamily: "Lexend",
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: "Lexend",
              ),
              backgroundColor: const Color(0xFFF9F9F9),
              selectedItemColor: Color(globals.appColor),
              onTap: _onItemTapped,
            );
        }));
  }
}
