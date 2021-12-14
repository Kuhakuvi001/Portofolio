import 'package:intl/intl.dart';
import 'package:speakapp/config.dart';

class ChatModel {
  String id;
  String message;
  String time;
  bool sender;
  String tipe;
  String nominal;
  String currency;
  bool success;
  bool error;

  ChatModel({
    this.id = "",
    this.message = "",
    this.time = "",
    this.sender = true,
    this.tipe = "",
    this.nominal = "0",
    this.currency = "",
    this.success = true,
    this.error = false,
  });

  static ChatModel convertdata(Map data, String status) {
    return ChatModel.convertitem(ChatModel(
      id: data['refid'].toString(),
      message: data['message'].toString(),
      tipe: data['tipe'].toString(),
      nominal: data['nominal'].toString(),
      currency: data['currency'].toString(),
      sender: int.parse(data['sender'].toString()) == 0 ? false : true,
      time: data['sendtime'].toString(),
    ));
  }

  static ChatModel convertitem(ChatModel data) {
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(data.time.replaceAll("T", " "));

    var outputFormat = DateFormat('MMM, dd yyyy HH:mma');
    var outputDate = outputFormat.format(inputDate);

    data.time = outputDate;

    return data;
  }
}
