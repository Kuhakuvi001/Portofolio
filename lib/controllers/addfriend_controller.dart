import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/chat_controller.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/model/chat_model.dart';
import 'package:speakapp/model/friend_model.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/pop_up/alert_loading.dart';
import 'package:speakapp/pop_up/alert_message.dart';
import 'package:speakapp/serviceapi.dart';

class AddFriendController extends GetxController {
  late PageController pagecontroller;
  TextEditingController inputaccount = TextEditingController();

  String rs_accountname = "";
  String rs_publickey = "";

  final cFriend = Get.find<FriendController>();

  @override
  void onInit() {
    super.onInit();

    pagecontroller = PageController(initialPage: 0, viewportFraction: .8);
  }

  void validation() {
    Get.focusScope?.unfocus();

    var accountname = inputaccount.text.trim();

    if (accountname.isNotEmpty) {
      bool ketemu = false;

      var pos =
          cFriend.listfriend.indexWhere((item) => item.nama == accountname);

      if (pos >= 0) {
        cFriend.datafriend = cFriend.listfriend[pos];
        // cFriend.datafriend = cFriend.listfriend[pos];

        _moveactivity();
      } else {
        _showLoading();
        _callapi(accountname);
      }
    }
  }

  _showAlert(message) {
    Get.dialog(AlertMessage(message));
  }

  _showLoading() {
    Get.dialog(AlertLoading());
  }

  _hideLoading(String message) async {
    await Future.delayed(Duration(milliseconds: AppConfig.timeloading));
    Get.back();
    if (message == "") {
      _moveactivity();
    } else {
      _showAlert(message);
    }
  }

  _moveactivity() {
    // Get.delete<AddFriendController>();
    Get.offNamed(AppRoute.chat);
  }

  Future<bool> closeActivity() async {
    Get.delete<AddFriendController>();
    Get.back();
    return true;
  }

  _callapi(String accountname) async {
    try {
      var datares = await callapi_getaccount(accountname);
      if (datares.statusCode == 200) {
        var datajson = jsonDecode(datares.body);
        var datapb = datajson['permissions'];

        rs_accountname = datajson['account_name'];

        for (var item in datapb) {
          if (item['perm_name'] == "active") {
            rs_publickey = item['required_auth']['keys'][0]['key'];
            break;
          }
        }

        cFriend.listfriend.insert(
            0,
            FriendModel(
              nama: accountname,
              message: "",
              publickey_to: rs_publickey,
              datamassege: [].obs,
              datetime: DateTime.now().microsecondsSinceEpoch.toString(),
            ));

        var pos =
            cFriend.listfriend.indexWhere((item) => item.nama == accountname);

        cFriend.datafriend = cFriend.listfriend[pos];
        _hideLoading("");
      } else {
        _hideLoading("Account not found");
      }
    } catch (e) {
      print("ERROR ${e}");
      _hideLoading("Account not found");
    }
  }
}
