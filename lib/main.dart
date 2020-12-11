import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner_app/doclistpage.dart';
import 'package:scanner_app/settingspage.dart';
import 'package:scanner_app/uiuitils.dart';
import 'package:scanner_app/CameraScreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scanner App',
      //the name that came when i pressed switch between apps on my phone
      home: BottomNavBarV2(),
    );
  }


}

class BottomNavBarV2 extends StatefulWidget {
  @override
  _BottomNavBarV2State createState() => _BottomNavBarV2State();
}

class _BottomNavBarV2State extends State<BottomNavBarV2> {
  int currentIndex = 0;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> _widgetOptions = <Widget>[
    DocList(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return WillPopScope(

      child: Scaffold(
        body: _widgetOptions.elementAt(currentIndex),
        bottomNavigationBar: Container(
          height: UIUtills().getProportionalHeight(height: 80),
          child: Stack(children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size.width,
                height: UIUtills().getProportionalHeight(height: 80),
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    CustomPaint(
                      size: Size(UIUtills().getProportionalWidth(width: size.width),
                          UIUtills().getProportionalHeight(height: 80)),
                      painter: BNBCustomPainter(),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                          backgroundColor: Colors.deepPurpleAccent,
                          child: Icon(Icons.add_sharp),
                          elevation: 0.1,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CameraScreen()),
                            );
                          }),
                    ),
                    Container(
                      width: size.width,
                      height: UIUtills().getProportionalHeight(height: 80),
                      padding: EdgeInsets.fromLTRB(
                          0, 0, 0, UIUtills().getProportionalHeight(height: 5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.article_outlined,
                                color: currentIndex == 0
                                    ? Colors.deepPurpleAccent
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(0);
                              }),
                          Container(
                            width:
                            UIUtills().getProportionalWidth(width: size.width) *
                                0.17,
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: currentIndex == 1
                                    ? Colors.deepPurpleAccent
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(1);
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
      onWillPop: () {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Exit"),
                content: Text("Are you sure you want to exit?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
        return Future.value(true);
      },
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }


}


