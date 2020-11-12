import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:scanner_app/uiuitils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> imgPaths;
  PreviewScreen({this.imgPaths});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>{
  PageController controller = PageController(initialPage: 0
  ,viewportFraction: 0.85);
  int currentindex=0;
  @override
  void initState() {
    // TODO: implement initState
    /*Future.delayed(const Duration(milliseconds: 500), () {
      if(widget.imgPaths.length>1) {
        Fluttertoast.showToast(
            msg: "Swipe to preview!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
      controller.animateToPage(1,
          duration: Duration(milliseconds: 600), curve: Curves.linear);
      controller.animateToPage(0,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    });*/
    if(widget.imgPaths.length>1) {
      Fluttertoast.showToast(
          msg: "Swipe to preview!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  controller: controller,
                  onPageChanged: (index) {
                    setState(() {
                      currentindex = index;
                    });
                  },
                  children: widget.imgPaths
                      .map((e) => Padding(
                    padding: EdgeInsets.fromLTRB(UIUtills().getProportionalWidth(width: 10), 0, UIUtills().getProportionalWidth(width: 10), 0),
                        child: Image.file(
                              File(e),
                              fit: BoxFit.fill,
                            ),
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
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          getBytesFromFile().then((bytes) {
                            Share.file(
                                'Share via',
                                basename(
                                    widget.imgPaths.elementAt(currentindex)),
                                bytes.buffer.asUint8List(),
                                'image/path');
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Vibration.vibrate(duration: 200);
                          setState(() {
                            widget.imgPaths.removeAt(currentindex);
                            if(currentindex==widget.imgPaths.length){
                            currentindex--;
                            }
                            if(widget.imgPaths.length==0){
                              Navigator.of(context).pop(true);
                            }
                          });
                        },
                      ),
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
    Uint8List bytes = File(widget.imgPaths.elementAt(currentindex))
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
