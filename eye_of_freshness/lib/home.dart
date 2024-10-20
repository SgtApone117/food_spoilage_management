import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eye_of_freshness/globals.dart' as globals;
import 'package:path/path.dart';

import 'model/FoodItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = "Eye of Freshness";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  int _selectedIndex = 1;
  String bruh = "";
  XFile? imageFile;

  @override
  initState() {
    super.initState();
    prepareCamera();
    getStart();
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

  void retakePhoto() { // bruh
    setState(() { // bruh
      imageFile = null; // Reset the image file to show the camera preview again // bruh
    });
  }

  Future<void> sendImage(XFile image) async {
    final bytes = await image.readAsBytes(); // Read the image as bytes
    String base64Image = base64Encode(bytes); // Convert bytes to Base64

    final url = Uri.parse('${globals.backendIP}analyze'); // Update the URL to your API endpoint
    final headers = {'Content-Type': 'application/json'};

    // Prepare the JSON body with the Base64 image
    final body = jsonEncode({
      'image': base64Image, // Send the Base64-encoded image
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);
      setState(() {
        bruh = data['vision_response']['responses'][0]['labelAnnotations'][0]['description'];
      });
      // Extract the product type and expiration date from the vision_response
      // String productType = data['vision_response']['responses'][0]['labelAnnotations'][0]['description'];
      // String expirationDate = '2024-12-31'; // Replace with logic to determine expiration date

      // Save to local database
      // await DatabaseHelper().insertProduct(productType, expirationDate);
    } else {
      throw Exception('Failed to send image');
    }
  }

  getStart() async {
    print("bruh");
    print("bruh");
    FoodItem foodItem = FoodItem(foodtype: "pizza");
    final url = Uri.parse('${globals.backendIP}analyze'); // FastAPI backend URL
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
                        if (bruh != "")
                        Text(bruh),
                        if (bruh == "")
                        Center(
                            child: CircularProgressIndicator(
                          color: Color(globals.appColor),
                        )),
                      ],
                    ));
              } else if (_selectedIndex == 1) {
                return Stack(
                  children: [
                    if (imageFile ==
                        null) // Show camera preview before image capture
                      Container(
                        width: double.infinity,
                        child: CameraPreview(_cameraController!), // bruh
                      ), // bruh
                    if (imageFile !=
                        null) // Show captured image after image is taken
                      Image.file(
                        // bruh
                        File(imageFile!.path), // bruh
                        width: double.infinity, // bruh
                        fit: BoxFit.cover, // bruh
                      ),
                    Positioned(
                      // bruh
                      bottom: 50, // bruh
                      left: 0, // bruh
                      right: 0, // bruh
                      child: Row(
                        // bruh
                        mainAxisAlignment: (imageFile == null ? MainAxisAlignment.center :MainAxisAlignment.spaceBetween),
                        // Spread buttons to left and right // bruh
                        children: [
                          // bruh
                          if (imageFile !=
                              null) // Show "Retake" button if image is taken // bruh
                            Padding(
                              // bruh
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20), // bruh
                              child: ElevatedButton(
                                // bruh
                                onPressed: retakePhoto, // Retake photo // bruh
                                child: const Text('Retake'), // bruh
                              ),
                            ),
                          if (imageFile ==
                              null) // Show capture button if no image is taken // bruh
                            FloatingActionButton(
                              // bruh
                              onPressed: () async {
                                // bruh
                                await captureImage(); // Capture image // bruh
                              },
                              child: const Icon(Icons.camera), // bruh
                            ),
                          if (imageFile !=
                              null) // Show "Send" button if image is taken // bruh
                            Padding(
                              // bruh
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20), // bruh
                              child: ElevatedButton(
                                // bruh
                                onPressed: () async {
                                  // bruh
                                  await sendImage(imageFile!); // Send captured image to API // bruh
                                },
                                child: const Text('Send to API'), // bruh
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

  @override
  void dispose() {
    // bruh
    _cameraController?.dispose(); // Dispose of the camera controller // bruh
    super.dispose(); // bruh
  }
}
