import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDirectory() async {
  if (kIsWeb) {
    // For Flutter Web, use a different directory or approach
    // For example, you can use the IndexedDB API to store data
    // or the File System API to access the file system
    // For simplicity, let's just return a dummy directory
    return '/web/directory';
  } else {
    // For other platforms, use the default path_provider
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return documentsDirectory.path;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}


Future<void> analyzeImage(String base64Image) async {
  // replace this with the python host link
  const String apiUrl = "https://vision.googleapis.com/v1/images:annotate?key=";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "requests": [
          {
            "image": base64Image // The base64 encoded image string
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Labels detected: $data");
    } else {
      print("Error: ${response.statusCode}");
      print("Error message: ${response.reasonPhrase}");
      print("Error body: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      home: FirstScreen(cameras: cameras),
    );
  }
}

class FirstScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const FirstScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hi, Guest',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/profile_default.jpg'),
              radius: 50,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondScreen(cameras: cameras)),
                );
              },
              child: const Text('Scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SecondScreen({super.key, required this.cameras});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Picture'),
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final directory = await getDirectory();
            String path = '$directory/${DateTime.now()}.png';
            _image = await _cameraController.takePicture();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ThirdScreen(image: _image!)),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  final XFile image;

  const ThirdScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicked Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kIsWeb? Image.network(image.path) : Image.file(File(image.path)),
            const SizedBox(height: 20),
            const Text(
              'You clicked a picture',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final bytes = await image.readAsBytes();
                final base64Image = base64Encode(bytes);
                await analyzeImage(base64Image);
              },
              child: const Text('Analyze Image'),
            ),
          ],
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
      return data['message']; // Returns the message received from FastAPI
    } else {
      return 'Failed to load message: ${response.statusCode}';
    }
  } catch (e) {
    // Handle any errors like connection issues
    return 'Error: $e';
  }
}
