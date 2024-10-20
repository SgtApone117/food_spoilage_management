import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}


// Future<void> analyzeImage(String base64Image) async {
//   final String apiUrl = "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDhqy_8orlYewPBZn57hC0fFYDtEzrVI_8";

//   try {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: json.encode({
//         "requests": [
//           {
//             "image": {
//               "content": base64Image, // The base64 encoded image string
//             },
//             "features": [
//               {
//                 "type": "LABEL_DETECTION", // You can use TEXT_DETECTION, OBJECT_DETECTION, etc.
//                 "maxResults": 10,
//               },
//             ],
//           },
//         ],
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print("Labels detected: $data");
//     } else {
//       print("Error: ${response.statusCode}");
//       print("Error message: ${response.reasonPhrase}");
//       print("Error body: ${response.body}");
//     }
//   } catch (e) {
//     print("Error: $e");
//   }
// }

Future<String> analyzeImageWithSpoonacular(String base64Image, String apiKey) async {
  print(apiKey);
  final String apiUrl = "https://api.spoonacular.com/food/images/classify?apiKey=$apiKey";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: json.encode({
      "image": base64Image,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    bool isFood = data['category'] == 'food';

    if (isFood) {
      print("This is a food product.");
      return data['category'];
    } else {
      print("This is NOT a food product.");
      return "Error: Image is not a food product";
    }
  } else {
    print("Error: ${response.statusCode}");
    return "Error: Unable to classify image";
  }
}

Future<String> analyzeImage(String base64Image) async {
  
  
  //final String apiUrl = dotenv.env['CLOUD_API_KEY']?? '';
  final String foodApi = "bdcd020a5a6642efb52f80f13aa5c4b5";
  try {
    //get food type
    if(foodApi.isNotEmpty){
      final foodType = await analyzeImageWithSpoonacular(base64Image, foodApi);
      if(foodType == 'food'){
        return 'Food';
      }
      else{
        return 'Not a food';
      }
    }
    else{
      print('Food API key is missing');
      return 'Food API key is missing';
    }
  }

  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       "Content-Type": "application/json",
  //     },
  //     body: json.encode({
  //       "requests": [
  //         {
  //           "image": {
  //             "content": base64Image, // The base64 encoded image string
  //           },
  //           "features": [
  //             {
  //               "type": "LABEL_DETECTION", // You can use TEXT_DETECTION, OBJECT_DETECTION, etc.
  //               "maxResults": 10,
  //             },
  //           ],
  //         },
  //       ],
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return data['responses'][0]['labelAnnotations'][0]['description'];
  //   } else {
  //     return 'Failed to detect object';
  //   }
  // } 
  catch (e) {
    return 'Error: $e';
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp({required this.cameras});

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

  FirstScreen({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hi, Guest',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: AssetImage('assets/profile_default.jpg'),
              radius: 50,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondScreen(cameras: cameras)),
                );
              },
              child: Text('Scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  SecondScreen({required this.cameras});

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
        title: Text('Take a Picture'),
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
            return Center(child: CircularProgressIndicator());
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
        child: Icon(Icons.camera),
      ),
    );
  }
}

class ThirdScreen extends StatefulWidget {
  final XFile image;

  ThirdScreen({required this.image});

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  String? _detectedObject;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clicked Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kIsWeb? Image.network(widget.image.path) : Image.file(File(widget.image.path)),
            SizedBox(height: 20),
            Text(
              _detectedObject?? 'Analyzing image...',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    final bytes = await widget.image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final detectedObject = await analyzeImage(base64Image);
    setState(() {
      _detectedObject = detectedObject;
    });
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
