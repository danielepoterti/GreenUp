import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_up/screens/transactions_list_screen.dart';
import 'package:green_up/widgets/curved_navigation_bar.dart';
import 'package:green_up/services/map_helper.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';

GlobalKey<MapScreenState> globalKey = GlobalKey();

class Wrapper extends StatefulWidget {
  Position snapshot;
  String login;
  Function getLogin;
  Wrapper({@required this.snapshot, this.login, this.getLogin});
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with SingleTickerProviderStateMixin {
  int _page = 0;
  bool autocompleteVisible = false;
  List<Widget> autocomplete;
  GlobalKey _bottomNavigationKey = GlobalKey();
  CurvedNavigationBarState navBarState;
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    //animationController.forward();
  }

  Future<void> handleAutocompleteClick(element) async {
    await MapHelper.handleMarkerClickCluster(
        double.parse(element['coo']['long']),
        double.parse(element['coo']['lat']));
    setState(() {
      autocompleteVisible = false;
    });
  }


  Widget _router() {
    if (_page == 0) {
      return (Stack(
        children: <Widget>[
          MapScreen(
            snapshot: widget.snapshot,
          ),
          CircularRevealAnimation(
            animation: animation,
            centerAlignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      ));
    } else if (_page == 1) {
      return (Stack(
        children: <Widget>[
          MapScreen(snapshot: widget.snapshot),
          CircularRevealAnimation(
              animation: animation,
              centerAlignment: Alignment.bottomCenter,
              child: TransactionsListScreen()),
        ],
      ));
    } else if (_page == 2) {
      return (Stack(
        children: <Widget>[
          MapScreen(snapshot: widget.snapshot),
          Container(
            margin: EdgeInsets.all(20),
            child: Align(
              alignment: FractionalOffset.topCenter,
              child: Container(),
            ),
          ),
          CircularRevealAnimation(
            animation: animation,
            centerAlignment: Alignment.bottomCenter,
            child: ProfileScreen(widget.login, widget.getLogin),
          ),
          
        ],
      ));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        bottomNavigationBar: CurvedNavigationBar(
          shadow: 5,
          key: _bottomNavigationKey,
          index: 0,
          height: 75.0,
          items: <Widget>[
            Icon(Icons.map, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.person, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            switch (index) {
              case 0:
                if (animationController.status == AnimationStatus.forward ||
                    animationController.status == AnimationStatus.completed) {
                  animationController.reverse();
                }
                break;

              default:
                if (animationController.status == AnimationStatus.reverse ||
                    animationController.status == AnimationStatus.dismissed) {
                  animationController.forward();
                }
                break;
            }
            
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: _router());
  }
}
