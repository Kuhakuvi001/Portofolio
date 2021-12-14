import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/page/addfriend/addfriend.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/page/friend/friend_ballance_loading.dart';
import 'package:speakapp/page/friend/view_ballance.dart';

class FriendPage extends StatelessWidget {
  final cFriend = Get.find<FriendController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.colorutama,
        body: WillPopScope(
            onWillPop: cFriend.onWillPop,
            child: SafeArea(
                child: Column(
              children: <Widget>[
                _toolbar(),
                _header(),
                _bodylayout(),
              ],
            ))),
        floatingActionButton: Align(
          alignment: Alignment(0.91, 0.96),
          child: FloatingActionButton(
            onPressed: () {
              Get.toNamed(AppRoute.addfriend);
            },
            child: Container(
              padding: EdgeInsets.only(left: 13, top: 13, bottom: 13, right: 7),
              child: Image.asset(
                AppImage.adduser,
                fit: BoxFit.contain,
              ),
            ),
            backgroundColor: AppColor.colorgray_v2,
          ),
        ));
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
                child: PopupMenuButton(
                  padding: EdgeInsets.zero,
                  onSelected: (selected) {
                    cFriend.logout();
                  },
                  icon: Image.asset(
                    AppImage.menu,
                    color: AppColor.colorblue_v2,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: AppColor.colortext,
                          fontSize: AppConfig.sizetextnormal,
                        ),
                      ),
                      value: 1,
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget _header() {
    return Obx(() => (cFriend.stateloading.value)
        ? FriendBallanceLoading()
        : Container(
            height: 140,
            padding: EdgeInsets.only(top: 30),
            child: PageView.builder(
                controller: cFriend.pageController,
                itemCount: cFriend.listbalance.length,
                itemBuilder: (context, pos) {
                  return ViewBallance(
                      name: cFriend.name, datamodel: cFriend.listbalance[pos]);
                })));
  }

  Widget _bodylayout() {
    return Expanded(
      child: RefreshIndicator(
          onRefresh: cFriend.refreshData,
          child: Container(
              padding: EdgeInsets.only(left: 30, right: 30, top: 40),
              child: GetX<FriendController>(builder: (controller) {
                return ListView.builder(
                    shrinkWrap: false,
                    itemCount: cFriend.listfriend.length,
                    itemBuilder: (context, pos) {
                      return Container(
                          margin: EdgeInsets.only(bottom: 18),
                          child: InkWell(
                              onTap: () {
                                cFriend.datafriend = cFriend.listfriend[pos];
                                Get.toNamed(AppRoute.chat);
                              },
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      width: 50,
                                      height: 50,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColor.colorwhite,
                                            width: 2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        AppImage.logo,
                                        color: AppColor.colorwhite,
                                      )),
                                  Padding(padding: EdgeInsets.only(left: 18)),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        cFriend.listfriend[pos].nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.colorwhite,
                                          fontSize:
                                              AppConfig.sizetextnormal + 2,
                                        ),
                                      ),
                                      Text(
                                        cFriend.listfriend[pos].message,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColor.colorgray_v3,
                                          fontSize:
                                              AppConfig.sizetextnormal - 1,
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              )));
                    });
              }))),
    );
  }
}
