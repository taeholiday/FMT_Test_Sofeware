// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraAndGalleryPage extends StatefulWidget {
  const CameraAndGalleryPage({Key? key}) : super(key: key);

  @override
  State<CameraAndGalleryPage> createState() => _CameraAndGalleryPageState();
}

class _CameraAndGalleryPageState extends State<CameraAndGalleryPage> {
  /// Variables
  File? imageFile;
  double size = 0.0;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera and gallery'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buttonAndIcon(
              Icons.camera_alt,
              "CAMERA",
              _getFromCamera,
            ),
            imageFile == null
                ? SizedBox(
                    width: size > 600 ? size * 0.5 : size * 0.2,
                    child: Image.asset('images/addimage.png'),
                  )
                : SizedBox(
                    width: size > 600 ? size * 0.5 : size * 0.2,
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
            buttonAndIcon(
              Icons.photo_library,
              "GALLERY",
              _getFromGallery,
            ),
          ],
        ),
      ),
    );
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? imageSelects;
    imageSelects = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    print("imageSelects gallery");
    print(imageSelects);
    if (imageSelects != null) {
      setState(() {
        imageFile = File(imageSelects!.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? imageSelects;
    imageSelects = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    print("imageSelects camera");
    print(imageSelects);
    if (imageSelects != null) {
      setState(() {
        imageFile = File(imageSelects!.path);
      });
    }
  }

  Widget buttonAndIcon(
      IconData icon, String buttonName, Function functionCallBack) {
    return ElevatedButton.icon(
        onPressed: () => functionCallBack(),
        icon: Icon(icon),
        label: Text(buttonName));
  }
}
