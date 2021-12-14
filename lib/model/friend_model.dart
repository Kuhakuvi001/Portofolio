import 'package:get/get.dart';
import 'package:speakapp/model/chat_model.dart';

class FriendModel {
  String publickey_to;
  String nama;
  String message;
  RxList datamassege = [].obs;
  String datetime;

  FriendModel({
    this.publickey_to = "",
    this.nama = "",
    this.message = "",
    required this.datamassege,
    this.datetime = "",
  });
}
