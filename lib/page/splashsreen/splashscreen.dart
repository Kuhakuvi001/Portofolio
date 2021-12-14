import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/page/friend/friend.dart';
import 'package:speakapp/page/login/login.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPage createState() => _SplashScreenPage();
}

class _SplashScreenPage extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Get.focusScope?.unfocus();
    _getDatabase();
    _checkdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorutama,
      body: Center(
        child: Image.asset(
          AppImage.logo,
          width: 80,
          height: 80,
          color: AppColor.colorwhite,
        ),
      ),
    );
  }

  _getDatabase() async {
    Database? database = await AppFunction.getDatabase();
    database?.close();
  }

  _checkdata() async {
    await Future.delayed(Duration(seconds: 2));
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var name = prefs.get("name_login_v2");

      if (name == null || name.toString() == "" || name.toString() == "null") {
        Get.offNamed(AppRoute.login);
      } else {
        Get.offNamed(AppRoute.friend);
      }
    } catch (e, st) {
      print("ERROR : ${st}");
      Get.offNamed(AppRoute.login);
    }
  }
}
