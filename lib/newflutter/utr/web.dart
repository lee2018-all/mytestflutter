/*
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UtrViewModel extends GetxController {
  Future<String?> pickImageWeb() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb, // Web 端需要获取数据
      );

      Uint8List? fileBytes = result?.files.first.bytes as Uint8List?;
      if (fileBytes != null) {
        await _uploadImageWeb(fileBytes, result?.files.first.name);
      }
    } catch (e) {
      print('Pick image error: $e');

        EasyLoading.showError('Failed to pick image');
      }
    return null;
    }
  }
}*/
