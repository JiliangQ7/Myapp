import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/Menus/controllers/user_prefs.dart';

class HomeController {
  final String username;

  HomeController(this.username);

  Future<String?> loadProfileImage() async {
    return await UserPrefs.getProfileImagePath(username);
  }

  Future<String?> changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedFile == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${username}_profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

    await UserPrefs.setProfileImagePath(username, savedImage.path);
    return savedImage.path;
  }
}
