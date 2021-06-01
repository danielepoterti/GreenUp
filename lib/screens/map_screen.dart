import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:green_up/providers/chargepoints_provider.dart';
import 'package:green_up/providers/transcations_provider.dart';
import 'package:green_up/services/map_helper.dart';
import 'package:green_up/services/map_marker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import '../widgets/searchbar.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  dynamic snapshot;
  MapScreen({@required this.snapshot});
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  //TODO: fix duplicated variables

  bool isInit = true;

  void _initMarkers() async {
    final List<MapMarker> markers = [];
    markers.addAll(MapHelper.dataChargePoints.markers);
    MapHelper.markersSelected.clear();
    MapHelper.markersSelected.addAll(MapHelper.dataChargePoints.markers);
    MapHelper.clusterManager = await MapHelper.initClusterManager(
      markers,
      MapHelper.minClusterZoom,
      MapHelper.maxClusterZoom,
    );
    await _updateMarkers();
  }

  void _onlyACMarkers() async {
    final List<MapMarker> markers = [];
    markers.addAll(MapHelper.dataChargePoints.markersAC);
    MapHelper.markersSelected.clear();
    MapHelper.markersSelected.addAll(MapHelper.dataChargePoints.markersAC);
    MapHelper.clusterManager = await MapHelper.initClusterManager(
      markers,
      MapHelper.minClusterZoom,
      MapHelper.maxClusterZoom,
    );
    await _updateMarkers();
  }

  void _onlyDCMarkers() async {
    final List<MapMarker> markers = [];
    markers.addAll(MapHelper.dataChargePoints.markersDC);
    MapHelper.markersSelected.clear();
    MapHelper.markersSelected.addAll(MapHelper.dataChargePoints.markersDC);
    MapHelper.clusterManager = await MapHelper.initClusterManager(
      markers,
      MapHelper.minClusterZoom,
      MapHelper.maxClusterZoom,
    );
    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers() async {
    if (MapHelper.clusterManager == null) return;

    if (MapHelper.currentZoomLevel != null) {
      MapHelper.currentZoom = MapHelper.currentZoomLevel;
    }
    setState(() {
      //  _areMarkersLoading = true;
    });
    final updatedMarkers = await MapHelper.getClusterMarkers(
      MapHelper.clusterManager,
      MapHelper.currentZoomLevel,
      MapHelper.clusterColor,
      MapHelper.clusterTextColor,
      80,
      MapHelper.box,
      MapHelper.handleMarkerClickCluster,
      handleMarkerClickMarker,
    );
    MapHelper.markers
      ..clear()
      ..addAll(updatedMarkers);
    setState(() {
      //  _areMarkersLoading = false;
    });
  }

  Future<void> handleAutocompleteClick(element) async {
    String key = "AIzaSyCc-16mvBlbztZ44hjE2LJB1ZNvXbZrwGM";
    String placeId = element["place_id"];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$key');

    final response = await http.get(url);

    Map<String, dynamic> map = json.decode(response.body);
    List<dynamic> data = map["results"];
    Map location = data[0]["geometry"]["location"];
    MapHelper.handleMarkerClickCluster(location["lng"], location["lat"]);
    MapHelper.keyAnimationSearch.currentState.onPressHandler();
    setState(() {
      MapHelper.autocompleteVisible = false;
    });
  }

  void getAutocomplete(List list) {
    List<Widget> appoggio = [];
    list.forEach((element) {
      appoggio.add(SizedBox(
        height: 7,
      ));
      String textPlace = element['description'];
      appoggio.add(
        InkWell(
          onTap: () => {handleAutocompleteClick(element)},
          child: Flexible(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 12),
                child: Text(
                  textPlace,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );
    });
    setState(() {
      MapHelper.autocompleteVisible = true;
      MapHelper.autocomplete = appoggio;
    });
  }

  void handleMarkerClickMarker(double long, double lat) async {
    //nearby.clear();
    MapHelper.keySnaplist.currentState.focusToInitialPosition();
    MapHelper.nearbyChargePoints.clear();
    for (var i = 0; i < MapHelper.markersSelected.length; i++) {
      if (MapHelper.getDistanceFromLatLonInKm(
              lat,
              long,
              MapHelper.markersSelected[i].latitude,
              MapHelper.markersSelected[i].longitude) <
          1.0) {
        //nearby.add(markersSelected[i]);
        MapHelper.nearbyChargePoints.add(MapHelper.dataChargePoints
            .chargePointfromMapMarker(MapHelper.markersSelected[i]));
      }
      MapHelper.nearbyChargePoints.sort(
        (a, b) => MapHelper.getDistanceFromLatLonInKm(
                lat, long, a.position.latitude, a.position.longitude)
            .compareTo(
          MapHelper.getDistanceFromLatLonInKm(
              lat, long, b.position.latitude, b.position.longitude),
        ),
      );
    }

    final GoogleMapController controller =
        await MapHelper.controllerCompleterMap.future;
    await controller
        .animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(lat, long),
              zoom: 17.0,
            ),
          ),
        )
        .then((value) => setState(() {
              MapHelper.isChargePointPressed = true;
            }));
    MapHelper.controllerChargePointCard.forward();
    //print('MARKER PRESSED');
  }

  //zoom on user current position
  void currentLocation() async {
    final GoogleMapController controller =
        await MapHelper.controllerCompleterMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(widget.snapshot.latitude, widget.snapshot.longitude),
        zoom: 17.0,
      ),
    ));
  }

  void handlePrefix() {
    setState(() {
      MapHelper.autocompleteVisible = false;
    });
  }

  FloatingActionButton buildCurrentLocationButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: currentLocation,
      child: Icon(
        Icons.location_searching_sharp,
        color: Colors.black,
      ),
    );
  }

  @override
  void initState() {
    MapHelper.controllerChargePointCard = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    MapHelper.offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: MapHelper.controllerChargePointCard,
        curve: Curves.elasticInOut,
      ),
    );
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (isInit) {
      setState(() {
        isInit = !isInit;
      });
      MapHelper.dataChargePoints = Provider.of<ChargePoints>(context);
      MapHelper.dataTransactions = Provider.of<Transactions>(context);
      MapHelper.styleOfMapJSON = await DefaultAssetBundle.of(context)
          .loadString('./assets/map_style.json');
      await MapHelper.dataChargePoints.initIcons();
      await MapHelper.dataChargePoints
          .initChargers(context)
          .then((_) => _initMarkers());
      await MapHelper.dataTransactions.initTransactions(context);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    MapHelper.controllerCompleterMap = Completer();
    MapHelper.controllerChargePointCard.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var snapshot = widget.snapshot;
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: GoogleMap(
            padding: EdgeInsets.only(bottom: 85),
            initialCameraPosition: snapshot == null
                ? MapHelper.kMilano
                : CameraPosition(
                    target: LatLng(
                      snapshot.latitude,
                      snapshot.longitude,
                    ),
                    zoom: MapHelper.currentZoom,
                  ),
            markers: Set<Marker>.of(MapHelper.markers),
            zoomControlsEnabled: false,
            onCameraMoveStarted: () {
              if (MapHelper.isChargePointPressed && !MapHelper.isSliding) {
                setState(() {
                  MapHelper.isChargePointPressed = false;
                });
                MapHelper.controllerChargePointCard.reverse();
              }
            },
            onMapCreated: (GoogleMapController controller) async {
              MapHelper.setMapstyle(controller);
              MapHelper.controllerMap = controller;
              await MapHelper.controllerMap.moveCamera(CameraUpdate.zoomOut());

              try {
                MapHelper.controllerCompleterMap.complete(controller);
              } catch (e) {
                print(e);
                snapshot != null
                    ? MapHelper.controllerMap.moveCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            snapshot.latitude,
                            snapshot.longitude,
                          ),
                        ),
                      )
                    : MapHelper.controllerMap.moveCamera(
                        CameraUpdate.newCameraPosition(MapHelper.kMilano),
                      );
              }
              setState(() {
                //  _isMapLoading = false;
              });
            },
            onCameraMove: (position) =>
                MapHelper.updateZoomLevel(position.zoom),
            onCameraIdle: () => _updateMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            buildingsEnabled: false,
          ),
          floatingActionButton: snapshot != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 90.0),
                  child: buildCurrentLocationButton(),
                )
              : null,
        ),
        Positioned(
          left: 20,
          top: MediaQuery.of(context).size.height / 2,
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              //border: Border.all(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              borderColor: Colors.white,
              selectedBorderColor: Colors.white,
              fillColor: Colors.white,
              //highlightColor: Colors.white,
              selectedColor: const Color(0xff44a688),
              direction: Axis.vertical,
              children: <Widget>[
                Text(
                  "AC/DC",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w800),
                ),
                Text(
                  "AC",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w800),
                ),
                Text(
                  "DC",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w800),
                ),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < MapHelper.isSelected.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      MapHelper.isSelected[buttonIndex] = true;
                    } else {
                      MapHelper.isSelected[buttonIndex] = false;
                    }
                  }
                  switch (index) {
                    case 0:
                      print("AC/DC");
                      _initMarkers();
                      break;
                    case 1:
                      print("AC");
                      _onlyACMarkers();
                      break;
                    case 2:
                      print("DC");
                      _onlyDCMarkers();
                      break;
                    default:
                  }
                });
              },
              isSelected: MapHelper.isSelected,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Row(
                children: [
                  SearchBar(
                    callback: getAutocomplete,
                    prefixTap: handlePrefix,
                    width: MediaQuery.of(context).size.width - 40,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MapHelper.autocompleteWidget(context),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Container(
                      child: Row(
                        children: [
                          SlideTransition(
                            position: MapHelper.offsetAnimation,
                            child: SizedBox(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              child: ScrollSnapList(
                                  key: MapHelper.keySnaplist,
                                  initialIndex: 0,
                                  itemCount:
                                      MapHelper.nearbyChargePoints.length,
                                  itemBuilder:
                                      MapHelper.chargePointCardsBuilder,
                                  itemSize:
                                      (MediaQuery.of(context).size.width - 40) +
                                          10,
                                  onItemFocus: (index) {
                                    MapHelper.handlerChangeFocusChargePointList(
                                        MapHelper.nearbyChargePoints[index]
                                            .position.longitude,
                                        MapHelper.nearbyChargePoints[index]
                                            .position.latitude);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
