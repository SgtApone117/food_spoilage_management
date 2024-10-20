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
  String food_item_name = "";
  int expiration_max = 0;
  int expiration_min = 0;
  XFile? imageFile;

  @override
  initState() {
    super.initState();
    prepareCamera();
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

      setState(() {
        food_item_name = data['food_item'] == "-" ? "Not a food" : data['food_item'];
        expiration_max = data['expiration_max'];
        expiration_min = data['expiration_min'];
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

    _cameraController?.dispose(); // Dispose of the camera controller
    super.dispose();
  }
}
