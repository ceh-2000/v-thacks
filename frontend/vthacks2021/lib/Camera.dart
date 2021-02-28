import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart' as loc;
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vthacks2021/MapScreen.dart';

import 'Photo.dart';
import 'main.dart';

class Camera extends StatefulWidget {
  Camera({Key key}) : super(key: key);

  @override
  _Camera createState() => _Camera();
}

class _Camera extends State<Camera> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // Variable to get the user's location
  loc.Location _location = new loc.Location();
  bool _serviceEnabled;
  loc.PermissionStatus _permissionGranted;
  loc.LocationData _locationData;

  // Local variables to take photo
  CameraController _controller;

  // List of Google-Vision extracted longitude and latitude
  List<String> _latitudes;
  List<String> _longitudes;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    getLocationOfUser();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  // Helper method to take photo and save to a specified path
  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision-Images';
    await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      // Captures image and saves it to the specified path
      await _controller.takePicture(imagePath);
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }
    return imagePath;
  }

  Future<String> _uploadImage(String path) async {
    File imageFile = File(path);

    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');

    String newPath = formattedDateTime + '.jpg';
    String imageUrl;

    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$newPath');

    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    await uploadTask.whenComplete(() async {
      imageUrl = await uploadTask.snapshot.ref.getDownloadURL();
    });

    return imageUrl;
  }

  Future<void> _getVisionInfoFromBill(image_url) async {
    // Get the latitudes and longitudes and store in _latitudes and _longitudes
    // Use a post request and pass the location and latitude and longitude
    String bodyOfUrl = """
    {"url" : "${image_url}", 
    "lat" : ${_locationData.latitude}, 
    "lon" : ${_locationData.longitude}}""";

    String flaskEndpoint = "https://vthacks2021.firebaseapp.com/";
    // Our other post request goes here
    http.Response resFlask = await http.post(flaskEndpoint,
        headers: {"Content-Type": "application/json"}, body: bodyOfUrl);

    var responseData = resFlask.body.toString();

    // To get content from a list returned with JSON we have to map the data
    print(responseData);
    _latitudes = responseData
        .split('[')
        .elementAt(1)
        .split(']')
        .elementAt(0)
        .split(', ');
    _longitudes = responseData
        .split('[')
        .elementAt(2)
        .split(']')
        .elementAt(0)
        .split(', ');

    // RegExp exp = new RegExp(r"\[(.+)\]");
    // Iterable<RegExpMatch> matches = exp.allMatches(responseData);
    // print(matches.toString());
  }

  // Helper methods for location
  void getLocationOfUser() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
  }

  // Adjust our CameraPreview for the ratio of our screen size
  Widget _cameraWidget(context) {
    // Get screen size
    final size = MediaQuery.of(context).size;

    // Calculate scale for aspect ratio widget
    var scale = _controller.value.aspectRatio / size.aspectRatio;

    // Check if adjustments are needed...
    if (_controller.value.aspectRatio < size.aspectRatio) {
      scale = 1 / scale;
    }

    return Transform.scale(
      scale: scale,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? Stack(
              children: <Widget>[
                _cameraWidget(context),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.teal[100],
                      icon: Icon(
                        Icons.camera,
                        color: Colors.teal,
                        size: 60.0,
                      ),
                      label: Text("Click", style: TextStyle(fontSize: 60)),
                      onPressed: () async {
                        await _takePicture().then((String path) async {
                          if (path != null) {
                            String url = await _uploadImage(path);
                            await _getVisionInfoFromBill(url);
                            print(_latitudes);
                            print(_longitudes);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                    lats: _latitudes, lons: _longitudes, curLat: _locationData.latitude, curLon: _locationData.longitude),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                )
              ],
            )
          : Container(
              color: Colors.teal,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
