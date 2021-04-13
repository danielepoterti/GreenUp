import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
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
              'Prenota',
              style: TextStyle(fontSize: 30),
            ))
          ],
        ),
        width: 350,
        height: 500,
      ),
    );
  }
}
