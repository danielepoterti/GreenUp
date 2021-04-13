import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_up/models/chargepoint_model.dart';
import 'package:green_up/providers/chargepoints_provider.dart';
import 'package:green_up/services/map_marker.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].
  static Future<BitmapDescriptor> getMarkerImageFromUrl(
    String url, {
    int targetWidth,
  }) async {
    assert(url != null);

    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    if (targetWidth != null) {
      markerImageBytes = await _resizeImageBytes(
        markerImageBytes,
        targetWidth,
      );
    }

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.
  static Future<BitmapDescriptor> _getClusterMarker(
    int clusterSize,
    Color clusterColor,
    Color textColor,
    int width,
  ) async {
    assert(clusterSize != null);
    assert(clusterColor != null);
    assert(width != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  static Future<Uint8List> _resizeImageBytes(
    Uint8List imageBytes,
    int targetWidth,
  ) async {
    assert(imageBytes != null);
    assert(targetWidth != null);

    final Codec imageCodec = await instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await imageCodec.getNextFrame();

    final ByteData byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    return byteData.buffer.asUint8List();
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    assert(markers != null);
    assert(minZoom != null);
    assert(maxZoom != null);
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          MapMarker(
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static Future<List<Marker>> getClusterMarkers(
    Fluster<MapMarker> clusterManager,
    double currentZoom,
    Color clusterColor,
    Color clusterTextColor,
    int clusterWidth,
    List<double> bbox,
    Function _handleMarkerClickCluster,
    Function _handleMarkerClickMarker,
  ) {
    assert(currentZoom != null);
    assert(clusterColor != null);
    assert(clusterTextColor != null);
    assert(clusterWidth != null);
    if (clusterManager == null) return Future.value([]);

    return Future.wait(clusterManager
        .clusters(bbox, currentZoom.toInt())
        .map((mapMarker) async {
      if (mapMarker.isCluster) {
        mapMarker.handleMarkerClick = _handleMarkerClickCluster;
        mapMarker.icon = await _getClusterMarker(
          mapMarker.pointsSize,
          clusterColor,
          clusterTextColor,
          clusterWidth,
        );
      } else {
        mapMarker.handleMarkerClick = _handleMarkerClickMarker;
      }
      return mapMarker.toMarker();
    }).toList());
  }

  //TODO: check for duplicated variable in logic
  static ChargePoints data;
  static List<MapMarker> markersSelected = [];
  static Fluster<MapMarker> clusterManager;
  static final int minClusterZoom = 0;
  static final int maxClusterZoom = 19;
  static double currentZoomLevel = 0;
  static double currentZoom = 15;
  static final Color clusterColor = Colors.blue;
  static final Color clusterTextColor = Colors.white;
  static List<double> box = [0, 0, 0, 0];
  static GoogleMapController controllerMap;
  static Completer<GoogleMapController> controllerCompleterMap = Completer();
  static List<ChargePoint> nearbyChargePoints = [];
  static bool isChargePointPressed = false;
  static AnimationController controllerChargePointCard;
  static Animation<Offset> offsetAnimation;
  static final Set<Marker> markers = Set();
  static final CameraPosition kRoma = CameraPosition(
    target: LatLng(41.893056, 12.482778),
    zoom: 11,
  );
  static String styleOfMapJSON;
  static bool isSliding = false;
  static ChargePoint selectedForTransaction;
  static AssetImage chargingGif = AssetImage("assets/images/battery-charge.gif",);

  // static Future<void> initMarkers() async {
  //   final List<MapMarker> markers = [];
  //   markers.addAll(data.markers);
  //   markersSelected.addAll(data.markers);
  //   clusterManager = await initClusterManager(
  //     markers,
  //     minClusterZoom,
  //     maxClusterZoom,
  //   );
  //   await MapScreen.updateMarkers();
  // }

  static Future<void> updateZoomLevel([double updatedZoom]) async {
    LatLngBounds area = await controllerMap.getVisibleRegion();
    MapHelper.box = [
      area.southwest.longitude,
      area.southwest.latitude,
      area.northeast.longitude,
      area.northeast.latitude
    ];
    MapHelper.currentZoomLevel = updatedZoom;
  }

  //callback that handle markers tap anz zoom on tapped marker
  static Future<void> handleMarkerClickCluster(double long, double lat) async {
    // TODO: check this duplicated variable
    final GoogleMapController controller = await controllerCompleterMap.future;
    currentZoom = await controller.getZoomLevel();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(lat, long),
          zoom: currentZoom + 3,
        ),
      ),
    );
  }

  static double getDistanceFromLatLonInKm(
      double lat1, double lon1, double lat2, double lon2) {
    double R = 6371.0; // Radius of the earth in km
    double dLat = deg2rad(lat2 - lat1); // deg2rad below
    double dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c; // Distance in km
    return d;
  }

  static double deg2rad(double deg) {
    return deg * (pi / 180.0);
  }

  static void setMapstyle(GoogleMapController controller) async {
    controller.setMapStyle(styleOfMapJSON);
  }
}
