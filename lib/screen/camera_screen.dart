import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_firebase/auth/login_screen.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeCamera;
  XFile? imageFile;
  String message = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    initializeCamera = controller.initialize();
  }

  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> takePicture() async {
    try {
      await initializeCamera;
      final image = await controller.takePicture();

      final face = await detectFaces(File(image.path));

      if (face.isNotEmpty) {
        setState(() {
          message = "Mendeteksi wajah seanyak: ${face.length}";
        });
      } else {
        setState(() {
          message = "Tidak ada wajah yang terdeteksi";
        });
      }

      setState(() {
        imageFile = image;
      });
    } catch (e) {
      setState(() {
        message = "Gagal mengambil gambar karena $e";
      });
    }
  }

  Future<List<Face>> detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final option = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableClassification: true,
      enableContours: true,
    );
    final faceDetector = FaceDetector(options: option);

    final face = await faceDetector.processImage(inputImage);
    await faceDetector.close();
    return face;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            FutureBuilder(
              future: initializeCamera,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return imageFile != null
                      ? Image.file(File(imageFile!.path))
                      : CameraPreview(controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                takePicture();
              },
              onLongPress: () {
                setState(() {
                  imageFile = null;
                });
              },
              child: Icon(Icons.camera),
            ),
          ],
        ),
      ),
      floatingActionButton: imageFile != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Icon(Icons.login),
            )
          : Text("Absen wajah dulu"),
    );
  }
}
