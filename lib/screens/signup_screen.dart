import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class SignUp extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Function getLogin;
  SignUp(this.storage, this.getLogin);
  @override
  _SignUp createState() => _SignUp(storage, getLogin);
}

class _SignUp extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final numberController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();

  final Function getLogin;

  final FlutterSecureStorage storage;

  //constructor
  _SignUp(this.storage, this.getLogin);

  void register() async {
    bool isGood = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      isGood = false;
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Fluttertoast.showToast(
          msg: "Password troppo debole",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          /*timeInSecForIosWeb: 1*/
        );
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Fluttertoast.showToast(
          msg: "Email già in uso",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          /*timeInSecForIosWeb: 1*/
        );
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
      await FirebaseAuth.instance.currentUser.updateProfile(
          displayName: nameController.text + " " + surnameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('SignUp'),
          backgroundColor: const Color(0xff44a688),
          leading: IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              height: MediaQuery.of(context).size.height,
              color: const Color(0xff44a688),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Image.asset(
                      'assets/images/github.png',
                      width: 150,
                      height: 150,
                    ),
                    Container(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height - 150,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50))),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
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
                                  width:
                                      MediaQuery.of(context).size.width - 100,
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
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                        labelText: 'Name',
                                        prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        hintText: 'Name'),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  child: TextField(
                                    controller: surnameController,
                                    decoration: InputDecoration(
                                        labelText: 'Surname',
                                        prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        hintText: 'Surname'),
                                  ),
                                ),
                                // SizedBox(
                                //   height: 20,
                                // ),
                                // Container(
                                //   width:
                                //       MediaQuery.of(context).size.width - 100,
                                //   child: TextField(
                                //     controller: numberController,
                                //     keyboardType: TextInputType.number,
                                //     decoration: InputDecoration(
                                //         labelText: 'Phone',
                                //         prefixIcon: Icon(Icons.call),
                                //         border: OutlineInputBorder(
                                //             borderRadius: BorderRadius.all(
                                //                 Radius.circular(25))),
                                //         hintText: 'Phone number'),
                                //   ),
                                // ),
                                SizedBox(height: 20),
                                SizedBox(
                                  height: 50,
                                  width: (MediaQuery.of(context).size.width -
                                          100) /
                                      2,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateColor.resolveWith(
                                              (states) =>
                                                  const Color(0xff44a688)),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                    onPressed: register,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                //ElevatedButton(onPressed: google, child: Text('Google')),
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              )),
        ));
  }
}
