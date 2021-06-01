import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String value;
  Function getLogin;
  ProfileScreen(this.value, this.getLogin);
  @override
  _ProfileScreenState createState() => _ProfileScreenState(value);
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = new FlutterSecureStorage();
  String a;
  dynamic dati;
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  _ProfileScreenState(String a) {
    dati = json.decode(a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        //physics: PageScrollPhysics(),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Container(
                color: const Color(0xff44a688),
                height: MediaQuery.of(context).size.height +
                    2000000000000, //L'altezza del container deve essere maggiore di quella dello schermo
              ),
              Positioned(
                top: 200,
                child: Container(
                  height: 800,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                ),
              ),
              Positioned(
                  top: 125,
                  left: (MediaQuery.of(context).size.width / 2) - 75,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  )),
              Positioned(
                  top: 130,
                  left: (MediaQuery.of(context).size.width / 2) - 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/images/skri.jpg',
                      width: 140,
                      height: 140,
                    ),
                  )),
              Positioned(
                top: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'INFORMAZIONI',
                        style: TextStyle(
                            color: const Color(0xff44a688),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(children: [
                        Icon(
                          Icons.person_rounded,
                          size: 20,
                        ),
                        Text("${auth.currentUser.displayName}",
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 20),
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.call,
                    //         size: 20,
                    //       ),
                    //       Text(
                    //         '${dati['phone']}',
                    //         style: TextStyle(
                    //           fontSize: 20,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 20,
                            ),
                            Text(
                              '${dati['mail']}',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 10),
                    //   child: Text(
                    //     'MACCHINE',
                    //     style: TextStyle(
                    //         color: const Color(0xff44a688),
                    //         fontSize: 25,
                    //         fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 20),
                    //     child: Row(
                    //       children: [
                    //         Icon(
                    //           Icons.directions_car,
                    //           size: 20,
                    //         ),
                    //         Text(
                    //           '<PICKER>',
                    //           style: TextStyle(
                    //             fontSize: 20,
                    //           ),
                    //         )
                    //       ],
                    //     )),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 10),
                    //   child: Text(
                    //     'DATI PERSONALI',
                    //     style: TextStyle(
                    //         color: const Color(0xff44a688),
                    //         fontSize: 25,
                    //         fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 20),
                    //     child: Row(
                    //       children: [
                    //         Icon(
                    //           Icons.person,
                    //           size: 20,
                    //         ),
                    //         Text(
                    //           'Modifica i dati personali',
                    //           style: TextStyle(
                    //             fontSize: 20,
                    //           ),
                    //         )
                    //       ],
                    //     )),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 20),
                    //     child: Row(
                    //       children: [
                    //         Icon(
                    //           Icons.monetization_on,
                    //           size: 20,
                    //         ),
                    //         Text(
                    //           'Modifica i dati di fatturazione',
                    //           style: TextStyle(
                    //             fontSize: 20,
                    //           ),
                    //         )
                    //       ],
                    //     )),
                    // SizedBox(
                    //   height: 10,
                    // ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + 10,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: (MediaQuery.of(context).size.width - 100) / 2,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xff44a688)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await storage.deleteAll();
                          await auth.signOut();
                          Phoenix.rebirth(context);
                          // widget.getLogin(widget.value);
                        },
                        child: Text(
                          'Log Off',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
