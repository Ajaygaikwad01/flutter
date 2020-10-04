import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurNoticeView extends StatefulWidget {
  @override
  _OurNoticeViewState createState() => _OurNoticeViewState();
}

class _OurNoticeViewState extends State<OurNoticeView> {
  @override
  void initState() {
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

  List<String> fileurl = List();
  List<String> _filename = List();
  TextEditingController _reviewController = TextEditingController();
  bool loading = false;

  // double _progress;
  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);

    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(value.getCurrentGroup.name ?? " loding...."),
        ),
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

    if (file != null) {
      progressdialog.show();
      progressdialog.update(message: "Uploding ....");
    }
    String filename = file.path.split("/").last;

    _uploadImagetoFirebase(file, filename);
  }

  Future<void> _uploadImagetoFirebase(File image, String filename) async {
    try {
      CurrentGroup _currentgroup =
          Provider.of<CurrentGroup>(context, listen: false);
      CurrentUser _currentuser =
          Provider.of<CurrentUser>(context, listen: false);

      // int randomnumber = Random().nextInt(1000);
      String imageLocation =
          '${_currentgroup.getCurrentGroup.name}/${_currentgroup.getCurrentGroup.currentNoticeid}/${_currentuser.getCurrentUser.uid}/$filename';

      print(imageLocation);
      final StorageReference storageReference =
          FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);

      await uploadTask.onComplete;
      // uploadTask.events.listen((event) {
      //   setState(() {
      //     _progress = event.snapshot.bytesTransferred.toDouble() /
      //         event.snapshot.totalByteCount.toDouble();
      //   });
      // });
      // print(_progress);
      // progressdialog.update(
      //     message: "Uploading..${(_progress).toStringAsFixed(2)}%");
      _addPathtodatabase(imageLocation, filename);
      print("object");

      progressdialog.update(message: "Done.. Press Send Button !!");
    } catch (e) {
      print(e);
    }
  }

  String len;
  void _addPathtodatabase(String location, String filename) async {
    try {
      final ref = FirebaseStorage().ref().child(location);
      var imageString = await ref.getDownloadURL();

      if (imageString != null) {
        setState(() {
          fileurl.add(imageString);
          // loading = !loading;
          _filename.add(filename);
        });

        progressdialog.hide().then((isHidden) {
          print(isHidden);
        });
      }
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.storage,
                              color: Colors.amber,
                              size: 30,
                            ),
                            onPressed: () async {
                              setState(() {
                                len = fileurl.length.toString();
                              });
                              getImage();
                            }),
                        Text("    $len select File From storage",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            )),

                        // child: Text("${_filename}",
                        //     style: TextStyle(
                        //       color: Colors.blueAccent,
                        //       fontWeight: FontWeight.bold,
                        //       fontStyle: FontStyle.italic,
                        //     )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.group),
                                hintText: "Review/Id/Comment"),
                            maxLength: 25,
                          ),
                          SizedBox(
                            height: 5.0,
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
                                setState(() {
                                  loading = !loading;
                                });
                                String uid = Provider.of<CurrentUser>(context,
                                        listen: false)
                                    .getCurrentUser
                                    .uid;

                                String userName = Provider.of<CurrentUser>(
                                        context,
                                        listen: false)
                                    .getCurrentUser
                                    .fullName;

                                // List<String> selectedfile = List();
                                // selectedfile.add(fileLocation);

                                Provider.of<CurrentGroup>(context,
                                        listen: false)
                                    .finishedAssignment(
                                        uid,
                                        userName,
                                        _reviewController.text,
                                        fileurl,
                                        _filename);

                                Navigator.of(context).pop();
                              }),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Don't Forgot to press SEND button",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
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
