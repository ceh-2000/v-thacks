import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key key}) : super(key: key);

  @override
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  @override
  void initState() {}

  _MapScreen() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Padding(
            padding: const EdgeInsets.all(50.0), child: Text("Map Screen")
        )
    );
  }
}
