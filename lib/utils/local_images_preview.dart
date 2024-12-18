import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';

import 'custom_fonts.dart';

class LocalImagesPreview extends StatelessWidget {
  final List<XFile> mediaFileList;
  final dynamic pickImageError;
  String? retrieveDataError;
  LocalImagesPreview(
      {super.key,
      required this.mediaFileList,
      this.pickImageError,
      this.retrieveDataError});

  @override
  Widget build(BuildContext context) {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (mediaFileList.isNotEmpty) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.separated(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final String? mime = lookupMimeType(mediaFileList[index].path);

              // Why network for web?
              // See https://pub.dev/packages/image_picker_for_web#limitations-on-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: kIsWeb
                    ? Image.network(mediaFileList[index].path)
                    : (mime == null || mime.startsWith('image/')
                        ? Image.file(
                            File(mediaFileList[index].path),
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
            itemCount: mediaFileList.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider()),
      );
    } else if (pickImageError != null) {
      return Text(
        'Photo capture error: $pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        'You have not yet clicked any photo.',
        textAlign: TextAlign.center,
        style: MontserratFont.paragraphReg1,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (retrieveDataError != null) {
      final Text result = Text(retrieveDataError!);
      retrieveDataError = null;
      return result;
    }
    return null;
  }
}
