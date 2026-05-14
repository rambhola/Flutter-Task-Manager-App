import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import 'auth_controller.dart';

class TaskController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  var tasks = <TaskModel>[].obs;
  var quote = Rx<Map<String, dynamic>?>(null);
  var isLoadingQuote = true.obs;
  var quoteError = Rx<String?>(null);
  var isLoadingTasks = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuote();
    if (_authController.user != null) {
      tasks.bindStream(_firestoreService.getTasks(_authController.user!.uid));
    
    }
    
    ever(_authController.rxUser, (user) {
      if (user != null) {
        tasks.bindStream(_firestoreService.getTasks(user.uid));
      } else {
        tasks.clear();
      }
    });
  }

  Future<void> fetchQuote() async {
    try {
      isLoadingQuote.value = true;
      quoteError.value = null;
      final fetchedQuote = await _apiService.fetchQuote();
      quote.value = fetchedQuote;
    } catch (e) {
      quoteError.value = 'Could not load quote';
    } finally {
      isLoadingQuote.value = false;
    }
  }

  Future<void> toggleTaskStatus(TaskModel task, bool? val) async {
    await _firestoreService.toggleTaskStatus(task.id, val ?? false);
  }

  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}

