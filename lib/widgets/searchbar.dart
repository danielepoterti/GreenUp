import 'package:flutter/material.dart';
import 'package:green_up/services/map_helper.dart';
import '../services/anim_search_widget.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SearchBar extends StatefulWidget {
  double width;
  String query = '';
  Function callback;
  Function prefixTap;
  Function suffixTap;
  SearchBar({
    this.callback,
    this.prefixTap,
    this.width,
  });
  @override
  _SearchBarState createState() => _SearchBarState(callback, prefixTap);
}

class _SearchBarState extends State<SearchBar> {
  Function callback;
  Function prefixTap;
  _SearchBarState(this.callback, this.prefixTap);
  TextEditingController textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    textController.addListener(handleTextChanges);
  }

  // callback fired every time input change
  void handleTextChanges() async {
    String key = "AIzaSyCc-16mvBlbztZ44hjE2LJB1ZNvXbZrwGM";
    if (textController.text.length > 2) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${textController.text}&language=it_IT&components=country:it&key=$key');
      final response = await http.get(url);
      Map<String, dynamic> map = json.decode(response.body);
      List<dynamic> data = map["predictions"];

      this.callback(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30),
        child: AnimSearchBar(
          key: MapHelper.keyAnimationSearch,
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
