// ignore_for_file: unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

void main() {
  runApp(ImageConverterApp());
}

class ImageConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImageConverter(),
    );
  }
}

class ImageConverter extends StatefulWidget {
  @override
  _ImageConverterState createState() => _ImageConverterState();
}

class _ImageConverterState extends State<ImageConverter> {
  File? _image;
  String _format = 'png'; // Default format
  String? _convertedImageUrl;
  String? _error;
  bool _loading = false; // Loading state

  final ImagePicker _picker = ImagePicker();

  // Handle image upload
  Future<void> _pickImage() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _convertedImageUrl = null; // Reset converted image
        _error = null; // Reset error message
      });
    } else {
      setState(() {
        _error = "Please select a valid image.";
      });
    }
  }

  // Handle format selection
  void _handleFormatChange(String? value) {
    setState(() {
      _format = value ?? 'png';
    });
  }

  // Handle the image conversion
  Future<void> _convertImage() async {
    if (_image == null) {
      setState(() {
        _error = "Please upload an image before converting.";
      });
      return;
    }

    setState(() {
      _loading = true; // Set loading state when conversion starts
      _error = null; // Reset error
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/convert-image/'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
      request.fields['format'] = _format;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final convertedImageUrl = String.fromCharCodes(responseData);
        setState(() {
          _convertedImageUrl = convertedImageUrl;
          _loading = false; // Stop loading when response is received
        });
      } else {
        throw Exception('Failed to convert image.');
      }
    } catch (e) {
      setState(() {
        _loading = false; // Stop loading if an error occurs
        _error = "Failed to convert image. Please try again.";
      });
      print(e);
    }
  }

  // Handle image download
  Future<void> _downloadImage() async {
    if (_convertedImageUrl == null) return;

    try {
      final response = await http.get(Uri.parse(_convertedImageUrl!));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Save the image using path_provider and permission_handler packages
        // You might need to implement the download logic as per your requirement
      } else {
        throw Exception("Failed to download image");
      }
    } catch (error) {
      print("Error downloading image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Convert your images easily and quickly!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            // File upload button
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            // Format selection
            DropdownButton<String>(
              value: _format,
              items: [
                DropdownMenuItem(child: Text('PNG'), value: 'png'),
                DropdownMenuItem(child: Text('JPG'), value: 'jpg'),
                DropdownMenuItem(child: Text('JPEG'), value: 'jpeg'),
              ],
              onChanged: _handleFormatChange,
            ),
            SizedBox(height: 20),
            // Convert button
            ElevatedButton(
              onPressed: _loading ? null : _convertImage,
              child: Text(_loading ? 'Converting...' : 'Convert'),
            ),
            SizedBox(height: 20),
            // Display converted image
            if (_convertedImageUrl != null)
              Column(
                children: [
                  Image.network(_convertedImageUrl!),
                  ElevatedButton(
                    onPressed: _downloadImage,
                    child: Text('Download Image'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

extension on ImagePicker {
  getImage({required ImageSource source, required int imageQuality}) {}
}
