import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {

  const ImageInput({super.key, required this.onPickImage});


  final void Function(File image) onPickImage;
  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedimage;
  void _takephoto() async {
    final imagepicker = ImagePicker();
    final pickedImage = await imagepicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedimage = File(pickedImage.path);
    });
    widget.onPickImage(_selectedimage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ElevatedButton.icon(
        onPressed: _takephoto,
        icon: const Icon(Icons.camera),
        label: const Text('snap pick'));
    if (_selectedimage != null) {
      content = GestureDetector(
          onTap: _takephoto,
          child: Image.file(
            _selectedimage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ));
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
      alignment: Alignment.center,
      height: 250,
      width: double.infinity,
      child: content,
    );
  }
}
