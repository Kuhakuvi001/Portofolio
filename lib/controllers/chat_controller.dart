import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/friend_controller.dart';
import 'package:speakapp/model/balance_model.dart';
import 'package:speakapp/model/chat_model.dart';

import 'package:eosdart/eosdart.dart' as eos;

class ChatController extends GetxController {
  final cFriend = Get.find<FriendController>();

  TextEditingController inputmsg = TextEditingController();
  TextEditingController inputamount = TextEditingController();
  TextEditingController inputamountmsg = TextEditingController();

  String publickey = "";
  String privatekey = "";
  String name = "";

  RxBool showwallet = false.obs;

  Rx<BalanceModel> selectbalance = BalanceModel().obs;

  eos.EOSClient? client;

  @override
  void onInit() {
    super.onInit();

    if (cFriend.listbalance.length > 0) {
      selectbalance.value = cFriend.listbalance[0];
    }

    _getData();
  }

  Future<bool> closeActivity() async {
    Get.delete<ChatController>();
    if (Get.previousRoute == "/") {
      Get.offNamed(AppRoute.friend);
    } else {
      Get.back();
    }
    return true;
  }

  void _getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      publickey = prefs.getString('publickey').toString();
      privatekey = prefs.getString('privatekey').toString();
      name = prefs.getString('name').toString();
    } catch (e, st) {
      print("ERROR : ${st}");
    }
  }

  void validation() {
    var datenow = DateTime.now();
    var textmsg = inputmsg.text.trim();
    var textdate = datenow.toString();
    var textid = datenow.millisecondsSinceEpoch.toString();

    if (textmsg.isNotEmpty) {
      cFriend.datafriend?.datamassege.insert(
          0,
          ChatModel.convertitem(ChatModel(
            id: textid,
            message: textmsg,
            sender: true,
            time: textdate,
            tipe: "chat",
            success: false,
          )));

      var pos = cFriend.listfriend
          .indexWhere((item) => item.nama == cFriend.datafriend?.nama);

      if (pos >= 0) {
        cFriend.listfriend[pos].datetime =
            DateTime.now().microsecondsSinceEpoch.toString();
      }

      cFriend.datafriend?.message = textmsg;
      cFriend.listfriend.sort((a, b) => b.datetime.compareTo(a.datetime));

      inputmsg.text = "";

      _sendMessage(textmsg, textid, textdate);
    }
  }

  void validationWallet() {
    var textamount = inputamount.text.trim();
    if (textamount.isNotEmpty) {
      double mAmount = (double.tryParse(textamount) ?? 0);
      double saldo = (double.tryParse(cFriend
              .listbalance[cFriend.listbalance.indexWhere(
                  (item) => item.matauang == selectbalance.value.matauang)]
              .nominal) ??
          0);

      if (mAmount > saldo) {
        _showToast("Balance is not enough");
      } else if (mAmount > 0 && (int.tryParse(textamount[0]) ?? -1) != -1) {
        if (textamount.split(".").length == 1) {
          textamount = textamount.replaceAll(".", "") + ".0000";
        }

        var datenow = DateTime.now();
        var textid = datenow.millisecondsSinceEpoch.toString();
        var textdate = datenow.toString();
        var textmemo = inputamountmsg.text.toString().trim();
        var currency = selectbalance.value.matauang;
        var quantity = textamount + " " + currency;

        if (textmemo.isEmpty) textmemo = "";

        cFriend.datafriend?.datamassege.insert(
            0,
            ChatModel.convertitem(ChatModel(
              id: textid,
              message: textmemo,
              sender: true,
              time: textdate,
              tipe: "wallet",
              nominal: textamount,
              currency: currency,
              success: false,
            )));

        cFriend.datafriend?.datetime =
            DateTime.now().microsecondsSinceEpoch.toString();
        cFriend.datafriend?.message = "Send wallet ${textamount} ${currency}";
        cFriend.listfriend.sort((a, b) => b.datetime.compareTo(a.datetime));

        _sendToken(textid, textmemo, quantity, textamount, textdate, currency);

        inputamount.text = "";
        inputamountmsg.text = "";
        showwallet.value = false;
      }
    }
  }

  void _sendMessage(String textmsg, String textid, String textdate) async {
    try {
      if (cFriend.socket?.connected == true) {
        Map datamap = AppFunction.encriptMsg(
          cFriend.datafriend!.publickey_to,
          cFriend.privatekey,
          textmsg,
          textid,
        );

        cFriend.socket?.emit("chat", {
          "refid": textid,
          "name_to": cFriend.datafriend!.nama,
          "name_from": cFriend.name,
          "pubkey_from": cFriend.publickey,
          "message": datamap,
          "pubkey_to": cFriend.datafriend!.publickey_to,
          "nominal": "0",
          "currency": "",
        });

        cFriend
            .datafriend
            ?.datamassege[cFriend.datafriend!.datamassege
                .indexWhere((item) => item.id == textid)]
            .success = true;

        _savetodatabase(textid, textmsg, textdate, "chat", null, null);
      } else {
        cFriend
            .datafriend
            ?.datamassege[cFriend.datafriend!.datamassege
                .indexWhere((item) => item.id == textid)]
            .error = true;
      }
    } catch (e, st) {
      print("ERROR : ${st}");
      cFriend
          .datafriend
          ?.datamassege[cFriend.datafriend!.datamassege
              .indexWhere((item) => item.id == textid)]
          .error = true;
      try {
        var messageError = jsonDecode(e.toString());
        _showToast(messageError['error']['what']);
      } catch (e) {}
    } finally {
      cFriend.datafriend?.datamassege.refresh();
    }

    client = null;
  }

  void _sendToken(String textid, String textmemo, String quantity,
      String textamount, String textdate, String currency) async {
    try {
      client = eos.EOSClient(AppConfig.eos_url, AppConfig.eos_ver,
          privateKeys: [privatekey]);
      client?.expirationInSec = 10;

      List<eos.Authorization> auth = [
        eos.Authorization()
          ..actor = name
          ..permission = 'active'
      ];

      Map data = {
        'from': name,
        'to': cFriend.datafriend?.nama,
        'quantity': quantity,
        'memo': textmemo
      };

      List<eos.Action> actions = [
        eos.Action()
          ..account = selectbalance.value.contract
          ..name = 'transfer'
          ..authorization = auth
          ..data = data
      ];

      eos.Transaction transaction = eos.Transaction()..actions = actions;

      var trx = await client?.pushTransaction(transaction, broadcast: true);

      if (trx != null) {
        cFriend
            .datafriend
            ?.datamassege[cFriend.datafriend!.datamassege
                .indexWhere((item) => item.id == textid)]
            .success = true;
        cFriend.callapi();

        Map datamessage = {};
        if (textmemo.isNotEmpty) {
          datamessage = AppFunction.encriptMsg(
            cFriend.datafriend!.publickey_to,
            privatekey,
            textmemo,
            textid,
          );
        }

        Map dataamount = AppFunction.encriptMsg(
          cFriend.datafriend!.publickey_to,
          privatekey,
          textamount,
          textid,
        );

        Map datacurrency = AppFunction.encriptMsg(
          cFriend.datafriend!.publickey_to,
          privatekey,
          currency,
          textid,
        );

        _sendWalletSocket(textid, (datamessage.isEmpty) ? null : datamessage,
            dataamount, datacurrency);
        _savetodatabase(
            textid, textmemo, textdate, "wallet", textamount, currency);
      }
    } catch (e) {
      cFriend
          .datafriend
          ?.datamassege[cFriend.datafriend!.datamassege
              .indexWhere((item) => item.id == textid)]
          .error = true;

      try {
        var messageError = jsonDecode(e.toString());
        _showToast(messageError['error']['what']);
      } catch (e) {}
    } finally {
      cFriend.datafriend?.datamassege.refresh();
    }

    client = null;
  }

  void _sendWalletSocket(refid, message, nominal, currency) {
    if (cFriend.socket?.connected == true) {
      cFriend.socket?.emit("wallet", {
        "refid": refid,
        "name_to": cFriend.datafriend!.nama,
        "name_from": name,
        "pubkey_from": publickey,
        "message": message,
        "pubkey_to": cFriend.datafriend!.publickey_to,
        "nominal": nominal,
        "currency": currency,
      });
    }
  }

  void _savetodatabase(refid, message, sendtime, tipe, nominal, currency) {
    var datainput = {
      "refid": refid,
      "name": cFriend.datafriend!.nama,
      "name_login": name,
      "message": message,
      "pubkey_to": cFriend.datafriend!.publickey_to,
      "sender": 1,
      "sendtime": sendtime,
      "tipe": tipe,
      "nominal": nominal,
      "currency": currency
    };
    AppFunction.saveData_toDbChat(cFriend.database, [datainput]);
  }

  void _showToast(message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColor.colorred,
      textColor: Colors.white,
      fontSize: AppConfig.sizetextnormal,
    );
  }

  void resendWallet(ChatModel datachat) {
    Get.focusScope?.unfocus();

    var datenow = DateTime.now();
    var textid = datenow.millisecondsSinceEpoch.toString();
    var textdate = datenow.toString();
    var quantity = datachat.nominal + " " + datachat.currency;

    cFriend.datafriend?.datamassege.remove(datachat);
    cFriend.datafriend?.datamassege.insert(
        0,
        ChatModel.convertitem(ChatModel(
          id: textid,
          message: datachat.message,
          sender: true,
          time: textdate,
          tipe: datachat.tipe,
          nominal: datachat.nominal,
          currency: datachat.currency,
          success: false,
        )));

    cFriend.datafriend?.datetime =
        DateTime.now().microsecondsSinceEpoch.toString();
    cFriend.datafriend?.message =
        "Send wallet ${datachat.nominal} ${datachat.currency}";
    cFriend.listfriend.sort((a, b) => b.datetime.compareTo(a.datetime));

    _sendToken(textid, datachat.message, quantity, datachat.nominal, textdate,
        datachat.currency);
  }

  void resendChat(ChatModel datachat) {
    Get.focusScope?.unfocus();

    var datenow = DateTime.now();
    var textid = datenow.millisecondsSinceEpoch.toString();
    var textdate = datenow.toString();

    cFriend.datafriend?.datamassege.remove(datachat);
    cFriend.datafriend?.datamassege.insert(
        0,
        ChatModel.convertitem(ChatModel(
          id: textid,
          message: datachat.message,
          sender: true,
          time: textdate,
          tipe: datachat.tipe,
          success: false,
        )));

    cFriend.datafriend?.datetime =
        DateTime.now().microsecondsSinceEpoch.toString();
    cFriend.datafriend?.message = datachat.message;
    cFriend.listfriend.sort((a, b) => b.datetime.compareTo(a.datetime));

    _sendMessage(datachat.message, textid, textdate);
  }
}
