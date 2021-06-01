import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_up/models/chargepoint_model.dart';
import 'package:green_up/services/map_marker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;


class ChargePoints with ChangeNotifier {
  BitmapDescriptor _iconAvailable;
  BitmapDescriptor _iconOccupied;
  BitmapDescriptor _iconUnavailable;

  List<ChargePoint> _chargePoints = [

  ];

  List<ChargePoint> get chargePoints {
    return [..._chargePoints];
  }

  ChargePoint chargePointfromMapMarker(MapMarker marker) {
    return _chargePoints.where((element) => element.id == marker.id).first;
  }

  Future<BitmapDescriptor> _setMarkerIcon(Status status) async {
    //apparentemente se si usano i byte le dimensioni non si buggano su iOS, tengo cosi per sicurezza
    //int width = Platform.isAndroid ? 128 : 128;
    String path;
    switch (status) {
      case Status.available:
        path = 'assets/images/chargingAvailable128px.png';
        break;
      case Status.unavailable:
        path = 'assets/images/chargingUnavailable.png';
        break;
      case Status.occupied:
        path = 'assets/images/chargingOccupied.png';
        break;
    }

    Uint8List byte = await getBytesFromAsset(path, 100);
    return BitmapDescriptor.fromBytes(byte);

    // return await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(),
    //     status == Status.available
    //         ? 'assets/images/chargingAvailable100px.png'
    //         : status == Status.unavailable
    //             ? 'assets/images/chargingAvailable.png'
    //             : status == Status.occupied
    //                 ? 'assets/images/chargingAvailable.png'
    //                 : '');
  }

  initChargers(BuildContext context) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getChargingStations');
    final results = await callable();

    final Map resultsMap = json.decode(results.data);

    final List<ChargePoint> loadedChargers = [
      
    ];

    resultsMap.forEach((key, element) {
      print(element["id"]);
      print(element["longitudine"]);

      return element["longitudine"] == null
          ? null
          : loadedChargers.add(
              ChargePoint(
                owner: element["titolare"].toString(),
                id: element["id"].toString(),
                address: Address(
                  city: element["citta"],
                  street: element["via"],
                ),
                //TODO: check status
                status: Status.available,
                plug: null,
                maxPower: null,
                powerType: element["tipo_ricar"].toString(),
                cost: null,
                position: LatLng(
                  double.parse(element["latitudine"]),
                  double.parse(element["longitudine"]),
                ),
              ),
            );
    });
    _chargePoints = loadedChargers;
    notifyListeners();
  }

  initIcons() async {
    _iconAvailable = (await _setMarkerIcon(Status.available));
    _iconOccupied = await _setMarkerIcon(Status.occupied);
    _iconUnavailable = await _setMarkerIcon(Status.unavailable);
  }

  List<MapMarker> get markers {
    List<MapMarker> chargeMarkers = [];

    _chargePoints.forEach((element) {
      chargeMarkers.add(
        MapMarker(
          id: element.id,
          position: element.position,
          icon: element.status == Status.available
              ? _iconAvailable
              : element.status == Status.unavailable
                  ? _iconUnavailable
                  : element.status == Status.occupied
                      ? _iconOccupied
                      : BitmapDescriptor.defaultMarker,
        ),
      );
    });

    return [...chargeMarkers];
  }

  List<MapMarker> get markersAC {
    List<MapMarker> chargeMarkers = [];

    _chargePoints.forEach((element) {
      if (element.powerType.contains("AC")) {
        chargeMarkers.add(
          MapMarker(
            id: element.id,
            position: element.position,
            icon: element.status == Status.available
                ? _iconAvailable
                : element.status == Status.unavailable
                    ? _iconUnavailable
                    : element.status == Status.occupied
                        ? _iconOccupied
                        : BitmapDescriptor.defaultMarker,
          ),
        );
      }
    });

    return [...chargeMarkers];
  }

  List<MapMarker> get markersDC {
    List<MapMarker> chargeMarkers = [];

    _chargePoints.forEach((element) {
      if (element.powerType.contains("DC")) {
        chargeMarkers.add(
          MapMarker(
            id: element.id,
            position: element.position,
            icon: element.status == Status.available
                ? _iconAvailable
                : element.status == Status.unavailable
                    ? _iconUnavailable
                    : element.status == Status.occupied
                        ? _iconOccupied
                        : BitmapDescriptor.defaultMarker,
          ),
        );
      }
    });

    return [...chargeMarkers];
  }

  ChargePoint findById(String id) {
    return _chargePoints.firstWhere((element) => element.id == id);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}
