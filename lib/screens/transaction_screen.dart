import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:green_up/services/map_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction>
    with SingleTickerProviderStateMixin {
  GifController controllerGif;
  RoundedLoadingButtonController btnController;

  void doSomething() async {
    Timer(Duration(seconds: 3), () {
      btnController.success();
      Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    });
  }

  @override
  void initState() {
    controllerGif = GifController(vsync: this);
    btnController = RoundedLoadingButtonController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllerGif.repeat(min: 0, max: 185, period: Duration(seconds: 4));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SizedBox(
            child: GifImage(
              controller: controllerGif,
              image: MapHelper.chargingGif,
            ),
          ),
          Container(
            child: Padding(
              padding:  EdgeInsets.only(left: 30, bottom:  MediaQuery.of(context).size.height/3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    MapHelper.selectedForTransaction.address.city,
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    MapHelper.selectedForTransaction.address.street,
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: RoundedLoadingButton(
                    successColor: const Color(0xff44a688),
                    color: Colors.redAccent,
                    child: Text('Termina sessione',
                        style: TextStyle(color: Colors.white)),
                    controller: btnController,
                    onPressed: doSomething,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
