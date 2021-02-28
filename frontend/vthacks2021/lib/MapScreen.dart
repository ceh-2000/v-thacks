import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'Navigation.dart';

class MapScreen extends StatefulWidget {
  List<String> lats;
  List<String> lons;
  double curLat;
  double curLon;

  MapScreen({Key key, this.lats, this.lons, this.curLat, this.curLon})
      : super(key: key);

  @override
  _MapScreen createState() => _MapScreen(lats, lons, curLat, curLon);
}

class _MapScreen extends State<MapScreen> {
  final Color backgroundColor = Color.fromRGBO(235, 237, 238, 1.0);
  final Color accentColor = Color.fromRGBO(207, 220, 240, 1.0);
  final Color textColor = Color.fromRGBO(62, 63, 59, 1.0);

  // Private variables
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  LatLng _center = const LatLng(37.280769, -76.720512);
  List<String> _lats;
  List<String> _lons;
  double _curLat;
  double _curLon;

  // Private class constructor
  _MapScreen(lats, lons, curLat, curLon) {
    this._lats = lats;
    this._lons = lons;
    this._curLat = curLat;
    this._curLon = curLon;
    this._center = LatLng(curLat, curLon);
  }

  // Initialize our custom marker here
  @override
  void initState() {
    super.initState();
    setCustomMapLocationIcon();
  }

  // Helper methods
  void setCustomMapLocationIcon() async {
    // Extract our custom pin image
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/money.png');

    // Plot all markers
    for (var i = 0; i < _lats.length; i++) {
      LatLng _markerLocation =
          LatLng(double.parse(_lats[i]), double.parse(_lons[i]));
      _markers.add(Marker(
          markerId: MarkerId('' + i.toString()),
          position: _markerLocation,
          icon: _pinLocationIcon));
    }
  }

  void updateMarkerDisplay() {
    setState(() {
      // Plot all markers
      for (var i = 0; i < _lats.length; i++) {
        LatLng _markerLocation =
            LatLng(double.parse(_lats[i]), double.parse(_lons[i]));
        _markers.add(Marker(
            markerId: MarkerId('' + i.toString()),
            position: _markerLocation,
            icon: _pinLocationIcon));
      }
    });
  }

  // Display
  @override
  Widget build(BuildContext context) {
    CameraPosition _initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: _center);

    return Scaffold(
        body: Stack(children: <Widget>[
      GoogleMap(
          myLocationButtonEnabled: true,
          markers: _markers,
          initialCameraPosition: _initialLocation,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            updateMarkerDisplay();
          }),
    Padding(
    padding: const EdgeInsets.all(50.0),
    child: Container(
    alignment: Alignment.bottomCenter,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: accentColor,
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.home, size: 50.0),
                SizedBox(width: 10),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                )
              ]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Navigation(),
              ),
            );
          },
    )))
    ]));
  }
}
