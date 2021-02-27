import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Photo extends StatefulWidget {
  Photo({Key key}) : super(key: key);

  @override
  _Photo createState() => _Photo();
}

class _Photo extends State<Photo> {
  @override
  void initState() {}

  _Photo() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Padding(
            padding: const EdgeInsets.all(50.0), child: Text("Photo")
        )
    );
  }
}
