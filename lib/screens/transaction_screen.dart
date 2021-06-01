import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:green_up/services/map_helper.dart';
import 'package:progress_indicator/progress_indicator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:cloud_functions/cloud_functions.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  //GifController controllerGif;
  RoundedLoadingButtonController btnController;
  String statusText = "Inizializzazione ricarica...";
  double textPercentage = 0;
  @override
  void initState() {
    //controllerGif = GifController(vsync: this);
    btnController = RoundedLoadingButtonController();
    //controllerGif.value = 122;
    startTransaction();
    super.initState();
  }

  @override
  void dispose() {
    //controllerGif.dispose();
    super.dispose();
  }

  void stopTransaction() async {
    final User user = FirebaseAuth.instance.currentUser;
    setState(() {
      statusText = "Terminazione ricarica in corso...";
    });
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('stopTransaction');
      await callable.call(<String, String>{
        'chargebox_id': MapHelper.selectedForTransaction.id,
        'tag': user.uid
      }).then((value) {
        print(value.data);
        if (value.data != "FATAL") {
          setState(() {
            statusText = "Ricarica terminata";
          });
          btnController.success();
          //controllerGif.stop();
          //controllerGif.animateTo(104, duration: Duration(milliseconds: 2000));
          Timer(Duration(milliseconds: 2100), () {
            Navigator.pop(context);
          });
        } else {
          Fluttertoast.showToast(
            msg: "ERRORE FATALE",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /*timeInSecForIosWeb: 1*/
          );

          Future.delayed(const Duration(seconds: 5), () async {
            Navigator.pop(context);
            await MapHelper.dataTransactions.initTransactions(context);
          });
        }
      });
      
      print(MapHelper.dataTransactions.transactions.toString());
    } on FirebaseFunctionsException catch (e) {
      print(e);
      print(e.code);
      print(e.message);
      print(e.details);
    }
  }

  void startTransaction() async {
    final User user = FirebaseAuth.instance.currentUser;
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('startTransaction');
      await callable.call(<String, String>{
        'chargebox_id': MapHelper.selectedForTransaction.id,
        'tag': user.uid
      }).then((value) {
        print(value.data);
        if (value.data != "FATAL") {
          setState(() {
            statusText = "Ricarica in corso";
          });
          Future.delayed(const Duration(seconds: 1), () {
            //controllerGif.animateTo(184, duration: Duration(milliseconds: 600));
            Future.delayed(const Duration(milliseconds: 600), () {
              //controllerGif.value = 0;
              // controllerGif.repeat(
              //     min: 0,
              //     max: 5,
              //     reverse: true,
              //     period: Duration(milliseconds: 600));
            });
          });
        } else {
          Fluttertoast.showToast(
            msg: "ERRORE FATALE",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /*timeInSecForIosWeb: 1*/
          );

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      });
    } on FirebaseFunctionsException catch (e) {
      print(e);
      print(e.code);
      print(e.message);
      print(e.details);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isInit = true;
    bool isSecondInit = true;
    double initString = 0;

    FirebaseFirestore.instance
        .collection('chargingPercentage')
        .doc(MapHelper.selectedForTransaction.id)
        .snapshots()
        .listen((document) {
      if (isInit) {
        isInit = false;
        initString = document['percentage'] + 0.0;
      } else {
        if (initString != document['percentage'] + 0.0 && isSecondInit) {
          isSecondInit = false;
          setState(() {
            textPercentage = document['percentage'] + 0.0;
          });
        } else if (document['percentage'] + 0.0 != textPercentage)
          //print("SNAPSHOT-------------------------------------");
          print(document['percentage'].toString());
        setState(() {
          textPercentage = document['percentage'] + 0.0;
        });
      }
    });
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Vuoi terminare la sessione?'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: const Color(0xff44a688),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Si',
                      style: TextStyle(
                        color: const Color(0xff44a688),
                      ),
                    ),
                    onPressed: () async {
                      btnController.start();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            });

        return value == true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: MediaQuery.of(context).size.height / 1.5,
                ),
                child: CircularProgress(
                  percentage: textPercentage,
                  color: Colors.amber,
                  backColor: Colors.grey,
                  gradient: LinearGradient(
                      colors: [const Color(0xff327a65), Color(0xff44a688)]),
                  showPercentage: true,
                  textStyle: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 60,
                      fontWeight: FontWeight.w500),
                  stroke: 20,
                  round: true,
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: MediaQuery.of(context).size.height / 1.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          statusText,
                          style: GoogleFonts.roboto(
                              fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30, bottom: MediaQuery.of(context).size.height / 4),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Fornitore: " + MapHelper.selectedForTransaction.owner,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Text(
                      "Tipologia: " +
                          MapHelper.selectedForTransaction.powerType,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w100,
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
                      onPressed: stopTransaction,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
