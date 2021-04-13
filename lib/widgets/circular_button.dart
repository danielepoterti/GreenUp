import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../screens/transaction_screen.dart';
import 'package:green_up/services/map_helper.dart';

// ignore: must_be_immutable
class LoadingButton extends StatefulWidget {
  int index;
  LoadingButton(this.index);
  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => controller.forward(),
      onTapUp: (_) {
        if (controller.status == AnimationStatus.forward) {
          controller.reverse();
          print('press not finished');
          return Fluttertoast.showToast(
            msg: "Tieni premuto per iniziare la ricarica",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /*timeInSecForIosWeb: 1*/
          );
        } else if (controller.status == AnimationStatus.completed) {
          MapHelper.selectedForTransaction =
              MapHelper.nearbyChargePoints[widget.index];
          Navigator.of(context).push(_createRoute());
          controller.reverse();
        }
      },
      /*onTap: () => {print('tap')},*/
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            height: 56,
            width: 56,
            child: CircularProgressIndicator(
              value: 1.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
          SizedBox(
            height: 56,
            width: 56,
            child: CircularProgressIndicator(
              value: controller.value,
              valueColor:
                  AlwaysStoppedAnimation<Color>(const Color(0xff44a688)),
            ),
          ),
          Icon(
            Icons.flash_on,
            size: 36,
          )
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Transaction(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
