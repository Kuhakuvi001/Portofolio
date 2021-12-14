import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:speakapp/rumus/vex_ecc.dart';
import 'package:sqflite/sqflite.dart';

class AppFont {
  AppFont._();
  static const String fontnormal = 'OpenSans';
}

class AppImage {
  AppImage._();
  static const String url = 'assets/images/';
  static const String logo = url + 'logo.png';
  static const String menu = url + 'menu.png';
  static const String adduser = url + 'addcontact.png';
  static const String wallet = url + 'wallet.png';
  static const String emoji = url + 'emoji.png';
  static const String send = url + 'send.png';
  static const String success = url + 'success.png';
  static const String pending = url + 'pending.png';
  static const String failed = url + 'failed.png';
  static const String reload = url + 'reload.png';
  static const String back = url + 'back.png';
}

class AppColor {
  AppColor._();
  static const Color colortext = Color(0xFF414a52);
  static const Color colorgray = Color(0xFFdedede);
  static const Color colorgray_v2 = Color(0xFF403D58);
  static const Color colorgray_v3 = Color(0xFFABAAB4);
  static const Color coloryellow = Color(0xFFffae29);
  static const Color colorwhite = Color(0xFFFFFFFF);
  static const Color colorutama = Color(0xFF161B2F);
  static const Color colorblue = Color(0xFF5C51D4);
  static const Color colorblue_v2 = Color(0xFF4FB1FF);
  static const Color colorblue_v3 = Color(0xFF1998FF);
  static const Color colorred = Color(0xFFFE3649);
}

class AppConfig {
  AppConfig._();
  static const double sizetextlogo = 20;
  static const double sizetextnormal = 14;
  static const double sizetextjudul = 18;
  static const double sizetexttoolbar = 16;
  static const double sizelogin = 35;
  static const double sizelogin_sub = 20;
  static const double sizelogin_btn = 16;
  static const double sizemsgsaldo = 25;

  static const dateformat_send = 'MMM, dd yyyy hh:mma';
  static const numberformat = '##,#0.0000';
  // static const urlapi = 'https://vexascan.com/api/v1/';
  static const urlapi = 'https://explorer.vexanium.com/api/v1/';
  static const urlapi_v2 = 'https://explorer.vexanium.com:6960/v1/chain/';
  static const eos_url = 'https://explorer.vexanium.com:6960';
  static const eos_ver = 'v1';
  static const url_socket = 'http://66.94.125.9:5400';

  static const int timeanimation = 400;
  static const int timeout = 10;
  static const int timeloading = 300;

  static const int dbversion = 13;
  static const String dbname = "chatdatabase_v2.db";
  static const String tablechat = "chat";

  static const String query_create_table_chat = """
        CREATE TABLE chat(
          refid TEXT PRIMARY KEY, 
          name TEXT, 
          name_login TEXT,
          message TEXT, 
          pubkey_to TEXT,
          tipe TEXT,
          nominal TEXT,
          currency TEXT,
          sender INTEGER, 
          sendtime DATETIME
        )
      """;
  static const String query_delete_table_chat = "DROP TABLE IF EXISTS chat";
}

class AppFunction {
  AppFunction._();
  static String numberformat(int number) {
    return NumberFormat("#,###").format(number);
  }

  static String numberformat_v2(String number) {
    return NumberFormat("#,###.0").format(double.tryParse(number) ?? 0);
  }

  static numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }

  static String getPublicKey(String private) {
    print("============== TEST ============");
    try {
      PrivateKey pvt = PrivateKey.fromString(private);
      return pvt.toPublic().toString();
    } catch (e) {
      return "";
    }
  }

  static Map encriptMsg(
    String pubkey_to,
    String prvkey,
    String message,
    String idmsg,
  ) {
    Map res = {
      "data": "",
      "nonce": "",
      "checksum": "",
      "refid": idmsg,
    };

    try {
      var encrypted = encrypt(
        PrivateKey.fromString(prvkey),
        PublicKey.fromString(pubkey_to),
        message,
      );

      res['nonce'] = bytesToHex(encrypted.nonce);
      res['checksum'] = bytesToHex(encrypted.checksum);
      res['data'] = encrypted.message;
    } catch (e, st) {
      print("ERROR ${st}");
    }

    return res;
  }

  static Future<Database?> getDatabase() async {
    try {
      return openDatabase(
        join(await getDatabasesPath(), AppConfig.dbname),
        onUpgrade: (db, oldVersion, newVersion) async {
          if (newVersion > oldVersion) {
            var batch = db.batch();
            batch.execute(AppConfig.query_delete_table_chat);
            batch.execute(AppConfig.query_create_table_chat);
            await batch.commit();
          }
        },
        onCreate: (db, version) {
          return db.execute(AppConfig.query_create_table_chat);
        },
        version: AppConfig.dbversion,
      );
    } catch (e) {
      print("ERROR CREATE DB");
      return null;
    }
  }

  static saveData_toDbChat(
      Database? database, List<Map<String, dynamic>> data) async {
    try {
      Batch? batch = database?.batch();
      data = data.reversed.toList();
      for (var item in data) {
        batch?.insert(AppConfig.tablechat, item);
      }
      await batch?.commit(noResult: true, continueOnError: true);
    } catch (e, st) {
      print("ERROR INSERT DB TO CHAT ${st}");
    }
  }
}

abstract class AppRoute {
  static String splashcreen = "/";
  static String login = "/login";
  static String friend = "/friend";
  static String addfriend = "/addfriend";
  static String chat = "/chat";
}
