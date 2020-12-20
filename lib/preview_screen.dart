import 'dart:io' as Io;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:scanner_app/uiuitils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

import 'CameraScreen.dart';
import 'CameraScreenRetake.dart';
import 'package:scanner_app/loader_anim.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class PreviewScreen extends StatefulWidget {
  List<String> imgPaths;

  PreviewScreen({this.imgPaths});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  ImageEditor contourDrawer, tempContourDrawer;

  PageController controller = PageController();
  int imgIndex = 0;
  bool loading = true, editmode = false;

  contourObjState tempContourObj;
  ValueNotifier<contourObjState> notifier;
  bool isOnPageTurning = false;

  void scrollListener() {
    if (isOnPageTurning && controller.page == controller.page.roundToDouble()) {
      setState(() {
        if (editmode) {
          editmode = false;
        }
        imgIndex = controller.page.toInt();
        notifier.value.index = imgIndex;
        contourDrawer = tempContourDrawer;
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning && imgIndex.toDouble() != controller.page) {
      if ((imgIndex.toDouble() - controller.page).abs() > 0.1) {
        setState(() {
          isOnPageTurning = true;
          tempContourDrawer = contourDrawer;
          contourDrawer = null;
        });
      }
    }
  }

  @override
  void initState() {
    tempContourObj = new contourObjState();
    super.initState();
    controller = PageController(
        initialPage: imgIndex, keepPage: true, viewportFraction: 0.85);
    controller.addListener(scrollListener);
    for (int i = 0; i < widget.imgPaths.length; i++) {
      if (i % 2 == 0) {
        tempContourObj.x1.add(40);
        tempContourObj.y1.add(40);
        tempContourObj.x2.add(40);
        tempContourObj.y2.add(260);
        tempContourObj.x3.add(260);
        tempContourObj.y3.add(260);
        tempContourObj.x4.add(260);
        tempContourObj.y4.add(40);
      } else {
        tempContourObj.x1.add(130);
        tempContourObj.y1.add(130);
        tempContourObj.x2.add(130);
        tempContourObj.y2.add(270);
        tempContourObj.x3.add(270);
        tempContourObj.y3.add(270);
        tempContourObj.x4.add(270);
        tempContourObj.y4.add(130);
      }
    }
    tempContourObj.index = imgIndex;
    notifier = ValueNotifier(tempContourObj);
    contourDrawer = new ImageEditor(notifier: notifier);
    loading = false;
    if (widget.imgPaths.length > 1) {
      Fluttertoast.showToast(
          msg: "Swipe to preview!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Page : ${imgIndex + 1} of ${widget.imgPaths.length}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: Container(
          color: Colors.black,
          child: loading
              ? Center(
                  child: ColorLoader3(
                  radius: UIUtills().getProportionalWidth(width: 60),
                  dotRadius: UIUtills().getProportionalWidth(width: 12),
                ))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: PageView(
                        physics: !editmode
                            ? BouncingScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                        controller: controller,
                        children: widget.imgPaths
                            .map((e) => Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      UIUtills()
                                          .getProportionalWidth(width: 10),
                                      0,
                                      UIUtills()
                                          .getProportionalWidth(width: 10),
                                      0),
                                  child: editmode
                                      ? LayoutBuilder(
                                      builder: (BuildContext context, BoxConstraints constraints) => contourAdjust(
                                            e, contourDrawer, notifier, () {
                                            //contourDrawer = new ImageEditor(
                                            //   notifier: notifier);
                                            tempContourObj = notifier.value;
                                            notifier.value = tempContourObj;
                                            setState(() {});
                                          }, constraints.maxHeight,
                                      constraints.maxWidth)
                                      )
                                      : Image.file(
                                          Io.File(e),
                                          fit: BoxFit.fill,
                                        ),

                                  /*Image.file(
                                  Io.File(e),
                                  fit: BoxFit.fill,
                                )*/
                                ))
                            .toList(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: size.width,
                        height: UIUtills().getProportionalHeight(height: 90),
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Visibility(
                              visible: editmode ? false : true,
                              child: IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  getBytesFromFile().then((bytes) {
                                    Share.file(
                                        'Share via',
                                        basename(widget.imgPaths
                                            .elementAt(imgIndex)),
                                        bytes.buffer.asUint8List(),
                                        'image/path');
                                  });
                                },
                              ),
                            ),
                            Visibility(
                              visible: editmode ? false : true,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Vibration.vibrate(duration: 200);
                                  setState(() {
                                    widget.imgPaths.removeAt(imgIndex);
                                    if (imgIndex == widget.imgPaths.length) {
                                      imgIndex--;
                                    }
                                    if (widget.imgPaths.length == 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                              ),
                            ),
                            Visibility(
                              visible: editmode ? false : true,
                              child: IconButton(
                                icon: Icon(
                                  Icons.repeat_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CameraScreenRetake(
                                              imgPaths: widget.imgPaths,
                                              imgIndex: imgIndex,
                                            )),
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                !editmode ? Icons.edit : Icons.edit_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (!editmode) {
                                    editmode = true;
                                  } else {
                                    editmode = false;
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Future<ByteData> getBytesFromFile() async {
    Uint8List bytes = Io.File(widget.imgPaths.elementAt(imgIndex))
        .readAsBytesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }

  Future reqpermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      Fluttertoast.showToast(
          msg: "Save clicked",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
  }
}

class contourAdjust extends StatefulWidget {
  String path;
  ImageEditor contourDrawer;
  ValueNotifier<contourObjState> notifier;
  var contourChanged;
  double height, width;

  contourAdjust(
      path, contourDrawer, notifier, contourChanged(), height, width) {
    this.path = path;
    this.contourDrawer = contourDrawer;
    this.notifier = notifier;
    this.contourChanged = contourChanged;
    this.height = height;
    this.width = width;
  }

  @override
  _contourAdjustState createState() => _contourAdjustState();
}

class _contourAdjustState extends State<contourAdjust> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => onPanStart(details, context),
      onPanUpdate: (details) => onPanUpdate(details, context),
      onPanEnd: (details) => onPanEnd(details, context),
      child: CustomPaint(
        child: Image.file(
          Io.File(widget.path),
          fit: BoxFit.fill,
        ),
        foregroundPainter: widget.contourDrawer,
      ),
    );
  }

  bool eng1 = false, eng2 = false, eng3 = false, eng4 = false;
  Offset stat;

  void onPanStart(DragStartDetails details, BuildContext context) {
    Offset localTouchPosition = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    stat = localTouchPosition;
    if (!eng1 &&
        sqrt(pow(
                    (localTouchPosition.dx -
                        widget.notifier.value.x1
                            .elementAt(widget.notifier.value.index)),
                    2) +
                pow(
                    (localTouchPosition.dy -
                        widget.notifier.value.y1
                            .elementAt(widget.notifier.value.index)),
                    2)) <
            UIUtills().getProportionalWidth(width: 20)) {
      eng1 = true;
    }
    if (!eng2 &&
        sqrt(pow(
                    (localTouchPosition.dx -
                        widget.notifier.value.x2
                            .elementAt(widget.notifier.value.index)),
                    2) +
                pow(
                    (localTouchPosition.dy -
                        widget.notifier.value.y2
                            .elementAt(widget.notifier.value.index)),
                    2)) <
            UIUtills().getProportionalWidth(width: 20)) {
      eng2 = true;
    }
    if (!eng3 &&
        sqrt(pow(
                    (localTouchPosition.dx -
                        widget.notifier.value.x3
                            .elementAt(widget.notifier.value.index)),
                    2) +
                pow(
                    (localTouchPosition.dy -
                        widget.notifier.value.y3
                            .elementAt(widget.notifier.value.index)),
                    2)) <
            UIUtills().getProportionalWidth(width: 20)) {
      eng3 = true;
    }
    if (!eng4 &&
        sqrt(pow(
                    (localTouchPosition.dx -
                        widget.notifier.value.x4
                            .elementAt(widget.notifier.value.index)),
                    2) +
                pow(
                    (localTouchPosition.dy -
                        widget.notifier.value.y4
                            .elementAt(widget.notifier.value.index)),
                    2)) <
            UIUtills().getProportionalWidth(width: 20)) {
      eng4 = true;
    }
  }

  void onPanUpdate(DragUpdateDetails details, BuildContext context) {
    Offset localTouchPosition = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    if (eng1) {
      widget.notifier.value.x1[widget.notifier.value.index] =
          localTouchPosition.dx;
      widget.notifier.value.y1[widget.notifier.value.index] =
          localTouchPosition.dy;
      setState(() {});
      widget.contourChanged();
    }
    if (eng2) {
      widget.notifier.value.x2[widget.notifier.value.index] =
          localTouchPosition.dx;
      widget.notifier.value.y2[widget.notifier.value.index] =
          localTouchPosition.dy;
      setState(() {});
      widget.contourChanged();
    }
    if (eng3) {
      widget.notifier.value.x3[widget.notifier.value.index] =
          localTouchPosition.dx;
      widget.notifier.value.y3[widget.notifier.value.index] =
          localTouchPosition.dy;
      setState(() {});
      widget.contourChanged();
    }
    if (eng4) {
      widget.notifier.value.x4[widget.notifier.value.index] =
          localTouchPosition.dx;
      widget.notifier.value.y4[widget.notifier.value.index] =
          localTouchPosition.dy;
      setState(() {});
      widget.contourChanged();
    }
  }

  void onPanEnd(DragEndDetails details, BuildContext context) {
    if (widget.notifier.value.x1.elementAt(widget.notifier.value.index) >
            widget.notifier.value.x3.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.x1.elementAt(widget.notifier.value.index) >
            widget.notifier.value.x4.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.x2.elementAt(widget.notifier.value.index) >
            widget.notifier.value.x3.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.x2.elementAt(widget.notifier.value.index) >
            widget.notifier.value.x4.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.y1.elementAt(widget.notifier.value.index) >
            widget.notifier.value.y2.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.y1.elementAt(widget.notifier.value.index) >
            widget.notifier.value.y3.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.y4.elementAt(widget.notifier.value.index) >
            widget.notifier.value.y2.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.y4.elementAt(widget.notifier.value.index) >
            widget.notifier.value.y3.elementAt(widget.notifier.value.index) ||
        widget.notifier.value.x1.elementAt(widget.notifier.value.index) < 0 ||
        widget.notifier.value.x2.elementAt(widget.notifier.value.index) < 0 ||
        widget.notifier.value.y1.elementAt(widget.notifier.value.index) < 0 ||
        widget.notifier.value.y4.elementAt(widget.notifier.value.index) < 0 ||
        widget.notifier.value.x4.elementAt(widget.notifier.value.index) >
            widget.width ||
        widget.notifier.value.x3.elementAt(widget.notifier.value.index) >
            widget.width ||
        widget.notifier.value.y2.elementAt(widget.notifier.value.index) >
            widget.height ||
        widget.notifier.value.y3.elementAt(widget.notifier.value.index) >
            widget.height) {
      if (eng1) {
        widget.notifier.value.x1[widget.notifier.value.index] = stat.dx;
        widget.notifier.value.y1[widget.notifier.value.index] = stat.dy;
      }
      if (eng2) {
        widget.notifier.value.x2[widget.notifier.value.index] = stat.dx;
        widget.notifier.value.y2[widget.notifier.value.index] = stat.dy;
      }
      if (eng3) {
        widget.notifier.value.x3[widget.notifier.value.index] = stat.dx;
        widget.notifier.value.y3[widget.notifier.value.index] = stat.dy;
      }
      if (eng4) {
        widget.notifier.value.x4[widget.notifier.value.index] = stat.dx;
        widget.notifier.value.y4[widget.notifier.value.index] = stat.dy;
      }
      Fluttertoast.showToast(
          msg: "This resizing is not possible!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
    eng1 = false;
    eng2 = false;
    eng3 = false;
    eng4 = false;
  }
}

class ImageEditor extends CustomPainter {
  ValueNotifier<contourObjState> notifier, m;
  Paint paint0;
  Paint paint1;
  Context context;

  ImageEditor({this.notifier}) : super(repaint: notifier) {
    paint0 = new Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;
    paint1 = new Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = UIUtills().getProportionalWidth(width: 4)
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        new Offset(notifier.value.x1.elementAt(notifier.value.index),
            notifier.value.y1.elementAt(notifier.value.index)),
        UIUtills().getProportionalWidth(width: 10),
        paint0);
    canvas.drawCircle(
        new Offset(notifier.value.x2.elementAt(notifier.value.index),
            notifier.value.y2.elementAt(notifier.value.index)),
        UIUtills().getProportionalWidth(width: 10),
        paint0);
    canvas.drawCircle(
        new Offset(notifier.value.x3.elementAt(notifier.value.index),
            notifier.value.y3.elementAt(notifier.value.index)),
        UIUtills().getProportionalWidth(width: 10),
        paint0);
    canvas.drawCircle(
        new Offset(notifier.value.x4.elementAt(notifier.value.index),
            notifier.value.y4.elementAt(notifier.value.index)),
        UIUtills().getProportionalWidth(width: 10),
        paint0);
    canvas.drawLine(
        new Offset(notifier.value.x1.elementAt(notifier.value.index),
            notifier.value.y1.elementAt(notifier.value.index)),
        new Offset(notifier.value.x2.elementAt(notifier.value.index),
            notifier.value.y2.elementAt(notifier.value.index)),
        paint1);
    canvas.drawLine(
        new Offset(notifier.value.x2.elementAt(notifier.value.index),
            notifier.value.y2.elementAt(notifier.value.index)),
        new Offset(notifier.value.x3.elementAt(notifier.value.index),
            notifier.value.y3.elementAt(notifier.value.index)),
        paint1);
    canvas.drawLine(
        new Offset(notifier.value.x3.elementAt(notifier.value.index),
            notifier.value.y3.elementAt(notifier.value.index)),
        new Offset(notifier.value.x4.elementAt(notifier.value.index),
            notifier.value.y4.elementAt(notifier.value.index)),
        paint1);
    canvas.drawLine(
        new Offset(notifier.value.x4.elementAt(notifier.value.index),
            notifier.value.y4.elementAt(notifier.value.index)),
        new Offset(notifier.value.x1.elementAt(notifier.value.index),
            notifier.value.y1.elementAt(notifier.value.index)),
        paint1);
    print("repaint");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    print("bool");
    return true;
  }

/*void updateCoordinates(List<double> x1 , List<double> y1 , List<double> x2 , List<double> y2 ,
      List<double> x3 , List<double> y3 , List<double> x4 , List<double> y4){
    this.x1=x1;
    this.y1=y1;
    this.x2=x2;
    this.y2=y2;
    this.x3=x3;
    this.y3=y3;
    this.x4=x4;
    this.y4=y4;
  }
  */

}

class contourObjState {
  List<double> x1 = new List();
  List<double> y1 = new List();
  List<double> x2 = new List();
  List<double> y2 = new List();
  List<double> x3 = new List();
  List<double> y3 = new List();
  List<double> x4 = new List();
  List<double> y4 = new List();
  int index;
}
