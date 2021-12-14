// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/chat_controller.dart';
import 'package:speakapp/controllers/friend_controller.dart';

class ChatCurrency extends StatelessWidget {
  final cFriend = Get.find<FriendController>();
  final cChat = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
        decoration: BoxDecoration(
            color: AppColor.colorutama,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
                child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                  color: AppColor.colorgray_v3,
                  borderRadius: BorderRadius.circular(3)),
            )),
            Padding(padding: EdgeInsets.only(top: 15)),
            Text(
              "Select wallet !",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppConfig.sizetextnormal + 2,
                color: AppColor.colorwhite.withOpacity(0.8),
              ),
            ),
            Expanded(
                child: GridView.builder(
                    padding: EdgeInsets.only(top: 15),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 3 / 2,
                      crossAxisCount: 4,
                    ),
                    itemCount: cFriend.listbalance.length,
                    itemBuilder: (context, pos) {
                      return Container(
                          margin:
                              EdgeInsets.only(bottom: 15, left: 7, right: 7),
                          decoration: BoxDecoration(
                            color: AppColor.colorgray_v2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () {
                                        cChat.selectbalance.value =
                                            cFriend.listbalance[pos];

                                        Get.back();
                                      },
                                      child: Center(
                                          child: Text(
                                        cFriend.listbalance[pos].matauang,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                              AppConfig.sizetextnormal + 1,
                                          color: AppColor.colorwhite,
                                        ),
                                      ))))));
                    }))
          ],
        ));
  }
}
