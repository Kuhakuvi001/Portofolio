import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/addfriend_controller.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/page/friend/friend_ballance_loading.dart';
import 'package:speakapp/page/friend/view_ballance.dart';

class AddFriendPage extends StatelessWidget {
  final cAddFriend = Get.find<AddFriendController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.colorutama,
        body: WillPopScope(
            onWillPop: cAddFriend.closeActivity,
            child: SafeArea(
                child: Column(
              children: <Widget>[
                _toolbar(),
                _header(),
                Expanded(
                  child: Container(),
                ),
                _bodylayout(),
              ],
            ))));
  }

  Widget _toolbar() {
    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 15,
              height: 15,
            ),
            Expanded(
                child: Text(
              "speakapp",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.colorgray,
                fontSize: AppConfig.sizetexttoolbar,
              ),
            )),
            Container(
              margin: EdgeInsets.only(right: 10),
              width: 15,
              height: 15,
              child: Image.asset(
                AppImage.menu,
                color: AppColor.colorblue_v2,
              ),
            ),
          ],
        ));
  }

  Widget _header() {
    return GetX<FriendController>(
        builder: (controller) => (controller.stateloading.value)
            ? FriendBallanceLoading()
            : Container(
                height: 140,
                padding: EdgeInsets.only(top: 30),
                child: PageView.builder(
                    controller: cAddFriend.pagecontroller,
                    itemCount: controller.listbalance.length,
                    itemBuilder: (context, pos) {
                      return ViewBallance(
                          name: controller.name,
                          datamodel: controller.listbalance[pos]);
                    })));
  }

  Widget _bodylayout() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 90),
      child: Column(
        children: <Widget>[
          Text(
            "Welcome to Speakapp",
            style: TextStyle(
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: AppColor.colorwhite,
              fontSize: AppConfig.sizetextnormal + 3,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 3)),
          Text(
            "Vexanium's Whisper messaging protocol",
            style: TextStyle(
              color: AppColor.colorgray_v3,
              fontSize: AppConfig.sizetextnormal - 1,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 40)),
          Container(
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 13, bottom: 13),
              decoration: BoxDecoration(
                  color: AppColor.colorgray_v2,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  )),
              child: TextField(
                  controller: cAddFriend.inputaccount,
                  maxLines: 1,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  style: TextStyle(
                      fontSize: AppConfig.sizetextnormal,
                      fontFamily: AppFont.fontnormal,
                      color: AppColor.colorgray_v3),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                    border: InputBorder.none,
                    hintText: "Account name",
                    isDense: true,
                    hintStyle: TextStyle(
                        fontSize: AppConfig.sizetextnormal - 1,
                        color: AppColor.colorgray_v3),
                    focusedBorder: InputBorder.none,
                  ))),
          Padding(padding: EdgeInsets.only(top: 15)),
          InkWell(
              onTap: () {
                cAddFriend.validation();
              },
              child: Container(
                padding: EdgeInsets.only(top: 13, bottom: 13),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColor.colorblue,
                          AppColor.colorblue_v2,
                        ])),
                child: Text(
                  "Invite friends",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: AppColor.colorwhite,
                      fontSize: AppConfig.sizelogin_btn),
                ),
              )),
        ],
      ),
    );
  }
}
