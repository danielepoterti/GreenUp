import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup_screen.dart';
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

  void login() async {
    bool isGood = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      isGood = false;
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Fluttertoast.showToast(
          msg: 'No user found for that email.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          /*timeInSecForIosWeb: 1*/
        );
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Fluttertoast.showToast(
          msg: 'Wrong password provided for that user.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          /*timeInSecForIosWeb: 1*/
        );
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
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          title: Text('Login'),
          backgroundColor: const Color(0xff44a688),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff44a688),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/github.png',
                    width: 150,
                    height: 150,
                  ),
                  Container(
                    child: Align(
                      //alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    hintText: 'Email'),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    hintText: 'Password'),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: 50,
                              width:
                                  (MediaQuery.of(context).size.width - 100) / 2,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => const Color(0xff44a688)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                                onPressed: login,
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'You dont have and account?',
                              style: TextStyle(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          SignUp(storage, getLogin))),
                              child: Text('Sign Up',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      decoration: TextDecoration.underline)),
                            )
                            //ElevatedButton(onPressed: google, child: Text('Google')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
