// import 'dart:js';

// import 'dart:html';
// import 'dart:math';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// import 'package:share/share.dart';
// import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurNoticeView extends StatefulWidget {
  @override
  _OurNoticeViewState createState() => _OurNoticeViewState();
}

class _OurNoticeViewState extends State<OurNoticeView> {
  String fileLocation;
  TextEditingController _reviewController = TextEditingController();
  // TextEditingController _ratingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  Widget _assignmentButton(context, bool value) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        value
            ? Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("Assignment Allready Submited")))
            : _bottomsheet(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            value ? Icon(Icons.assignment_turned_in) : Icon(Icons.assignment),
            // Icon(Icons.assignment),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Add Assignment',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool loading = false;
// bool _isLoading = false;
  double _progress;
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
            // backgroundColor: Colors.white,
            title: Text(value.getCurrentGroup.name ?? " loding...."),
            actions: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.home),
              //   onPressed: () async {
              //     Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(builder: (context) => HomeNavigator()),
              //         (route) => false);
              //   },
              // ),
            ]),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection("groups")
                .document(value.getCurrentGroup.id)
                .collection("notice")
                .document(value.getCurrentGroup.currentNoticeid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text("Loading...."),
                );
              } else {
                if (snapshot.data.data == null) {
                  return Center(
                    child: Text("Loading...."),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: Ourcontener(
                      child: ListView(children: [
                        Container(
                          color: Colors.amber,
                          alignment: Alignment.center,
                          child: Text(
                            snapshot.data['noticetype'] ?? "Loading...",
                            style: TextStyle(
                              // color: Colors.amber,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(
                                "Title: ",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data['name'] ?? "Loading...",
                                  style: TextStyle(
                                    // color: Colors.amber,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(
                                "Subject: ",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data['subject'] ?? "Loading...",
                                  style: TextStyle(
                                    // color: Colors.amber,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(
                                "Description:",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "-    ",
                                // style: TextStyle(
                                //   // color: Colors.amber,
                                //   fontSize: 15.0,
                                //   fontWeight: FontWeight.bold,
                                // ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  snapshot.data['description'] ?? "Loading...",
                                  style: TextStyle(
                                    // color: Colors.amber,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        (snapshot.data['noticetype'] == "Assignment")
                            ? _assignmentButton(
                                context, value.getDoneWithCurrentAssignment)
                            : Text(" "),
                      ]),
                    ),
                  );
                }
              }
            }),
      );
    });
  }

  Future getImage() async {
    File file = await FilePicker.getFile(type: FileType.any);
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _uploadImagetoFirebase(file);
  }

  Future<void> _uploadImagetoFirebase(File image) async {
    try {
      CurrentGroup _currentgroup =
          Provider.of<CurrentGroup>(context, listen: false);
      CurrentUser _currentuser =
          Provider.of<CurrentUser>(context, listen: false);

      int randomnumber = Random().nextInt(1000);
      String imageLocation =
          '${_currentgroup.getCurrentGroup.name}/${_currentgroup.getCurrentGroup.currentNoticeid}/${_currentuser.getCurrentUser.uid}${randomnumber}';

      print(imageLocation);
      final StorageReference storageReference =
          FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;

      _addPathtodatabase(imageLocation);

      print("object");
    } catch (e) {
      print(e);
    }
  }

  void _addPathtodatabase(String location) async {
    try {
      final ref = FirebaseStorage().ref().child(location);
      var imageString = await ref.getDownloadURL();
      setState(() {
        fileLocation = imageString;
      });

      // CurrentGroup _currentgroup =
      //     Provider.of<CurrentGroup>(context, listen: false);
      // CurrentUser _currentuser =
      //     Provider.of<CurrentUser>(context, listen: false);

      // await Firestore.instance
      //     .collection("groups")
      //     .document(_currentgroup.getCurrentGroup.id)
      //     .collection("notice")
      //     .document(_currentgroup.getCurrentGroup.currentNoticeid)
      //     .collection("assignment")
      //     .document(_currentuser.getCurrentUser.uid)
      //     .updateData({"imglocation": imageString});
    } catch (e) {
      print(e);
    }
  }

  void _bottomsheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0)),
              height: MediaQuery.of(context).size.height * .60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.add_a_photo,
                          color: Colors.amber,
                          size: 25,
                        ),
                        onPressed: () async {
                          // var image = await ImagePicker.pickImage(
                          //     source: ImageSource.gallery);
                          // _uploadImagetoFirebase(image);
                          File file =
                              await FilePicker.getFile(type: FileType.any);
                          // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                          _uploadImagetoFirebase(file);
                        }),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                          // children: [BackButton()],
                          ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Ourcontener(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _reviewController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.group),
                                  hintText: "Review"),
                              maxLength: 25,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            // TextFormField(
                            //   controller: _ratingController,
                            //   decoration: InputDecoration(
                            //       prefixIcon: Icon(Icons.description),
                            //       hintText: "Rating"),
                            //   maxLength: 50,
                            // ),
                            SizedBox(
                              height: 20.0,
                            ),

                            RaisedButton(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 30),
                                  child: Text(
                                    "Send",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                onPressed: () async {
                                  String uid = Provider.of<CurrentUser>(context,
                                          listen: false)
                                      .getCurrentUser
                                      .uid;

                                  String userName = Provider.of<CurrentUser>(
                                          context,
                                          listen: false)
                                      .getCurrentUser
                                      .fullName;
                                  Provider.of<CurrentGroup>(context,
                                          listen: false)
                                      .finishedAssignment(uid, userName,
                                          _reviewController.text, fileLocation);

                                  Navigator.of(context).pop();
                                })
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
