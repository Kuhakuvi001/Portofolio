import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/rumus/vex_ecc.dart';
import 'package:sqflite/sqflite.dart';

class NotificationService {
  NotificationService._internal();
  FirebaseMessaging? _fcm;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'newchannel',
    'Default Notification',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> init() async {
    _firebaseConfig();
  }

  _firebaseConfig() async {
    await Firebase.initializeApp();

    _fcm = FirebaseMessaging.instance;

    await _fcm?.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotifications(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message");
    showNotifications(message);
  }

  Future<void> showNotifications(remoteMessage) async {
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

      await flutterLocalNotificationsPlugin.show(
        Random().nextInt(999) + 100,
        name_from,
        msg_show,
        NotificationDetails(android: _androidNotificationDetails),
      );

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
}

Future selectNotification(String? payload) async {
  print(payload);
  print("SELECT");
}
