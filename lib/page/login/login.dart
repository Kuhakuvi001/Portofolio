import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/page/friend/friend.dart';
import 'package:speakapp/pop_up/alert_loading.dart';
import 'package:speakapp/pop_up/alert_message.dart';
import 'package:speakapp/serviceapi.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController inputprivatekey = new TextEditingController();
  // ..text =
  // "5KD5JAadr4rpC158bT8kSsBzLXz5Uske5MgdtkbHXjrUByw5ZRc"; //account baru
  // ..text = "5HwD3t4nMPZGXinetCSNrZYYXVhcjkGwzYvkWYeFESeKBSvWng1"; //speak3
  // ..text = "5JDuqipR586mAyr19H7xKRfAZujc9weSqniHLbr58ncyUFvPgjb"; //speak2
  // ..text = "5JQpDvL89fTchMDQc2fLTUJFAz18RtzRAC8GCu8SrFhgHg4vBKy"; //speak1

  String privatekey = "", publickey = "", name = "";

  FirebaseMessaging? _fcm;

  @override
  void initState() {
    super.initState();
    _fcm = FirebaseMessaging.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.colorutama,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
          children: <Widget>[
            ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 300),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      AppImage.logo,
                      width: 150,
                      height: 150,
                      color: AppColor.colorwhite,
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Text(
                      "SPEAKAPP",
                      style: TextStyle(
                          letterSpacing: 6,
                          fontWeight: FontWeight.w600,
                          color: AppColor.colorwhite,
                          fontSize: AppConfig.sizelogin),
                    ),
                    Text(
                      "Real. Freedom!",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.colorwhite,
                          fontSize: AppConfig.sizelogin_sub),
                    )
                  ],
                ))),
            Container(
              padding: EdgeInsets.only(left: 25, right: 25, bottom: 20),
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                          color: AppColor.colorgray_v2,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          )),
                      child: TextField(
                          obscureText: true,
                          controller: inputprivatekey,
                          maxLines: 1,
                          keyboardType: TextInputType.visiblePassword,
                          style: TextStyle(
                              fontSize: AppConfig.sizetextnormal,
                              fontFamily: AppFont.fontnormal,
                              color: AppColor.colorgray_v3),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                            border: InputBorder.none,
                            hintText: "Import your private key",
                            isDense: true,
                            hintStyle: TextStyle(
                                fontSize: AppConfig.sizetextnormal - 1,
                                color: AppColor.colorgray_v3),
                            focusedBorder: InputBorder.none,
                          ))),
                  Padding(padding: EdgeInsets.only(top: 15)),
                  InkWell(
                      onTap: () {
                        _validation();
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
                          "Confirm",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              color: AppColor.colorwhite,
                              fontSize: AppConfig.sizelogin_btn),
                        ),
                      )),
                  Padding(padding: EdgeInsets.only(top: 25)),
                  Text(
                    "Private keys never leave your device.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: AppColor.colorwhite,
                        fontSize: AppConfig.sizetextnormal - 2),
                  ),
                  Padding(padding: EdgeInsets.only(top: 25)),
                  Container(
                      padding: EdgeInsets.only(left: 14, right: 14),
                      child: Text(
                        "If yout have created account with you private key by Vex Wallet or other wallet, please import your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorgray_v3,
                            fontSize: AppConfig.sizetextnormal - 3),
                      )),
                  Padding(padding: EdgeInsets.only(top: 10)),
                ],
              ),
            )
          ],
        ))));
  }

  _validation() {
    FocusScope.of(context).unfocus();

    setState(() {
      privatekey = inputprivatekey.text.trim();
      publickey = AppFunction.getPublicKey(privatekey);
    });

    if (publickey.isNotEmpty) {
      _callapi();
    } else {
      _showAlert("Account not found");
    }
  }

  _savedata() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('privatekey', privatekey);
      prefs.setString('publickey', publickey);

      var namesave = (name.isEmpty) ? "" : name;

      prefs.setString('name', namesave);
      prefs.setString('name_login', namesave);
      prefs.setString('name_login_v2', namesave);
    }).catchError((e) {
      print("ERROR : ${e}");
    }).whenComplete(() {
      _moveactivity();
    });
  }

  _moveactivity() {
    Get.offNamed(AppRoute.friend);
  }

  _showAlert(message) {
    showDialog(context: context, builder: (_) => AlertMessage(message));
  }

  _showLoading() {
    showDialog(context: context, builder: (_) => AlertLoading());
  }

  _hideLoading(String message) {
    Timer(Duration(milliseconds: AppConfig.timeloading), () {
      Navigator.of(context).pop();
      if (message == "") {
        _fcm?.subscribeToTopic(name);
        _savedata();
      } else {
        _showAlert(message);
      }
    });
  }

  _callapi() {
    _showLoading();

    callapi_getname(publickey).then((res) {
      if (res.statusCode == 200) {
        var datajson = jsonDecode(res.body);

        setState(() {
          name = datajson['account_names'][0];
        });

        _hideLoading("");
      } else {
        _hideLoading("Failed get data, please try again");
      }
    }).catchError((e) {
      print("ERROR ${e}");
      _hideLoading("Failed get data, please try again");
    });
  }
}
