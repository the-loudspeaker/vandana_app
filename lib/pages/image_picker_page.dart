import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:vandana_app/utils/custom_fonts.dart';

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

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList.isNotEmpty) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              final String? mime = lookupMimeType(_mediaFileList[index].path);

              // Why network for web?
              // See https://pub.dev/packages/image_picker_for_web#limitations-on-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: kIsWeb
                    ? Image.network(_mediaFileList[index].path)
                    : (mime == null || mime.startsWith('image/')
                        ? Image.file(
                            File(_mediaFileList[index].path),
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return const Center(
                                  child:
                                      Text('This image type is not supported'));
                            },
                          )
                        : const SizedBox()),
              );
            },
            itemCount: _mediaFileList.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider()),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
        style: MontserratFont.paragraphReg1,
      );
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
                      return _previewImages();
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
            : _previewImages(),
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
