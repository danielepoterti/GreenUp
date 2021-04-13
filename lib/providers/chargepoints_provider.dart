import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_up/models/chargepoint_model.dart';
import 'package:green_up/services/map_marker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:io' show Platform;

class ChargePoints with ChangeNotifier {
  BitmapDescriptor _iconAvailable;
  BitmapDescriptor _iconOccupied;
  BitmapDescriptor _iconUnavailable;

  List<ChargePoint> _chargePoints = [
    // ChargePoint(
    //   id: 'cp01',
    //   address: Address(
    //     city: 'Nova Milanese',
    //     country: 'Italia',
    //     houseNumber: '18',
    //     street: 'Via Sarajevo',
    //     zipCode: '20834',
    //   ),
    //   status: Status.available,
    //   plug: PlugType.type2,
    //   maxPower: PowerSupply.kW22,
    //   powerType: PowerType.ac,
    //   cost: 0,
    //   position: const LatLng(45.594100, 9.192028),
    // ),
    // ChargePoint(
    //   id: 'cp02',
    //   address: Address(
    //     city: 'Nova Milanese',
    //     country: 'Italia',
    //     houseNumber: '18',
    //     street: 'Via Sarajevo',
    //     zipCode: '20834',
    //   ),
    //   status: Status.available,
    //   plug: PlugType.type2,
    //   maxPower: PowerSupply.kW22,
    //   powerType: PowerType.ac,
    //   cost: 0,
    //   position: const LatLng(45.59348806009438, 9.191465264449239),
    // ),
  ];

  List<ChargePoint> get chargePoints {
    return [..._chargePoints];
  }

  ChargePoint chargePointfromMapMarker(MapMarker marker) {
    return _chargePoints.where((element) => element.id == marker.id).first;
  }

  Future<BitmapDescriptor> _setMarkerIcon(Status status) async {
    //apparentemente se si usano i byte le dimensioni non si buggano su iOS, tengo cosi per sicurezza
    int width = Platform.isAndroid ? 128 : 128;
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
    return await BitmapDescriptor.fromBytes(byte);

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
    final url = Uri.https(
      'michelebanfi.github.io',
      'data/data.geojson',
    );

    // final json =
    //     await DefaultAssetBundle.of(context).loadString("assets/data.json");
    // Map positionMap = jsonDecode(json);

    try {
      final response = await http.get(url);
      final positionMap = json.decode(response.body);
      final List<ChargePoint> loadedChargers = [];

      positionMap['features'].forEach((element) {
        return loadedChargers.add(
          ChargePoint(
            owner: element['properties']['titolare'].toString(),
            id: element['properties']['id'].toString(),
            address: Address(
                city: "Milano",
                street: element['properties']['localita'].toString()),
            status: Status.available,
            plug: null,
            maxPower: null,
            powerType: element['properties']['tipo_ricar'].toString(),
            cost: null,
            position: LatLng(element['geometry']['coordinates'][0][1],
                element['geometry']['coordinates'][0][0]),
          ),
        );
      });
      _chargePoints = loadedChargers;
      notifyListeners();
    } catch (e) {
      print(e);
    }
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
