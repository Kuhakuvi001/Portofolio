import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speakapp/config.dart';
import 'package:speakapp/model/balance_model.dart';

class ViewBallance extends StatefulWidget {
  final BalanceModel datamodel;
  final String name;

  const ViewBallance({
    Key? key,
    required this.datamodel,
    required this.name,
  }) : super(key: key);

  @override
  _ViewBallance createState() => _ViewBallance();
}

class _ViewBallance extends State<ViewBallance> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColor.colorblue,
                  AppColor.colorblue_v2,
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "welcome, ",
                  style: TextStyle(
                    color: AppColor.colorwhite,
                    fontSize: AppConfig.sizetextnormal,
                  ),
                ),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.colorwhite,
                    fontSize: AppConfig.sizetextnormal,
                  ),
                ),
              ],
            ),
            Text(
              "${widget.datamodel.nominal} ${widget.datamodel.matauang}",
              style: TextStyle(
                color: AppColor.colorwhite,
                fontSize: AppConfig.sizemsgsaldo,
              ),
            )
          ],
        ));
  }
}
