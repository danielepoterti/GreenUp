import 'dart:async';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:green_up/providers/chargepoints_provider.dart';
import 'package:green_up/services/geolocator_service.dart';
import 'package:green_up/services/map_helper.dart';
import 'package:green_up/services/map_marker.dart';
import 'package:green_up/widgets/circular_button.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import '../widgets/searchbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  dynamic snapshot;
  MapScreen({@required this.snapshot});
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  //TODO: fix duplicated variables

  final keySnaplist = GlobalKey<ScrollSnapListState>();

  bool autocompleteVisible = false;
  List<Widget> autocomplete;

  bool isInit = true;

  void _initMarkers() async {
    final List<MapMarker> markers = [];
    markers.addAll(MapHelper.data.markers);
    MapHelper.markersSelected.addAll(MapHelper.data.markers);
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

  void handleAutocompleteClick(element) {
    MapHelper.handleMarkerClickCluster(element['geometry']['coordinates'][0],
        element['geometry']['coordinates'][1]);
    setState(() {
      autocompleteVisible = false;
    });
  }

  List getAutocomplete(List list) {
    List<Widget> appoggio = [];
    list.forEach((element) {
      appoggio.add(SizedBox(
        height: 7,
      ));
      appoggio.add(InkWell(
          onTap: () => {handleAutocompleteClick(element)},
          child: Container(
            height: 40,
            width: 500,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(child: Text(element['properties']['name'])),
          )));
    });
    setState(() {
      autocompleteVisible = true;
      autocomplete = appoggio;
    });
  }

  Widget _autocomplete() {
    if (autocompleteVisible) {
      return (Container(
        width: 300,
        child: MediaQuery.removePadding(
          removeBottom: true,
          context: context,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: autocomplete,
          ),
        ),
      ));
    } else {
      return Container();
    }
  }

  void handleMarkerClickMarker(double long, double lat) async {
    //nearby.clear();
    keySnaplist.currentState.focusToInitialPosition();
    MapHelper.nearbyChargePoints.clear();
    for (var i = 0; i < MapHelper.markersSelected.length; i++) {
      if (MapHelper.getDistanceFromLatLonInKm(
              lat,
              long,
              MapHelper.markersSelected[i].latitude,
              MapHelper.markersSelected[i].longitude) <
          1.0) {
        //nearby.add(markersSelected[i]);
        MapHelper.nearbyChargePoints.add(MapHelper.data
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
    print('MARKER PRESSED');
  }

  void handlerChangeFocusChargePointList(double long, double lat) async {
    MapHelper.isSliding = true;
    final GoogleMapController controller =
        await MapHelper.controllerCompleterMap.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(lat, long),
          zoom: 17.0,
        ),
      ),
    );
    MapHelper.isSliding = false;
  }

  //zoom on user current position
  void _currentLocation() async {
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
      autocompleteVisible = false;
    });
  }

  final GeolocatorService geo = GeolocatorService();

  FloatingActionButton buildCurrentLocationButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: _currentLocation,
      child: Icon(
        Icons.location_searching_sharp,
        color: Colors.black,
      ),
    );
  }

  Widget chargePointCardsBuilder(BuildContext context, int index) {
    return Card(
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(13),
        ),
      ),
      elevation: 5,
      child: SizedBox(
        child: Stack(children: [
          Positioned(
            bottom: 20,
            right: 20,
            child: ClipOval(
              child: Material(
                color: const Color(0xff44a688), // button color
                child: InkWell(
                  //splashColor: Colors.red, // inkwell color
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.directions_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    String url =
                        'https://www.google.com/maps/dir/?api=1&destination=${MapHelper.nearbyChargePoints[index].position.latitude},${MapHelper.nearbyChargePoints[index].position.longitude}';
                    await canLaunch(url)
                        ? await launch(url)
                        : throw 'Could not launch google maps';
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 17.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                MapHelper.nearbyChargePoints[index].address.city,
                style: GoogleFonts.roboto(
                    fontSize: 20, fontWeight: FontWeight.w200),
              ),
            ),
          ),
          Positioned(
            //top: 35,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 40, right: 20.0),
              child: Column(
                children: [
                  Text(
                    MapHelper.nearbyChargePoints[index].address.street,
                    softWrap: true,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: LoadingButton(index),
          ),
        ]),
        width: (MediaQuery.of(context).size.width - 40),
        height: 300,
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

  //ChargePoints data;

  @override
  Future<void> didChangeDependencies() async {
    if (isInit) {
      MapHelper.data = Provider.of<ChargePoints>(context);
      MapHelper.styleOfMapJSON = await DefaultAssetBundle.of(context)
          .loadString('./assets/map_style.json');
      await MapHelper.data.initIcons();
      await MapHelper.data.initChargers(context).then((_) => _initMarkers());

      setState(() {
        isInit = !isInit;
      });
      fetchGif(MapHelper.chargingGif);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
                ? MapHelper.kRoma
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
            onMapCreated: (GoogleMapController controller) {
              MapHelper.setMapstyle(controller);
              MapHelper.controllerMap = controller;
              try {
                MapHelper.controllerCompleterMap.complete(controller);
              } catch (e) {
                throw e;
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
        Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Search(
                        callback: getAutocomplete,
                        prefixTap: handlePrefix,
                        width: MediaQuery.of(context).size.width - 40,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _autocomplete(),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 180),
                    child: Container(
                      child: Row(
                        children: [
                          SlideTransition(
                            position: MapHelper.offsetAnimation,
                            child: SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: ScrollSnapList(
                                  key: keySnaplist,
                                  initialIndex: 0,
                                  itemCount:
                                      MapHelper.nearbyChargePoints.length,
                                  itemBuilder: chargePointCardsBuilder,
                                  itemSize:
                                      (MediaQuery.of(context).size.width - 40) +
                                          10,
                                  onItemFocus: (index)
                                      // =>
                                      //     handleMarkerClickMarker(
                                      //         MapHelper.nearbyChargePoints[index]
                                      //             .position.longitude,
                                      //         MapHelper.nearbyChargePoints[index]
                                      //             .position.latitude)
                                      {
                                    handlerChangeFocusChargePointList(
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
