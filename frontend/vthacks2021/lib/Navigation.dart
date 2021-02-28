import 'package:flutter/material.dart';
import 'Camera.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Navigation extends StatefulWidget {
  Navigation({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _Navigation createState() => _Navigation();
}

class _Navigation extends State<Navigation> {
  final Color backgroundColor = Color.fromRGBO(235, 237, 238, 1.0);
  final Color accentColor = Color.fromRGBO(207, 220, 240, 1.0);
  final Color textColor = Color.fromRGBO(62, 63, 59, 1.0);

  List<String> moneyFacts = [
    "There are almost 40 billion bills in circulation currently.",
    "The Federal Reserve is the central bank of the United States and is in charge of the monetary financial system.",
    "The Bureau of Engraving and Printing is responsible for producing all paper currency in the United States.",
    "Pennies cost almost 2 cents per coin to manufacture.",
    "The 1913 Liberty Head nickel sold for \$3.7 million at auction in 2010."
  ];

  String _getRandomMoneyFact() {
    int randomIndex = Random().nextInt(moneyFacts.length);
    return moneyFacts[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Image.asset('images/logo.png'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: accentColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Camera()),
                  );
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text(
                    'Follow the money',
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  )
                ])),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: EdgeInsets.all(35.0),
                child: Text(
                  _getRandomMoneyFact(),
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ))
          ],
        )));
  }
}
