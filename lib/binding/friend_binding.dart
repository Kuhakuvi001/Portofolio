import 'package:get/get.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/page/friend/friend.dart';

class FriendBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(FriendController());
  }
}
