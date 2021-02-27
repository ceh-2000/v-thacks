import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  Camera({Key key}) : super(key: key);

  @override
  _Camera createState() => _Camera();
}

class _Camera extends State<Camera> {
  @override
  void initState() {}

  _Camera() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Padding(
            padding: const EdgeInsets.all(50.0), child: Text("Camera")
        )
    );
  }
}
