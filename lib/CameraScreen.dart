import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scanner_app/preview_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner_app/uiuitils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State with RouteAware {
  CameraController controller;
  List cameras;
  int selectedCameraIndex;
  List<String> imgPaths = List<String>();

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _cameraPreviewWidget(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: UIUtills().getProportionalHeight(height: 90),
                  width: size.width,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _cameraControlWidget(context),
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

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _cameraControlWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewScreen(
                            imgPaths: imgPaths,
                          )),
                ).then((value) {
                      setState(() {
                      });
                    });
              },
              child: Container(
                  height: UIUtills().getProportionalHeight(height: 60),
                  width: UIUtills().getProportionalWidth(width: 70),
                  child: Stack(children: [
                    Positioned(
                      top: UIUtills().getProportionalHeight(height: 5),
                      left: UIUtills().getProportionalWidth(width: 5),
                      child: Container(
                          height: UIUtills().getProportionalHeight(height: 50),
                          width: UIUtills().getProportionalWidth(width: 60),
                          child: imgPaths.length == 0
                              ? null
                              : Image.file(
                                  File(imgPaths.elementAt(imgPaths.length - 1)),
                                  fit: BoxFit.fill,
                                )),
                    ),
                    Positioned(
                      top: UIUtills().getProportionalHeight(height: 0),
                      right: UIUtills().getProportionalWidth(width: 0),
                      child: Opacity(
                        opacity: imgPaths.length == 0 ? 0 : 1,
                        child: Container(
                          height: UIUtills().getProportionalHeight(height: 25),
                          width: UIUtills().getProportionalWidth(width: 25),
                          decoration: BoxDecoration(
                              color: Colors.orange, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              "${imgPaths.length}",
                              style: UIUtills().getTextStyleRegular(
                                color: Colors.white,
                                fontsize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        right: UIUtills().getProportionalWidth(width: 0),
                        top: UIUtills().getProportionalHeight(height: 25),
                        child: Opacity(
                          opacity: imgPaths.length == 0 ? 0 : 1,
                          child: Container(
                            height:
                                UIUtills().getProportionalHeight(height: 15),
                            width: UIUtills().getProportionalWidth(width: 15),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.black,
                              size:
                                  UIUtills().getProportionalHeight(height: 14),
                            ),
                          ),
                        ))
                  ])),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.camera,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _onCapturePressed(context);
                });
              },
            ),
            Container(
              height: UIUtills().getProportionalHeight(height: 60),
              width: UIUtills().getProportionalWidth(width: 70),
              child: Center(
                child: Opacity(
                  opacity: imgPaths.length == 0 ? 0 : 1,
                  child: IconButton(
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    iconSize: UIUtills().getProportionalWidth(width: 30),
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  void _onCapturePressed(context) async {
    try {
      final path =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await controller.takePicture(path);
      imgPaths.add(path);
    } catch (e) {
      _showCameraException(e);
    }
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {Navigator.of(context).pop();},
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed:  () {
        setState(() {
          Vibration.vibrate(duration: 200);
          imgPaths.clear();
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Are you sure?"),
      content: Text("All pictures will be lost."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
