import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/model/balance_model.dart';
import 'package:speakapp/model/chat_model.dart';
import 'package:speakapp/model/friend_model.dart';
import 'package:speakapp/page/chat/chat.dart';
import 'package:speakapp/page/login/login.dart';
import 'package:speakapp/rumus/vex_ecc.dart';
import 'package:speakapp/serviceapi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FriendController extends GetxController {
  RxList<FriendModel> listfriend = <FriendModel>[].obs;
  List<BalanceModel> listbalance = <BalanceModel>[].obs;

  PageController? pageController;

  Database? database;
  IO.Socket? socket;
  FriendModel? datafriend;

  String privatekey = "";
  String publickey = "";
  String name = "";

  RxBool stateloading = true.obs;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: 0, viewportFraction: .8);

    getData();
  }

  @override
  void dispose() {
    print("DISPOSE");
    super.dispose();
  }

  @override
  void onClose() {
    print("================== on close ==============");
    closeController();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      privatekey = prefs.getString('privatekey').toString();
      publickey = prefs.getString('publickey').toString();
      name = prefs.getString('name').toString();
    } catch (e, st) {
      print("ERROR : ${st}");
    } finally {
      database = await AppFunction.getDatabase();
      _getDataFromDb();
      _connectSocket();
      callapi();
    }
  }

  _getDataFromDb() async {
    List<Map<String, Object?>>? listdata = await database
        ?.rawQuery("SELECT * FROM chat WHERE name_login = '${name}'");

    listdata = listdata?.reversed.toList();

    for (var item in listdata!) {
      String name = item['name'].toString();
      String pubkey_to = item['pubkey_to'].toString();
      ChatModel datatemp = ChatModel.convertdata(item, "0");

      bool ketemu = false;

      for (int i = 0; i < listfriend.length; i++) {
        if (listfriend[i].nama == item['name'].toString()) {
          ketemu = true;
          listfriend[i].datamassege.add(datatemp);
        }
      }

      if (!ketemu) {
        String msg = "";
        if (datatemp.nominal == "null" || datatemp.nominal == "") {
          msg = datatemp.message;
        } else {
          if (datatemp.sender) {
            msg = "Send wallet ${datatemp.nominal} ${datatemp.currency}";
          } else {
            msg = "Receive wallet ${datatemp.nominal} ${datatemp.currency}";
          }
        }

        RxList listdata = [].obs;
        listdata.add(datatemp);

        listfriend.add(FriendModel(
          message: msg,
          nama: name,
          publickey_to: pubkey_to,
          datamassege: listdata,
          datetime: DateTime.now().microsecondsSinceEpoch.toString(),
        ));
      }
    }
  }

  callapi() async {
    stateloading.value = true;
    try {
      http.Response res = await callapi_getbalance(name);

      if (res.statusCode == 200) {
        listbalance = BalanceModel.convertdata(res.body);
      }
    } catch (e, st) {
      print("ERROR ${st}");
    } finally {
      _hideStateLoading();
    }
  }

  _hideStateLoading() async {
    await Future.delayed(Duration(milliseconds: AppConfig.timeloading));
    stateloading.value = false;
  }

  void logout() async {
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    fcm.unsubscribeFromTopic(name);

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("name", "");
    pref.setString("name_login", "");
    pref.setString("name_login_v2", "");

    pref.remove('name');
    pref.remove('name_login');
    pref.remove('name_login_v2');

    pref.clear();

    Get.delete<FriendController>();
    Get.offAllNamed(AppRoute.login);
  }

  Future<void> refreshData() async {
    closeController();
    getData();
  }

  void closeController() {
    database?.close();
    socket?.dispose();
  }

  void _connectSocket() {
    try {
      socket = IO.io(
          AppConfig.url_socket,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());

      socket?.connect();
      socket?.onConnect((data) => print("connected"));
      socket?.on(name, (data) async {
        try {
          // === Data === //
          var refid = data['refid'].toString();
          var name_to = data['name_to'].toString();
          var name_from = data['name_from'].toString();
          var pubkey_from = data['pubkey_from'].toString();
          var time = data['time'].toString();
          var tipe = data['tipe'].toString();
          var nominal = "";
          var currency = "";

          var msg = "";
          var msg_friend = "";

          // === Check if message null === //
          // === Decrypt message === //
          if (data['message'] != null) {
            var pubkey = PublicKey.fromString(pubkey_from);
            var message = data['message']['data'].toString();
            var nonce = hexToBytes(data['message']['nonce'].toString());
            var checksum = hexToBytes(data['message']['checksum'].toString());

            var derypted = decrypt(
              PrivateKey.fromString(privatekey),
              pubkey,
              message,
              nonce: nonce,
              checksum: checksum,
            );

            msg = derypted.message;
            msg_friend = msg;
          }

          if (tipe == "wallet") {
            // ==== Decrypt Nominal ==== //
            var pubkey = PublicKey.fromString(pubkey_from);
            var nom_msg = data['nominal']['data'].toString();
            var nom_nonce = hexToBytes(data['nominal']['nonce'].toString());
            var nom_checksum =
                hexToBytes(data['nominal']['checksum'].toString());

            var nom_decry = decrypt(
              PrivateKey.fromString(privatekey),
              pubkey,
              nom_msg,
              nonce: nom_nonce,
              checksum: nom_checksum,
            );

            // ==== Decrypt Currency ==== //
            var cur_msg = data['currency']['data'].toString();
            var cur_nonce = hexToBytes(data['currency']['nonce'].toString());
            var cur_checksum =
                hexToBytes(data['currency']['checksum'].toString());

            var cur_decry = decrypt(
              PrivateKey.fromString(privatekey),
              pubkey,
              cur_msg,
              nonce: cur_nonce,
              checksum: cur_checksum,
            );

            nominal = nom_decry.message;
            currency = cur_decry.message;

            msg_friend = "Receive wallet ${nominal} ${currency}";

            callapi();
          }

          // === Cari pada list frind === //
          var pos =
              listfriend.indexWhere((item) => item.nama == data['name_from']);

          // === Insert into list friend === //
          ChatModel datains = ChatModel.convertitem(ChatModel(
            id: refid,
            message: msg.toString(),
            sender: false,
            tipe: tipe,
            nominal: nominal,
            currency: currency,
            time: time,
          ));

          var datetimenow = DateTime.now().toString();

          if (pos < 0) {
            RxList listdata = [].obs;
            listdata.add(datains);
            listfriend.insert(
                0,
                FriendModel(
                  publickey_to: pubkey_from,
                  nama: name_from,
                  message: msg,
                  datetime: datetimenow,
                  datamassege: listdata,
                ));
          } else {
            listfriend[pos].message = msg_friend;
            listfriend[pos].datetime = datetimenow;
            listfriend[pos].datamassege.insert(0, datains);
          }

          listfriend.sort((a, b) => b.datetime.compareTo(a.datetime));

          // === Save into database === //
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
          print("ERROR : ${st}");
        }
      });
    } catch (e, st) {
      print("ERROR : ${st}");
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Press again to exit",
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}
