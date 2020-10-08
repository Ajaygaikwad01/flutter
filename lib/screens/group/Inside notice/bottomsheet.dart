import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurBottomsheet extends StatefulWidget {
  OurBottomsheet({Key key}) : super(key: key);
  @override
  _OurBottomsheetState createState() => _OurBottomsheetState();
}

class _OurBottomsheetState extends State<OurBottomsheet> {
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
    return showbottomsheet(context);
  }

  showbottomsheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              key: UniqueKey(),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0)),
              height: MediaQuery.of(context).size.height * .60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (_filename.length != null)
                        ? Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                // scrollDirection: Axis.horizontal,
                                itemCount: _filename.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // final ref = FirebaseStorage()
                                  //     .ref()
                                  //     .child(_filelocation[index]);
                                  // Future<String> val = ref.getName();
                                  return StreamBuilder(
                                      stream: FirebaseStorage.instance
                                          .ref()
                                          .child(_filelocation[index])
                                          .getName()
                                          .asStream(),
                                      builder: (context, snapshot) {
                                        return Card(
                                          child: Center(
                                              child: Text(snapshot.data)),
                                        );
                                      });
                                }))
                        : Text(""),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      Icons.storage,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = !loading;
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

                                      Navigator.of(context).pop();
                                    }),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      Text("Don't Forgot to press SEND button",
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
                  ],
                ),
              ),
            ),
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