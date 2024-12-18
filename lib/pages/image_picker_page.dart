import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/local_images_preview.dart';

class ImagePickerPage extends StatefulWidget {
  final Function onPick;
  final bool singleImage;
  const ImagePickerPage(
      {super.key, required this.onPick, this.singleImage = false});
  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  List<XFile> _mediaFileList = List.empty(growable: true);

  dynamic _pickImageError;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();

  void _setImageFileListFromFile(XFile? value) {
    if (value != null) {
      if (widget.singleImage) {
        _mediaFileList = <XFile>[value];
      } else {
        if (_mediaFileList.isEmpty) {
          _mediaFileList = <XFile>[value];
        } else {
          _mediaFileList.add(value);
        }
      }
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files!;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.singleImage
        ? _mediaFileList.isEmpty
            ? "Add image"
            : "Confirm image"
        : _mediaFileList.isEmpty
            ? "Add images"
            : "Confirm images";

    return Scaffold(
      appBar: AppBar(
          title: Text(titleText, style: MontserratFont.paragraphMedium1)),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return LocalImagesPreview(mediaFileList: _mediaFileList, pickImageError: _pickImageError, retrieveDataError: _retrieveDataError);
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : LocalImagesPreview(mediaFileList: _mediaFileList, pickImageError: _pickImageError, retrieveDataError: _retrieveDataError),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_picker.supportsImageSource(ImageSource.camera))
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: FloatingActionButton(
                onPressed: () async {
                  if (context.mounted) {
                    try {
                      final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      setState(() {
                        _setImageFileListFromFile(pickedFile);
                      });
                    } catch (e) {
                      setState(() {
                        _pickImageError = e;
                      });
                    }
                  }
                },
                heroTag: 'image',
                tooltip: 'Take photo(s)',
                child: Icon(widget.singleImage && _mediaFileList.length == 1
                    ? Icons.cameraswitch
                    : Icons.camera_alt),
              ),
            ),
          if (_mediaFileList.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  widget.onPick(_mediaFileList);
                  Navigator.pop(context);
                },
                heroTag: "Confirm",
                tooltip: "Confirm",
                child: const Icon(Icons.check),
              ),
            )
        ],
      ),
    );
  }
}
