import 'package:get/get.dart';
import 'package:speakapp/controllers/chat_controller.dart';
import 'package:speakapp/page/chat/chat.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ChatController());
  }
}
