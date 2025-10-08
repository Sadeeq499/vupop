import 'package:permission_handler/permission_handler.dart';
import 'package:socials_app/utils/common_code.dart';

class PermissionsService {
  Future<bool> _requestPermission(Permission permission) async {
    final result = await permission.request();
    if (result.isGranted) {
      return true;
    }
    if (result.isLimited) {
      return true;
    }
    if (result.isPermanentlyDenied) {
      printLogs("Permission permanently denied");
      // openAppSettings();
    }
    if (result.isDenied) {
      printLogs("Permission denied");
    }
    return false;
  }

  Future<bool> requestReadPhoneStatePermission({required Function onPermissionGranted, required Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.phone);
    if (!granted) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }
    return granted;
  }

  Future<bool> hasReadPhoneStatePermission() async {
    return hasPermission(Permission.phone);
  }

  Future<bool> requestCameraPermission({required Function onPermissionGranted, required Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.camera);

    if (!granted) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }
    return granted;
  }

  Future<bool> requestPhotoVideoPermission({required Function onPermissionGranted, required Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.photos);
    var grantedVideo = await _requestPermission(Permission.videos);
    var grantedAudio = await _requestPermission(Permission.microphone);
    // var grantedAudio = await _requestPermission(Permission.audio);

    if (!granted || !grantedVideo || !grantedAudio) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }
    return granted || grantedVideo;
  }

  Future<bool> hasCameraPermission() async {
    return hasPermission(Permission.camera);
  }

  Future<bool> hasPermission(Permission permission) async {
    var permissionStatus = await permission.isGranted;
    return permissionStatus;
  }

  Future<bool> requestPhotoAccessPermission({required Function onPermissionGranted, required Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.photos);
    if (!granted) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }
    return granted;
  }

  Future<bool> hasPhotoAccessPermission() async {
    return await hasPermission(Permission.photos) && await hasPermission(Permission.storage);
  }

  Future<bool> requestStoragePermission({required Function onPermissionGranted, required Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.storage);

    if (!granted) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }
    return granted;
  }

  Future<bool> hasStoragePermission() async {
    bool havePermission = await hasPermission(Permission.storage);
    print('=========hasStoragePermission $havePermission');
    return havePermission;
  }

  static Future<bool> requestPhotosPermission() async {
    // Use storage for Android < 13 and photos/media for Android 13+
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }
}
