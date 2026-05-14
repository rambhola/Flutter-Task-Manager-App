import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final name = 'user'.obs;
  final email = 'user123@gmail.com'.obs;
  final imagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('user_name') ?? 'user';
    email.value = prefs.getString('user_email') ?? 'user123@gmail.com';
    imagePath.value = prefs.getString('user_image') ?? '';
  }

  Future<void> updateProfile(String newName, String newEmail) async {
    name.value = newName;
    email.value = newEmail;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_email', newEmail);
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', pickedFile.path);
    }
  }
}
