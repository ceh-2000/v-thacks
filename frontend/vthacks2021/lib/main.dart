import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'Camera.dart';
import 'MapScreen.dart';
import 'Navigation.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(207, 220, 240, .1),
      100: Color.fromRGBO(207, 220, 240, .2),
      200: Color.fromRGBO(207, 220, 240, .3),
      300: Color.fromRGBO(207, 220, 240, .4),
      400: Color.fromRGBO(207, 220, 240, .5),
      500: Color.fromRGBO(207, 220, 240, .6),
      600: Color.fromRGBO(207, 220, 240, .7),
      700: Color.fromRGBO(207, 220, 240, .8),
      800: Color.fromRGBO(207, 220, 240, .9),
      900: Color.fromRGBO(207, 220, 240, 1),
    };
    MaterialColor myColor = MaterialColor(0xFFcfdcf0, color);

    return MaterialApp(
      title: 'Follow the Money',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'BebasNeue',
        primarySwatch: myColor,
      ),
      home: Navigation(title: 'Follow the Money'),
    );
  }
}
