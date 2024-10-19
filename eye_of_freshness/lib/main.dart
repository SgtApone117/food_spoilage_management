import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
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

class ThirdScreen extends StatelessWidget {
  final XFile image;

  ThirdScreen({required this.image});

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
            kIsWeb ? Image.network(image.path) : Image.file(File(image.path)),
            SizedBox(height: 20),
            Text(
              'You clicked a picture',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
