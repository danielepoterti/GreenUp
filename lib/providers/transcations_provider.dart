import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions {
    return [..._transactions];
  }

  initTransactions(BuildContext context) async {
    /*FirebaseAuth.instance.currentUser.uid;*/
    final User user =  FirebaseAuth.instance.currentUser;
    
    print(user);
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('OCPPTagTransactions');
    try {
      await callable.call(<String, String>{
        'tag': user.uid /*FirebaseAuth.instance.currentUser.uid*/,
        'period': "ALL"
      }).then((value) {
        final List<Transaction> loadedTransactions = [];
        
        Map<dynamic, dynamic> recived = value.data;
       recived.forEach((key, value) {
         return loadedTransactions.add(
           Transaction(
             id: value[0],
             chargePointId: value[1],
             address: Address(street: value[2], city:value[5]),
             startTime: DateTime.parse(value[8]),
             endTime: DateTime.parse(value[9]),
           )
         );
         
       });
       loadedTransactions.sort((a,b) => a.id.compareTo(b.id));
       _transactions = loadedTransactions.reversed.toList();
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

class Transaction {
  final String id;
  final String chargePointId;
  final Address address;
  final DateTime startTime;
  final DateTime endTime;

  Transaction({
    this.id,
    this.chargePointId,
    this.address,
    this.startTime,
    this.endTime,
  });
}

class Address {
  final String street;
  final String houseNumber;
  final String zipCode;
  final String city;
  final String country;

  Address({
    this.street,
    this.houseNumber,
    this.zipCode,
    this.city,
    this.country,
  });
}
