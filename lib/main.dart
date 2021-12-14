import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/binding/addfriend_binding.dart';
import 'package:speakapp/binding/chat_binding.dart';
import 'package:speakapp/binding/friend_binding.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/notif_service.dart';
import 'package:speakapp/page/addfriend/addfriend.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/page/friend/friend.dart';
import 'package:speakapp/page/login/login.dart';
import 'package:speakapp/page/splashsreen/splashscreen.dart';
import 'package:speakapp/rumus/vex_ecc.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  await _notifconfig();
  await _firebaseConfig();

  runApp(MyApp());
}

FriendController? controller;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationDetails _androidNotificationDetails =
    AndroidNotificationDetails(
  'newchannel',
  'Default Notification',
  playSound: true,
  priority: Priority.high,
  importance: Importance.high,
);

_firebaseConfig() async {
  await Firebase.initializeApp();

  FirebaseMessaging fcm = FirebaseMessaging.instance;

  await fcm.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotifications(message, "FOREGROUND");
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  showNotifications(message, "BACKGROUND");
}

_notifconfig() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icon');

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: null, macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

Future selectNotification(String? payload) async {
  try {
    Map datapy = jsonDecode(payload!);
    if (datapy['tipe'] == "FOREGROUND") {
      final cFriend = Get.find<FriendController>();

      var named = Get.currentRoute;

      switch (named) {
        case "/friend":
          cFriend.datafriend = cFriend.listfriend[cFriend.listfriend
              .indexWhere((item) => item.nama == datapy['name'])];
          Get.toNamed(AppRoute.chat);
          break;
        case "/addfriend":
          cFriend.datafriend = cFriend.listfriend[cFriend.listfriend
              .indexWhere((item) => item.nama == datapy['name'])];

          Get.offNamed(AppRoute.chat);
          break;
      }
    } else if (datapy['tipe'] == "BACKGROUND") {
      var named = Get.currentRoute;
      switch (named) {
        case "/friend":
          final cFriend = Get.find<FriendController>();
          cFriend.datafriend = cFriend.listfriend[cFriend.listfriend
              .indexWhere((item) => item.nama == datapy['name'])];
          Get.toNamed(AppRoute.chat);
          break;
        case "/addfriend":
          final cFriend = Get.find<FriendController>();
          cFriend.datafriend = cFriend.listfriend[cFriend.listfriend
              .indexWhere((item) => item.nama == datapy['name'])];
          Get.offNamed(AppRoute.chat);
          break;
      }

      // var prefs = await SharedPreferences.getInstance();
      // prefs.setString("background", datapy['name']);
    }
  } catch (e, st) {
    print("ERROR : ${st}");
  }
}

Future<void> showNotifications(remoteMessage, tipepayload) async {
  try {
    var prefs = await SharedPreferences.getInstance();

    String privatekey = prefs.getString('privatekey').toString();

    Map<String, dynamic> data = remoteMessage.data;

    var refid = data['refid'].toString();
    var name_to = data['name_to'].toString();
    var name_from = data['name_from'].toString();
    var pubkey_from = data['pubkey_from'].toString();
    var time = data['time'].toString();
    var tipe = data['tipe'].toString();
    var nominal = "";
    var currency = "";

    var msg = "";
    var msg_show = "";

    // === Check if message null === //
    // === Decrypt message === //
    if (data['message'] != null) {
      Map<String, dynamic> body =
          jsonDecode(remoteMessage.data['message'].toString());

      var pubkey = PublicKey.fromString(pubkey_from);
      var message = body['data'].toString();
      var nonce = hexToBytes(body['nonce'].toString());
      var checksum = hexToBytes(body['checksum'].toString());

      var derypted = decrypt(
        PrivateKey.fromString(privatekey),
        pubkey,
        message,
        nonce: nonce,
        checksum: checksum,
      );

      msg = derypted.message;
      msg_show = msg;
    }

    if (tipe == "wallet") {
      var pubkey = PublicKey.fromString(pubkey_from);

      // ==== Decrypt Nominal ==== //
      Map<String, dynamic> nom_body =
          jsonDecode(remoteMessage.data['nominal'].toString());
      var nom_msg = nom_body['data'].toString();
      var nom_nonce = hexToBytes(nom_body['nonce'].toString());
      var nom_checksum = hexToBytes(nom_body['checksum'].toString());

      var nom_decry = decrypt(
        PrivateKey.fromString(privatekey),
        pubkey,
        nom_msg,
        nonce: nom_nonce,
        checksum: nom_checksum,
      );

      // ==== Decrypt Currency ==== //
      Map<String, dynamic> cur_body =
          jsonDecode(remoteMessage.data['currency'].toString());

      var cur_msg = cur_body['data'].toString();
      var cur_nonce = hexToBytes(cur_body['nonce'].toString());
      var cur_checksum = hexToBytes(cur_body['checksum'].toString());

      var cur_decry = decrypt(
        PrivateKey.fromString(privatekey),
        pubkey,
        cur_msg,
        nonce: cur_nonce,
        checksum: cur_checksum,
      );

      nominal = nom_decry.message;
      currency = cur_decry.message;
      msg_show = "Receive wallet ${nominal} ${currency}";
    }

    Map payload = {"tipe": tipepayload, "name": name_from};

    await flutterLocalNotificationsPlugin.show(
        Random().nextInt(999) + 100,
        name_from,
        msg_show,
        NotificationDetails(android: _androidNotificationDetails),
        payload: jsonEncode(payload));

    Database? database = await AppFunction.getDatabase();

    var datainput = {
      "refid": refid,
      "name": name_from,
      "name_login": name_to,
      "message": msg,
      "pubkey_to": pubkey_from,
      "sender": 0,
      "sendtime": time,
      "tipe": tipe,
      "nominal": nominal,
      "currency": currency
    };
    await AppFunction.saveData_toDbChat(database, [datainput]);
  } catch (e, st) {
    print("ERROR SHOW MESSAGE : ${st}");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: AppFont.fontnormal,
      ),
      home: SplashScreenPage(),
      getPages: [
        GetPage(
          name: AppRoute.splashcreen,
          page: () => SplashScreenPage(),
        ),
        GetPage(
          name: AppRoute.login,
          page: () => LoginPage(),
        ),
        GetPage(
          name: AppRoute.friend,
          page: () => FriendPage(),
          binding: FriendBinding(),
        ),
        GetPage(
          name: AppRoute.addfriend,
          page: () => AddFriendPage(),
          binding: AddFriendBinding(),
        ),
        GetPage(
          name: AppRoute.chat,
          page: () => ChatPage(),
          binding: ChatBinding(),
        )
      ],
    );
  }
}
