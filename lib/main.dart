import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_up/providers/chargepoints_provider.dart';
import 'package:green_up/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login_screen.dart';
import 'wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
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
      setState(() {
        login = value;
      });
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
        )
      ],
      child: MaterialApp(
        title: 'GreenUp Demo',
        home: FutureBuilder(
          future:
              Future.wait([GeolocatorService.getLocation(), _initialization]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data[0]); //if login is null => login screen
              if (login != null) {
                return MaterialApp(home: Wrapper(snapshot: snapshot.data[0]));
              } else {
                return MaterialApp(
                  home: Login(storage, getLogin),
                );
              }
            } else {
              //loading screen
              return (Center());
            }
          },
        ),
      ),
    );
  }
}
