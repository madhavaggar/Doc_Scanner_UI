import 'package:flutter/material.dart';
import 'package:scanner_app/uiuitils.dart';

class Settings extends StatefulWidget {
  @override
  _DocListState createState() => _DocListState();
}

class _DocListState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return Container(
      width: UIUtills().getProportionalWidth(width: size.width),
      height: UIUtills().getProportionalHeight(height: size.height ),
      padding: EdgeInsets.fromLTRB(UIUtills().getProportionalWidth(width: 10),
          UIUtills().getProportionalHeight(height: 40), 0, 0),
      child: Text('Settings Screen'),
    );
  }
}
