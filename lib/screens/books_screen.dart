import 'package:flutter/material.dart';

class Prenotazioni extends StatefulWidget {
  @override
  _PrenotazioniState createState() => _PrenotazioniState();
}

class _PrenotazioniState extends State<Prenotazioni> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Center(
                child: Text(
              'Prenotazioni',
              style: TextStyle(fontSize: 30),
            )),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text(
                'Oggi',
                style: TextStyle(fontSize: 25),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Via Santa Maria Hoe. 9:00 - 10:00',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Text(
                'Domani',
                style: TextStyle(fontSize: 25),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Via Santa Maria Hoe. 17:00 - 18:00',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Largo Via Brombeis. 7:30 - 10:00',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        width: 350,
        height: 500,
      ),
    );
  }
}
