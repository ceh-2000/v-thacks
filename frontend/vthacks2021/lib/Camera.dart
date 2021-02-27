import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class Camera extends StatefulWidget {
  Camera({Key key}) : super(key: key);

  @override
  _Camera createState() => _Camera();
}

class _Camera extends State<Camera> {
  // Variable to get the user's location
  Location _location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  @override
  void initState() {
    getLocationOfUser();
  }

  _Camera() {}

  // Helper methods
  void getLocationOfUser() async{
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    print(_locationData.latitude.toString()+' '+_locationData.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Padding(
            padding: const EdgeInsets.all(50.0), child: Text("Camera")
        )
    );
  }
}
