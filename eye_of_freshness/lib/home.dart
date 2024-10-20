import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eye_of_freshness/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'database_helper.dart';
import 'model/FoodItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = "Eye of Freshness";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _foodItemsFuture;
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  int _selectedIndex = 1;
  String food_item_name = "";
  int expiration_max = 0;
  int expiration_min = 0;
  XFile? imageFile;

  @override
  initState() {
    super.initState();
    prepareCamera();
    _initializeDatabase();
    _loadFoodItems();
  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper().database;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Prepare the camera when the app starts
  Future<void> prepareCamera() async {
    try {
      cameras = await availableCameras(); // Get the list of available cameras

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0], // Use the first available camera
          ResolutionPreset.high, // Set resolution to high
        );

        await _cameraController!.initialize(); // Initialize the camera
        setState(() {});
      } else {
        print("No cameras available");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        imageFile = await _cameraController!.takePicture();
        setState(() {});
      } catch (e) {
        print("Error capturing image: $e");
      }
    }
  }

  void retakePhoto() {
    setState(() {
      imageFile = null; // Reset the image file to show the camera preview again
    });
  }

  Future<void> sendImage(XFile image) async {
    setState(() {
      food_item_name = "";
      expiration_max = 0;
      expiration_min = 0;
    });

    final bytes = await image.readAsBytes(); // Read the image as bytes
    String base64Image = base64Encode(bytes); // Convert bytes to Base64

    final url = Uri.parse('${globals.backendIP}analyze'); // Update the URL to your API endpoint
    final headers = {'Content-Type': 'application/json'};

    // Prepare the JSON body with the Base64 image
    final body = jsonEncode({
      'image': base64Image, // Send the Base64-encoded image
    });

    final response = await http.post(url, headers: headers, body: body);

    // // bruh bruh bruh bruh bruh bruh
    // setState(() {
    //   _selectedIndex = 0;
    //   food_item_name = "Mockfood";
    //   expiration_max = 14;
    //   expiration_min = 7;
    // });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        food_item_name = data['food_item'] == "-" ? "Not a food" : data['food_item'];
        expiration_max = data['expiration_max'];
        expiration_min = data['expiration_min'];
      });
    } else {
      throw Exception('Failed to send image');
    }
  }

  void _loadFoodItems() {
    setState(() {
      _foodItemsFuture = DatabaseHelper().getSortedFoodItems();
    });
  }

  Future<void> _saveFoodItem(String name, int minDays, int maxDays) async {
    await DatabaseHelper().insertFoodItem(name, minDays, maxDays);
    _loadFoodItems();
  }

  String calculateExpirationDate(String dateReceived, int daysToAdd) {
    DateTime receivedDate = DateTime.parse(dateReceived);
    DateTime expirationDate = receivedDate.add(Duration(days: daysToAdd));
    return expirationDate.toLocal().toString().split(' ')[0]; // Returns only the date part
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(globals.appColor),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          title: Text("Eye of freshness"),
        ),
        body: SafeArea(
            child: Builder(
          builder: (context) {
            if (true) {
              if (_selectedIndex == 0) {
                return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        if (food_item_name != "")
                        Text(food_item_name),
                        if (food_item_name != "" && food_item_name != "Not a food")
                        Text("Will be expired in : " + expiration_min.toString() + "-" + expiration_max.toString() + " days."),
                        if (food_item_name == "")
                        Center(
                            child: CircularProgressIndicator(
                          color: Color(globals.appColor),
                        )),
                        if (food_item_name != "" && food_item_name != "Not a food")
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // Spread buttons to left and right
                              children: [
                                if (imageFile !=
                                    null) // Show "Send" button if image is taken
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await _saveFoodItem(food_item_name, expiration_min, expiration_max);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ),
                              ],
                            ),
                      ],
                    ));
              } else if (_selectedIndex == 1) {
                return Stack(
                  children: [
                    if (imageFile ==
                        null) // Show camera preview before image capture
                      Container(
                        width: double.infinity,
                        child: CameraPreview(_cameraController!),
                      ),
                    if (imageFile !=
                        null) // Show captured image after image is taken
                      Image.file(

                        File(imageFile!.path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Positioned(

                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Row(

                        mainAxisAlignment: (imageFile == null ? MainAxisAlignment.center :MainAxisAlignment.spaceBetween),
                        // Spread buttons to left and right
                        children: [

                          if (imageFile !=
                              null) // Show "Retake" button if image is taken
                            Padding(

                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: ElevatedButton(

                                onPressed: retakePhoto, // Retake photo
                                child: const Text('Retake'),
                              ),
                            ),
                          if (imageFile ==
                              null) // Show capture button if no image is taken
                            FloatingActionButton(

                              onPressed: () async {

                                await captureImage(); // Capture image
                              },
                              child: const Icon(Icons.camera),
                            ),
                          if (imageFile !=
                              null) // Show "Send" button if image is taken
                            Padding(

                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: ElevatedButton(

                                onPressed: () async {

                                  await sendImage(imageFile!); // Send captured image to API
                                },
                                child: const Text('Send to API'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
                // }
                // if (bruh == ""){
                //   return Container(
                //       padding: const EdgeInsets.all(40),
                //       child: Column(
                //         children: [
                //           Center(
                //               child: CircularProgressIndicator(
                //                 color: Color(globals.appColor),
                //               )),
                //         ],
                //       ));
                // }
                // return Container(
                //     child: Text(bruh));
              } else {
                // return FutureBuilder<List<Map<String, dynamic>>>(
                //   future: DatabaseHelper().getSortedFoodItems(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Container(
                //         padding: const EdgeInsets.all(40),
                //         child: Center(
                //           child: CircularProgressIndicator(
                //             color: Color(globals.appColor),
                //           ),
                //         ),
                //       );
                //     }
                //
                //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
                //       return Container(
                //         padding: const EdgeInsets.all(40),
                //         child: Center(
                //           child: Text('No items found'),
                //         ),
                //       );
                //     }
                //
                //     final foodItems = snapshot.data!;
                //
                //     return Container(
                //       padding: const EdgeInsets.all(40),
                //       child: Column(
                //         children: [
                //           Expanded(
                //             child: ListView.builder(
                //               itemCount: foodItems.length,
                //               itemBuilder: (context, index) {
                //                 final item = foodItems[index];
                //                 String expirationMinDate = DateFormat('yyyy-MM-dd').format(item['calculated_expiration_min']);
                //                 String expirationMaxDate = calculateExpirationDate(item['date_received'], item['expiration_max']);
                //
                //                 return ListTile(
                //                   title: Text(item['name']),
                //                   subtitle: Text('Expires between $expirationMinDate and $expirationMaxDate'),
                //                 );
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // );
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _foodItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(globals.appColor),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text('No items found'),
                        ),
                      );
                    }

                    final foodItems = snapshot.data!;

                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: ListView.builder(
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          final item = foodItems[index];
                          String expirationMinDate = DateFormat('yyyy-MM-dd').format(item['calculated_expiration_min']);
                          String expirationMaxDate = calculateExpirationDate(item['date_received'], item['expiration_max']);

                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text('Expires between $expirationMinDate and $expirationMaxDate'),
                          );
                        },
                      ),
                    );
                  },
                );
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

  @override
  void dispose() {

    _cameraController?.dispose(); // Dispose of the camera controller
    super.dispose();
  }
}
