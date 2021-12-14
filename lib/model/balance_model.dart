import 'dart:convert';

class BalanceModel {
  String matauang;
  String nominal;
  String contract;

  BalanceModel({this.matauang = "", this.nominal = "", this.contract = ""});

  static List<BalanceModel> convertdata(String data) {
    List<BalanceModel> listdata = [];

    try {
      var dataobject = jsonDecode(data);
      var datajson = dataobject['balances'];

      for (var item in datajson) {
        listdata.add(BalanceModel(
          matauang: item['currency'].toString(),
          nominal: item['amount'].toString(),
          contract: item['contract'].toString(),
        ));
      }
    } catch (e) {
      print("ERROR ${e}");
    }

    return listdata;
  }
}
