import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  void checkAndEnableLocation(BuildContext context, Function onSuccess) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool result = await Geolocator.openLocationSettings();
      if (result) {
        onSuccess();
      }
    } else {
      onSuccess();
    }
  }

  void onActivityResult(int requestCode, int resultCode) {
    // Handle activity result if needed
    debugPrint('LocationHelper onActivityResult: $requestCode, $resultCode');
  }
}