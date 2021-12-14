import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/controllers/chat_controller.dart';
import 'package:speakapp/model/chat_model.dart';

class ViewChatWallet extends StatelessWidget {
  final ChatModel datachat;

  ViewChatWallet(this.datachat);

  ChatController cChat = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: (datachat.sender)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (datachat.error)
                  InkWell(
                      onTap: () {
                        cChat.resendWallet(datachat);
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 5, right: 10),
                          child: Image.asset(
                            AppImage.reload,
                            width: 13,
                            height: 13,
                            color: AppColor.colorwhite,
                          ))),
                Flexible(
                    child: Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: (datachat.success) ? 15 : 6,
                          top: 8,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                            color: (datachat.sender)
                                ? AppColor.colorblue
                                : AppColor.colorblue_v3,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                              bottomLeft: (datachat.sender)
                                  ? Radius.circular(6)
                                  : Radius.circular(0),
                              bottomRight: (datachat.sender)
                                  ? Radius.circular(0)
                                  : Radius.circular(6),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  datachat.nominal + " " + datachat.currency,
                                  textAlign: (datachat.sender)
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.colorwhite,
                                    fontSize: AppConfig.sizetextnormal + 5,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: 2)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      (datachat.sender)
                                          ? "send to "
                                          : "send from ",
                                      style: TextStyle(
                                        color: AppColor.colorwhite,
                                        fontSize: AppConfig.sizetextnormal - 3,
                                      ),
                                    ),
                                    Text(
                                      cChat.cFriend.datafriend!.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.colorwhite,
                                        fontSize: AppConfig.sizetextnormal - 3,
                                      ),
                                    ),
                                  ],
                                ),
                                if (datachat.message.isNotEmpty)
                                  Padding(
                                      padding: EdgeInsets.only(top: 1),
                                      child: Text(
                                        datachat.message,
                                        textAlign: (datachat.sender)
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        style: TextStyle(
                                          color: AppColor.colorwhite,
                                          fontSize:
                                              AppConfig.sizetextnormal - 5,
                                        ),
                                      )),
                              ],
                            )),
                            if (datachat.sender && !datachat.success)
                              Container(
                                  width: 13,
                                  height: 13,
                                  margin: EdgeInsets.only(left: 8),
                                  child: Image.asset(
                                    (datachat.error)
                                        ? AppImage.failed
                                        : AppImage.pending,
                                    color: (datachat.error)
                                        ? AppColor.colorred
                                        : AppColor.colorwhite,
                                  )),
                          ],
                        ))),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Text(
              datachat.time,
              style: TextStyle(
                color: AppColor.colorwhite.withOpacity(0.8),
                fontSize: AppConfig.sizetextnormal - 4,
              ),
            ),
          ],
        ));
  }
}
