import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldetor/screens/group/pdfviewer.dart';
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
    getpermission();
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
                new SnackBar(content: new Text("Assignment Already Submited")))
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

  void getpermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  String downlodingMessage = " ";
  bool _isDownloading = false;
  ProgressDialog progressdialog;
  double _progress;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        backgroundColor: Colors.cyan,
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
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(Icons.check_circle,
                                                        color: Colors.green),
                                                    Text("Refreshed"),
                                                  ],
                                                ),
                                                duration:
                                                    Duration(seconds: 1)));
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
                      SizedBox(height: 10.0),
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
                      SizedBox(height: 20.0),
                      Container(
                        height: MediaQuery.of(context).size.height - 150.0,
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
                            Container(
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
                                  Text(" "),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      snapshot.data['subject'] ?? "Loading...",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
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
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableLinkify(
                                      onOpen: (link) async {
                                        if (await canLaunch(link.url)) {
                                          await launch(link.url);
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      },
                                      linkStyle: TextStyle(color: Colors.blue),
                                      text: snapshot.data['description'] ??
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
                            SizedBox(
                              height: 15,
                            ),
                            (snapshot.data['noticetype'] != "Assignment")
                                ? Visibility(
                                    visible: (snapshot.data['noticetype'] ==
                                        "Notice"),
                                    child:
                                        (snapshot.data["filename"].length !=
                                                null)
                                            ? Row(
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: snapshot
                                                          .data["filename"]
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      25,
                                                                  vertical: 1),
                                                          child: Container(
                                                            child: Card(
                                                              color: Colors
                                                                      .blueGrey[
                                                                  300],
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        1),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        snapshot.data["filename"][index] ??
                                                                            "Loading...",
                                                                        style:
                                                                            TextStyle(),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                        splashColor:
                                                                            Colors
                                                                                .grey,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .preview,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          String
                                                                              url =
                                                                              snapshot.data["fileurl"][index];

                                                                          Widget
                                                                              retval;
                                                                          retval = ChangeNotifierProvider(
                                                                              create: (context) => CurrentGroup(),
                                                                              child: Ourpdfviewer());
                                                                          Navigator.of(context)
                                                                              .push(
                                                                            MaterialPageRoute(
                                                                                builder: (context) => retval,
                                                                                settings: RouteSettings(arguments: url)),
                                                                          );
                                                                        }),
                                                                    IconButton(
                                                                        splashColor:
                                                                            Colors
                                                                                .grey,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .download_sharp,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (await canLaunch(snapshot.data["fileurl"]
                                                                              [
                                                                              index])) {
                                                                            await launch(snapshot.data["fileurl"][index]);
                                                                          } else {
                                                                            throw 'Could not launch ';
                                                                          }
                                                                          // setState(
                                                                          //     () {
                                                                          //   _isDownloading =
                                                                          //       !_isDownloading;
                                                                          // });
                                                                          // progressdialog
                                                                          //     .show();
                                                                          // progressdialog
                                                                          //     .update(
                                                                          //   message:
                                                                          //       "Downloading ....",
                                                                          // );

                                                                          // var dir =
                                                                          //     await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);

                                                                          // Dio dio =
                                                                          //     Dio();
                                                                          // dio.download(
                                                                          //   snapshot.data["fileurl"][index],
                                                                          //   "$dir/${snapshot.data["filename"][index]}",
                                                                          //   onReceiveProgress:
                                                                          //       (count, total) {
                                                                          //     var percentage = count / total * 100;

                                                                          //     setState(() {
                                                                          //       downlodingMessage = percentage.floor().toString();
                                                                          //     });

                                                                          //     if (downlodingMessage == "100") {
                                                                          //       progressdialog.hide();
                                                                          //       Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("File Downloaded")));
                                                                          //     }
                                                                          //   },
                                                                          // );
                                                                        })
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(""),
                                  )
                                : SizedBox(
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
                                    child: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 30),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              // scrollDirection: Axis.horizontal,
                                              itemCount: _filename.length,
                                              itemBuilder:
                                                  (BuildContext context,
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
                                                          _filename
                                                              .removeAt(index);
                                                          fileurl
                                                              .removeAt(index);
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
                                      ],
                                    ),
                                  )
                                : Text(""),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
                              child: TextFormField(
                                controller: _reviewController,
                                decoration: InputDecoration(
                                    hintText: "Review/Id/Comment"),
                                maxLength: 30,
                              ),
                            ),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
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

                                    String userName = Provider.of<CurrentUser>(
                                            context,
                                            listen: false)
                                        .getCurrentUser
                                        .fullName;
                                    String useruniqueid =
                                        Provider.of<CurrentUser>(context,
                                                listen: false)
                                            .getCurrentUser
                                            .uniqueId;
                                    // List<String> selectedfile = List();
                                    // selectedfile.add(fileLocation);

                                    Provider.of<CurrentGroup>(context,
                                            listen: false)
                                        .finishedAssignment(
                                            uid,
                                            userName,
                                            useruniqueid,
                                            _reviewController.text,
                                            fileurl,
                                            _filename);

                                    // Navigator.of(context).pop();
                                  }),
                            ),
                            Visibility(
                              visible: (value.getDoneWithCurrentAssignment !=
                                      true &&
                                  snapshot.data['noticetype'] == "Assignment"),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text("Don't Forgot to press SEND button",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    )),
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
      progressdialog.update(message: "Uploding...");
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

//       uploadTask.events.listen((event) {
//         // print(event.snapshot.totalByteCount);
//         print(event.type);
//         setState(() {
//           // _isLoading = true;

//           _progress = event.snapshot.bytesTransferred.toDouble() /
//               event.snapshot.totalByteCount.toDouble();
//         });
//         // }).onError((error) {
//         //   // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(error.toString()), backgroundColor: Colors.red,) );
//       });
// print(_progress);

      await uploadTask.onComplete;
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
