import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  List<double> lats;
  List<double> lons;

  MapScreen({Key key, this.lats, this.lons}) : super(key: key);

  @override
  _MapScreen createState() => _MapScreen(lats, lons);
}

class _MapScreen extends State<MapScreen> {
  // Private variables
  BitmapDescriptor _pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  final LatLng _center = const LatLng(37.280769, -76.720512);
  List<double> _lats;
  List<double> _lons;
  String _mapStyle;

  // Private class constructor
  _MapScreen(lats, lons) {
    this._lats = lats;
    this._lons = lons;
  }

  // Initialize our custom marker here
  @override
  void initState(){
    super.initState();
    loadMapStyle();
    setCustomMapLocationIcon();
  }

  // Helper methods
  void setCustomMapLocationIcon() async{
    // Extract our custom pin image
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(
        devicePixelRatio: 2.5
    ), 'images/money.png');

    // Plot all markers
    for(var i = 0; i < _lats.length; i++){
      LatLng _markerLocation = LatLng(_lats[i], _lons[i]);
      _markers.add(
          Marker(
              markerId: MarkerId(''+i.toString()),
              position: _markerLocation,
              icon: _pinLocationIcon
          )
      );
    }
  }

  void loadMapStyle() async{
    _mapStyle = await rootBundle.loadString('images/map.json');
  }

  // Display
  @override
  Widget build(BuildContext context) {
    CameraPosition _initialLocation = CameraPosition(
        zoom: 16,
        bearing: 30,
        target: _center);

    return GoogleMap(
      myLocationButtonEnabled: true,
      markers: _markers,
      initialCameraPosition: _initialLocation,
      onMapCreated: (GoogleMapController controller){
        _controller.complete(controller);
        controller.setMapStyle(_mapStyle);

      },

    );
  }
}
