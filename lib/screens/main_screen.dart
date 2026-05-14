import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'add_edit_task_screen.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  void changeIndex(int index) => currentIndex.value = index;
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    final List<Widget> screens = [
      const HomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: screens[controller.currentIndex.value],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditTaskScreen()),
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    controller: controller,
                  ),
                  const SizedBox(width: 40), // Space for Floating Action Button
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 1,
                    controller: controller,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required MainController controller,
  }) {
    final isActive = controller.currentIndex.value == index;
    return MaterialButton(
      minWidth: 40,
      onPressed: () => controller.changeIndex(index),
      splashColor: Colors.indigo.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.indigo : Colors.grey.shade600,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.indigo : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

