import 'package:flutter/material.dart';
import 'Camera.dart';
import 'Photo.dart';
import 'MapScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'Follow the Money',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          home: Navigation(title: 'Follow the Money'),
        );
  }
}

class Navigation extends StatefulWidget {
  Navigation({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _Navigation createState() => _Navigation();
}

class _Navigation extends State<Navigation> {
  List num_screens = [0, 1, 2];

  List all_screens = [
    Camera(),
    Photo(),
    MapScreen()
  ];
  List all_screen_names = [
    'Camera',
    'Photo',
    'Map Screen'
  ];

  Widget getScreenButtons(int i) {
    return OutlineButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => all_screens[i]),
          );
        },
        child: Text(all_screen_names[i]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: <Widget>[
                for (var i in num_screens) getScreenButtons(i)
              ],
            )));
  }
}