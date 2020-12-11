import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:scanner_app/uiuitils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

class DocList extends StatefulWidget {
  @override
  _DocListState createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  bool emptystat = false;
  bool multiSelect = false;
  final List<String> sortOptions = ["Asc", "Desc"];
  String selectedSortOption = "Asc";
  List<String> tempcont = <String>[
    "Abcd1",
    "Abcd2",
    "Abcd3",
    "Abcd4",
    "Abcd5",
    "Abcd6",
    "Abcd7",
    "Abcd8",
    "Abcd9",
    "Abcd10",
    "Abcd11",
    "Abcd12",
    "Abcd13",
    "End",
  ];
  List<bool> checkBoxValues = List<bool>();
  int numDocsChecked = 0;
  List<String> disptempcont = List<String>();

  @override
  void initState() {
    disptempcont = tempcont;
    disptempcont.sort((a, b) => a.compareTo(b));
    checkBoxValues = List.filled(tempcont.length, false, growable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UIUtills().updateScreenDimesion(width: size.width, height: size.height);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        width: UIUtills().getProportionalWidth(width: size.width),
        height: UIUtills().getProportionalHeight(height: size.height),
        color: Colors.white54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                  UIUtills().getProportionalWidth(width: 7.5),
                  UIUtills().getProportionalHeight(height: 50),
                  0,
                  0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: multiSelect? false:true,
                    child: Text(
                      "Your Documents",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: multiSelect? true:false,
                    child: Text(
                      numDocsChecked.toString()+" selected",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: UIUtills().getProportionalWidth(width: size.width) *
                        0.15,
                  ),
                  Visibility(
                    visible: multiSelect? false:true,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: GestureDetector(
                          child: Text(
                            "Select",
                            style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          onTap: () {
                            if(!multiSelect)
                              setState((){
                                multiSelect = true;
                              });
                          },
                        ),
                      ),
                  ),

                  Visibility(
                    visible: multiSelect? true:false,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black54,
                      ),
                      iconSize: UIUtills().getProportionalWidth(width: 20),
                      onPressed: () {
                        showAlertDialog(context);
                      },
                    ),
                  ),
                  Visibility(
                    visible: multiSelect? true:false,
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.black54,
                      ),
                      iconSize: UIUtills().getProportionalWidth(width: 20),
                      onPressed: () {

                      },
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
            visible: multiSelect? false:true,
            child: Container(
                height: UIUtills().getProportionalHeight(height: 70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        width: UIUtills().getProportionalWidth(width: 225),
                        child: TextField(
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                            filled: true,
                            fillColor: Colors.grey[250],
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                            hintText: 'Search',
                            focusColor: Colors.deepPurpleAccent,
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(const Radius.circular(14)),
                            ),
                          ),
                          onChanged: (text) {
                            text = text.toLowerCase();
                            setState(() {
                              disptempcont = tempcont.where((note) {
                                var noteTitle = note.toLowerCase();
                                return noteTitle.contains(text);
                              }).toList();
                            });
                          },
                        ),
                      ),
                    DropdownButton<String>(
                          value: selectedSortOption,
                          icon: Icon(Icons.sort),
                          iconSize: UIUtills().getProportionalWidth(width: 35),
                          items: sortOptions.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                              value: value,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSortOption = value;
                              if (selectedSortOption == "Asc") {
                                disptempcont.sort((a, b) => a.compareTo(b));
                              } else if (selectedSortOption == "Desc") {
                                disptempcont.sort((b, a) => a.compareTo(b));
                              }
                            });
                          }),
                  ],
                ),
              ),
            ),
            Container(
              height: UIUtills().getProportionalHeight(height: 400),
              color: Colors.white54,
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount: disptempcont.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          UIUtills().getProportionalWidth(width: 10),
                          0,
                          UIUtills().getProportionalWidth(width: 10),
                          UIUtills().getProportionalHeight(height: 10)),
                      child: FocusedMenuHolder(
                        blurSize: 3,
                        blurBackgroundColor: Colors.white,
                        onPressed: () {},
                        menuWidth: UIUtills()
                            .getProportionalWidth(width: size.width / 2),
                        animateMenuItems: false,
                        menuItemExtent:
                        UIUtills().getProportionalHeight(height: 37.5),
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                            title: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                ),
                              ),
                            onPressed: () {
                              if(numDocsChecked != 0)
                                 showAlertDialog(context, index: index);
                            },
                            trailingIcon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.deepPurpleAccent,
                          )
                        ],
                        child: Card(
                          child: ListTile(
                            tileColor: Colors.white,
                            onTap: () {
                              if(multiSelect){
                                setState((){
                                  checkBoxValues[index] = !checkBoxValues[index];
                                  if(checkBoxValues[index])
                                    numDocsChecked++;
                                  else
                                    numDocsChecked--;
                                });
                              }
                              else {
                                Fluttertoast.showToast(
                                    msg: "Item CLicked : ${index}",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            title: Text(
                              disptempcont.elementAt(index),
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/icon.jpg'),
                            ),
                            trailing: Opacity(
                              opacity: multiSelect? 1 : 0,
                              child: Checkbox(
                                value: checkBoxValues[index],
                                activeColor: Colors.deepPurpleAccent,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    checkBoxValues[index] = newValue;
                                    if(checkBoxValues[index])
                                      numDocsChecked++;
                                    else
                                      numDocsChecked--;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }


  void deleteDocuments(int index){
    if(index != -1)
      tempcont.removeAt(index);
    else{
      int i=0;
      while( i < checkBoxValues.length )
        if(checkBoxValues[i]){
          checkBoxValues.removeAt(i);
           tempcont.removeAt(i);
        }
        else i++;
        numDocsChecked = 0;
        multiSelect = false;
    }
  }

  showAlertDialog(BuildContext context , {int index = -1}) {

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
          deleteDocuments(index);
          disptempcont = tempcont;
          if (selectedSortOption == "Asc") {
            disptempcont.sort((a, b) => a.compareTo(b));
          } else if (selectedSortOption == "Desc") {
            disptempcont.sort((b, a) => a.compareTo(b));
          }
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Are you sure?"),
      content: multiSelect ? Text("All Documents will be deleted permanently.") : Text("Document will be deleted permanently."),
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
