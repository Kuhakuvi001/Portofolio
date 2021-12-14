import 'package:flutter/material.dart';
import 'package:speakapp/config.dart';

class AlertMessage extends StatefulWidget {
  final String message;
  AlertMessage(this.message);

  @override
  State<StatefulWidget> createState() => _AlertMessage();
}

class _AlertMessage extends State<AlertMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationcontroller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationcontroller = AnimationController(
        vsync: this, duration: Duration(milliseconds: AppConfig.timeanimation));
    animation = CurvedAnimation(
        parent: animationcontroller, curve: Curves.fastOutSlowIn);
    animationcontroller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
          child: ScaleTransition(
              scale: animation,
              child: Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                padding:
                    EdgeInsets.only(top: 30, bottom: 15, left: 10, right: 10),
                decoration: BoxDecoration(
                    color: AppColor.colorwhite,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.colortext,
                            fontSize: AppConfig.sizetextjudul),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 30)),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            "retry",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColor.colorblue_v2,
                                fontSize: AppConfig.sizetextnormal),
                          ),
                        ))
                  ],
                ),
              ))),
    );
    // Material(
    //   color: Colors.transparent,
    //   child:
    // );
  }
}
