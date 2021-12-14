import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/chat_controller.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/model/chat_model.dart';
import 'package:speakapp/page/chat/chat_currency.dart';
import 'package:speakapp/page/chat/view_chat.dart';

import 'package:speakapp/page/chat/view_chat_wallet.dart';

class ChatPage extends StatelessWidget {
  final cChat = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.colorutama,
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
            onWillPop: cChat.closeActivity,
            child: SafeArea(
                child: Column(
              children: <Widget>[
                _toolbar(),
                _bodylayout(),
                Obx(() =>
                    (cChat.showwallet.value) ? _walletlayout() : Container()),
                _bottomlayout(),
              ],
            ))));
  }

  Widget _toolbar() {
    return Container(
        child: Row(
      children: <Widget>[
        InkWell(
            onTap: () {
              cChat.closeActivity();
            },
            child: Container(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Image.asset(
                AppImage.back,
                width: 15,
                height: 15,
                color: AppColor.colorblue_v2,
              ),
            )),
        Expanded(
            child: Container(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  cChat.cFriend.datafriend!.nama,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.colorgray,
                    fontSize: AppConfig.sizetexttoolbar,
                  ),
                ))),
        Container(
          margin: EdgeInsets.only(right: 15, top: 15),
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

  Widget _bodylayout() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: GetX<FriendController>(builder: (controller) {
            return ListView.builder(
                reverse: true,
                itemCount: controller.datafriend?.datamassege.length,
                itemBuilder: (context, pos) {
                  ChatModel datachat = controller.datafriend!.datamassege[pos];

                  return (datachat.tipe == "chat")
                      ? ViewChat(datachat)
                      : ViewChatWallet(datachat);
                });
          })),
    );
  }

  Widget _bottomlayout() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 13, bottom: 13),
        color: AppColor.colorgray_v2,
        child: Row(
          children: <Widget>[
            InkWell(
                onTap: () {
                  if (cChat.selectbalance != null) {
                    if (cChat.showwallet.value) {
                      cChat.showwallet.value = false;
                    } else {
                      cChat.showwallet.value = true;
                    }
                  }
                },
                child: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(4),
                  child: Image.asset(
                    AppImage.wallet,
                  ),
                )),
            Padding(padding: EdgeInsets.only(left: 5)),
            Container(
              width: 35,
              height: 35,
              padding: EdgeInsets.all(4),
              child: Image.asset(
                AppImage.emoji,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Expanded(
              child: TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  controller: cChat.inputmsg,
                  style: TextStyle(
                      fontSize: AppConfig.sizetextnormal,
                      fontFamily: AppFont.fontnormal,
                      color: AppColor.colorwhite),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                    border: InputBorder.none,
                    hintText: "Message...",
                    isDense: true,
                    hintStyle: TextStyle(
                      fontSize: AppConfig.sizetextnormal,
                      color: AppColor.colorwhite.withOpacity(0.8),
                    ),
                    focusedBorder: InputBorder.none,
                  )),
            ),
            InkWell(
                onTap: () {
                  cChat.validation();
                },
                child: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(4),
                  child: Image.asset(
                    AppImage.send,
                  ),
                )),
          ],
        ));
  }

  Widget _walletlayout() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            IntrinsicHeight(
                child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                  decoration: BoxDecoration(
                    color: AppColor.colorgray_v2,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(6)),
                  ),
                  child: TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      controller: cChat.inputamount,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        WhitelistingTextInputFormatter(RegExp("[.0123456789]"))
                      ],
                      style: TextStyle(
                          fontSize: AppConfig.sizetextnormal,
                          fontFamily: AppFont.fontnormal,
                          color: AppColor.colorwhite),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                        border: InputBorder.none,
                        hintText: "Amount",
                        isDense: true,
                        hintStyle: TextStyle(
                          fontSize: AppConfig.sizetextnormal,
                          color: AppColor.colorwhite.withOpacity(0.8),
                        ),
                        focusedBorder: InputBorder.none,
                      )),
                )),
                Padding(padding: EdgeInsets.only(left: 2)),
                Container(
                    decoration: BoxDecoration(
                      color: AppColor.colorgray_v2,
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(6)),
                    ),
                    child: ClipRRect(
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(5)),
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                                onTap: () {
                                  showCurrency();
                                },
                                child: Container(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Center(
                                        child: Obx(
                                      () => Text(
                                          cChat.selectbalance.value.matauang,
                                          style: TextStyle(
                                            fontSize: AppConfig.sizetextnormal,
                                            color: AppColor.colorwhite,
                                          )),
                                    ))))))),
              ],
            )),
            Padding(padding: EdgeInsets.only(top: 2)),
            Container(
              padding:
                  EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
              decoration: BoxDecoration(
                color: AppColor.colorgray_v2,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6)),
              ),
              child: TextField(
                  maxLines: 1,
                  keyboardType: TextInputType.visiblePassword,
                  controller: cChat.inputamountmsg,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  style: TextStyle(
                      fontSize: AppConfig.sizetextnormal,
                      fontFamily: AppFont.fontnormal,
                      color: AppColor.colorwhite),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                    border: InputBorder.none,
                    hintText: "Say something nice... (optional)",
                    isDense: true,
                    hintStyle: TextStyle(
                      fontSize: AppConfig.sizetextnormal,
                      color: AppColor.colorwhite.withOpacity(0.8),
                    ),
                    focusedBorder: InputBorder.none,
                  )),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            InkWell(
                onTap: () {
                  cChat.validationWallet();
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
                    "Send",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                        color: AppColor.colorwhite,
                        fontSize: AppConfig.sizelogin_btn),
                  ),
                )),
          ],
        ));
  }

  showCurrency() {
    Get.bottomSheet(ChatCurrency());
  }
}
