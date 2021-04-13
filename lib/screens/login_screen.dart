import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Function getLogin;
  Login(this.storage, this.getLogin);
  @override
  _LoginState createState() => _LoginState(storage, getLogin);
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Function getLogin;

  final FlutterSecureStorage storage;

  //constructor
  _LoginState(this.storage, this.getLogin);

  void register() async {
    bool isGood = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      isGood = false;
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      isGood = false;
      print(e);
    }
    //succesfully registered
    if (isGood) {
      String data =
          '{\"mail\": \"${emailController.text}\", \"psw\": \"${passwordController.text}\"}';
      await storage.write(key: 'login', value: data);
      this.getLogin(data);
    }
  }

  void login() async {
    bool isGood = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      isGood = false;
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    //successfully logged in
    if (isGood) {
      String data =
          '{\"mail\": \"${emailController.text}\", \"psw\": \"${passwordController.text}\"}';
      await storage.write(key: 'login', value: data);
      this.getLogin(data);
    }
  }

  // void google() async {
  //   print(await signInWithGoogle());
  // }

  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser.authentication;

  //   // Create a new credential
  //   final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Password'),
          ),
          ElevatedButton(onPressed: register, child: Text('Register')),
          ElevatedButton(onPressed: login, child: Text('Login')),
          //ElevatedButton(onPressed: google, child: Text('Google')),
        ],
      )),
    );
  }
}
