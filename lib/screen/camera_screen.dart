import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_firebase/auth/login_screen.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeCamera;
  XFile? imageFile;
  String message = 'Posisikan wajah Anda di depan kamera';

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    initializeCamera = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    try {
      await initializeCamera;
      final image = await controller.takePicture();

      final face = await detectFaces(File(image.path));

      if (face.isNotEmpty) {
        setState(() {
          message = "Berhasil mendeteksi ${face.length} wajah.";
          imageFile = image;
        });
      } else {
        setState(() {
          message = "Tidak ada wajah yang terdeteksi. Coba lagi.";
          imageFile = null;
        });
      }
    } catch (e) {
      setState(() {
        message = "Gagal mengambil gambar: $e";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absen Wajah'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      // --- REDESIGN: Menggunakan Stack untuk UI yang lebih baik ---
      body: FutureBuilder(
        future: initializeCamera,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Camera Preview atau Gambar Hasil
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: imageFile != null
                        ? Image.file(File(imageFile!.path))
                        : CameraPreview(controller),
                  ),
                ),

                // Layer 2: Tombol dan Pesan
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Pesan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Aksi
                    if (imageFile == null)
                      // Tombol Ambil Gambar
                      FloatingActionButton.large(
                        onPressed: takePicture,
                        child: const Icon(Icons.camera_alt),
                      )
                    else
                      // Tombol Lanjut Login & Ulangi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                imageFile = null;
                                message =
                                    'Posisikan wajah Anda di depan kamera';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Ulangi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Lanjut Login'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // --- Akhir Redesign ---
    );
  }
}
