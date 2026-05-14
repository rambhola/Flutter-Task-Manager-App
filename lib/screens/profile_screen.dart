import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerBottomSheet(context, profileCtrl),
                  child: Obx(() {
                    final imagePath = profileCtrl.imagePath.value;
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imagePath.isNotEmpty
                          ? FileImage(File(imagePath)) as ImageProvider
                          : const NetworkImage('https://i.pravatar.cc/300?u=v'),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Obx(() => Text(profileCtrl.name.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                Obx(() => Text(profileCtrl.email.value, style: const TextStyle(color: Colors.grey))),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => _showEditProfileDialog(context, profileCtrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 40),
                _menuItem(Icons.person, 'Edit Profile', onTap: () => _showEditProfileDialog(context, profileCtrl)),
                _menuItem(Icons.notifications, 'Notifications'),
                _menuItem(Icons.lock, 'Security'),
                _menuItem(Icons.help, 'Help & Support'),
                const SizedBox(height: 10),
                _menuItem(Icons.logout, 'Logout', color: Colors.redAccent, onTap: () {
                  authController.logout();
                  Get.offAll(() => const LoginScreen());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  controller.pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  controller.pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileController controller) {
    final nameController = TextEditingController(text: controller.name.value);
    final emailController = TextEditingController(text: controller.email.value);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  controller.updateProfile(nameController.text, emailController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _menuItem(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.blueGrey.shade700),
            const SizedBox(width: 20),
            Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
