import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_up/providers/chargepoints_provider.dart';
import 'package:green_up/providers/transcations_provider.dart';
import 'package:green_up/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'wrapper.dart';
import 'dart:convert';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  //firebase & storage inizialization
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final storage = new FlutterSecureStorage();
  String login;

  _MyApp() {
    getLogin(null);
  }

  void getLogin(String data) async {
    //await storage.deleteAll();
    if (data != null) {
      setState(() {
        login = data;
      });
    } else {
      String value = await storage.read(key: 'login');
      bool validCredentials = await loginFromDisk(value);
      print(validCredentials);
      if (validCredentials != null && validCredentials) {
        setState(() {
          login = value;
        });
      } else {
        setState(() {
          login = null;
        });
      }
    }
  }

  Future<bool> loginFromDisk(String data) async {
    try {
      final dati = json.decode(data);
      String mail = dati['mail'];
      String psw = dati['psw'];
      bool isGood = true;
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: mail, password: psw);
      } on FirebaseAuthException catch (e) {
        isGood = false;
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
      //successfully logged in
      return isGood;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return ChargePoints();
          },
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return Transactions();
          },
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GreenUp Demo',
        home: FutureBuilder(
          future:
              Future.wait([GeolocatorService.getLocation(), _initialization]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data[0]); //if login is null => login screen
              if (login != null) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                    home: Wrapper(
                  snapshot: snapshot.data[0],
                  login: login,
                  getLogin: getLogin,
                ));
              } else {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Login(storage, getLogin),
                );
              }
            } else {
              //loading screen
              return (SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: const Color(0xff44a688)),
                  child: Center(
                    child: Image.asset(
                      'assets/images/github.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ));
            }
          },
        ),
      ),
    );
  }
}
