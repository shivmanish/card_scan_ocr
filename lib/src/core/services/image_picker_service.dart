import 'package:image_picker/image_picker.dart';

enum ImageSourceType { camera, gallery }

abstract class ImagePickerService {
  Future<String?> pickImage(ImageSourceType source);
}

class ImagePickerServiceImpl implements ImagePickerService {
  ImagePickerServiceImpl({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickImage(ImageSourceType source) async {
    final picked = await _picker.pickImage(
      source: source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 90,
    );
    return picked?.path;
  }
}
