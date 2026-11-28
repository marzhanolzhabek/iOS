
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'
as ph;

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickPhoto(ImageSource source) async {
    if (source == ImageSource.camera) {
      // macOS camera requires a custom camera delegate.
      if (!kIsWeb && Platform.isMacOS) {
        throw UnsupportedError(
          'Camera is not supported in this Mac version. '
              'Use Gallery or a real phone.',
        );
      }

      if (!kIsWeb &&
          (Platform.isAndroid || Platform.isIOS)) {
        final permission =
        await ph.Permission.camera.request();

        if (permission.isPermanentlyDenied) {
          throw StateError(
            'Camera permission is blocked. '
                'Enable it in app settings.',
          );
        }

        if (!permission.isGranted) {
          throw StateError(
            'Camera permission denied.',
          );
        }
      }
    }

    return _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
  }
}
