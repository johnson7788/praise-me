import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoPraisePage extends StatefulWidget {
  const PhotoPraisePage({super.key});

  @override
  _PhotoPraisePageState createState() => _PhotoPraisePageState();
}

class _PhotoPraisePageState extends State<PhotoPraisePage> {
  File? _selectedImage;
  String _praiseResult = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('your_api_url/photo-praise')
      );
      request.files.add(
          await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path
          )
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        setState(() => _praiseResult = result);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍拍夸')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('相册选择'),
                  onPressed: _isLoading ? null : _pickImage,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                  onPressed: _isLoading ? null : _takePhoto,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
                : const Text('请先选择或拍摄照片'),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadImage,
                child: const Text('生成照片夸夸'),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _praiseResult,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
