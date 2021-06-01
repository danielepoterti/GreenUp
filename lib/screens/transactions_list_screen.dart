import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:green_up/providers/transcations_provider.dart';
import 'package:provider/provider.dart';

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Transactions data = Provider.of<Transactions>(context);

    return Container(
      color: Colors.white,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: SafeArea(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: data.transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 44.0,
                      child: FadeInAnimation(
                        child: TransactionCard(
                          width: MediaQuery.of(context).size.width,
                          height: 100.0,
                          data: data.transactions[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Stack(children: [
          Container(
            //color: Colors.blue,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: const Color(0xff44a688),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),

            height: 131,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              "Ricariche effettuate:",
              style:
                  GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          )
        ]),
      ]),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final double width;
  final double height;
  final Transaction data;

  const TransactionCard({
    Key key,
    this.width,
    this.height,
    this.data
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Codice ricarica #"+data.id,
              softWrap: true,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Text(
            data.address.street,
            softWrap: true,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            data.address.city,
            softWrap: true,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w200,
            ),
          ),
          Row( crossAxisAlignment: CrossAxisAlignment.end ,mainAxisAlignment: MainAxisAlignment.end, children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "Durata: "+data.endTime.difference(data.startTime).inMinutes.toString()+" minuti",
                softWrap: true,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ])
        ]),
      ),
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
    );
  }
}

