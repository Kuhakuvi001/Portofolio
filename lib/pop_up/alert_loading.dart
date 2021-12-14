import 'package:flutter/material.dart';
import 'package:speakapp/config.dart';

class AlertLoading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AlertLoading();
}

class _AlertLoading extends State<AlertLoading>
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
                padding: EdgeInsets.only(top: 20, bottom: 15),
                decoration: BoxDecoration(
                    color: AppColor.colorwhite,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Please wait",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.colortext,
                            fontSize: AppConfig.sizetextjudul),
                      ),
                    ),
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
