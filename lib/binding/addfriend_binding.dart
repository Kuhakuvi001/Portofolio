import 'package:get/get.dart';
import 'package:speakapp/controllers/addfriend_controller.dart';

class AddFriendBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AddFriendController());
  }
}
