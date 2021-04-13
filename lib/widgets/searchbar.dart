import 'package:flutter/material.dart';
import '../services/anim_search_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  double width;
  String query = '';
  Function callback;
  Function prefixTap;
  Search({this.callback, this.prefixTap, this.width});
  @override
  _SearchState createState() => _SearchState(callback, prefixTap);
}

class _SearchState extends State<Search> {
  Function callback;
  Function prefixTap;
  _SearchState(this.callback, this.prefixTap);
  TextEditingController textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    textController.addListener(handleTextChanges);
  }

  // callback fired every time input change
  void handleTextChanges() async {
    if (textController.text.length > 2) {
      final url = Uri.parse(
          'https://photon.komoot.io/api/?q=${textController.text}&limit=5');
      final response = await http.get(url);
      Map<String, dynamic> map = json.decode(response.body);
      List<dynamic> data = map["features"];
      this.callback(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30),
        child: AnimSearchBar(
          width: widget.width,
          textController: textController,
          suffixIcon: Icon(Icons.search),
          autoFocus: true,
          onPrefixTap: () => {
            setState(() {
              textController.clear();
            }),
            this.prefixTap()
          },
          onSuffixTap: () {
            setState(() {
              textController.clear();
            });
          },
        ));
  }
}
