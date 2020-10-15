import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurNoticePage extends StatefulWidget {
  @override
  _OurNoticePageState createState() => _OurNoticePageState();
}

class _OurNoticePageState extends State<OurNoticePage> {
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
            : getImage();
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
                'Attach Document',
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
  List<String> _filelocation = List();
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
        backgroundColor: Color(0xFF21BFBD),
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
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.data.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Container(
                                width: 125.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.cached),
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.menu),
                                      color: Colors.white,
                                      onPressed: () {},
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                      SizedBox(height: 25.0),
                      Padding(
                        padding: EdgeInsets.only(left: 40.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                                snapshot.data['noticetype'] + ':' ??
                                    "Loading...",
                                style: TextStyle(
                                    // fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0)),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Text(snapshot.data['name'] ?? "Loading...",
                                  style: TextStyle(
                                      // fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontSize: 24.0)),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Container(
                        height: MediaQuery.of(context).size.height - 185.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(75.0)),
                        ),
                        child: ListView(
                          // primary: false,
                          padding:
                              EdgeInsets.only(left: 25.0, right: 20.0, top: 15),
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      "Subject: ",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        snapshot.data['subject'] ??
                                            "Loading...",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      "Description:",
                                      style: TextStyle(
                                        color: Colors.redAccent,
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
                            ),
                            Expanded(
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.data['description'] ??
                                            "Loading...",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            (snapshot.data['noticetype'] == "Assignment")
                                ? _assignmentButton(
                                    context, value.getDoneWithCurrentAssignment)
                                : Text(" "),
                            SizedBox(
                              height: 15,
                            ),
                            (_filename.length != null)
                                ? Visibility(
                                    visible:
                                        (value.getDoneWithCurrentAssignment !=
                                            true),
                                    child: Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 30),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          // scrollDirection: Axis.horizontal,
                                          itemCount: _filename.length,
                                          itemBuilder: (BuildContext context,
                                                  int index) =>
                                              Card(
                                            color: Colors.white30,
                                            child: Center(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                    child: Text("    " +
                                                        _filename[index])),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.cancel,
                                                    ),
                                                    onPressed: () async {
                                                      setState(() {
                                                        loading = !loading;
                                                      });
                                                      _filename.removeAt(index);
                                                      fileurl.removeAt(index);
                                                      // await FirebaseStorage.instance
                                                      //     .ref()
                                                      //     .child(
                                                      //         _filelocation[index])
                                                      //     .delete();
                                                      // _filelocation.removeAt(index);
                                                      // print();
                                                    })
                                              ],
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(""),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
                              child: Expanded(
                                child: TextFormField(
                                  controller: _reviewController,
                                  decoration: InputDecoration(
                                      hintText: "Review/Id/Comment"),
                                  maxLength: 30,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
                              child: Expanded(
                                child: RaisedButton(
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
                                      String uid = Provider.of<CurrentUser>(
                                              context,
                                              listen: false)
                                          .getCurrentUser
                                          .uid;

                                      String userName =
                                          Provider.of<CurrentUser>(context,
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

                                      // Navigator.of(context).pop();
                                    }),
                              ),
                            ),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
                              child: Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      Text("Don't Forgot to press SEND button",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
      setState(() {
        _filelocation.add(imageLocation);
      });

      // print(imageLocation);
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
      // print("object");

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

      String retval = await ref.getName();
      print(retval);
      if (imageString != null) {
        setState(() {
          fileurl.add(imageString);
          loading = !loading;
          _filename.add(filename);
        });

        progressdialog.hide().then((isHidden) {
          // print(isHidden);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
