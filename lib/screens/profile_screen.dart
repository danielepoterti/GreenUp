import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.account_circle,
              size: 70,
            ),
            Center(
              child: Text(
                'Miche-lino Banfi',
                style: TextStyle(fontSize: 30),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Impostazioni',
                style: TextStyle(fontSize: 25),
              ),
            ),
            ElevatedButton(
              child: Text('Privacy'),
              onPressed: null,
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
            ),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        width: 350,
        height: 500,
      ),
    );
  }
}
