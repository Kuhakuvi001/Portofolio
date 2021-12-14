import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speakapp/config.dart';

class FriendBallanceLoading extends StatefulWidget {
  @override
  _FriendBallanceLoading createState() => _FriendBallanceLoading();
}

class _FriendBallanceLoading extends State<FriendBallanceLoading> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: AppColor.colorgray_v2,
        highlightColor: AppColor.colorgray_v3,
        child: Container(
            padding: EdgeInsets.only(top: 30),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  width: double.infinity,
                  height: 110,
                  margin: EdgeInsets.only(left: 40, right: 14),
                  decoration: BoxDecoration(
                      color: AppColor.colorwhite.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 170,
                        height: 20,
                        decoration: BoxDecoration(
                            color: AppColor.colorwhite.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Container(
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                            color: AppColor.colorwhite.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6)),
                      )
                    ],
                  ),
                )),
                Container(
                  width: 40,
                  height: 110,
                  decoration: BoxDecoration(
                      color: AppColor.colorwhite.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      )),
                )
              ],
            )));
  }
}
