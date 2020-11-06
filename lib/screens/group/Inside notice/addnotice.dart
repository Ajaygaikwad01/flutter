import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/models/noticedoc.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurAddNotice extends StatefulWidget {
  @override
  _OurAddNoticeState createState() => _OurAddNoticeState();
}

class _OurAddNoticeState extends State<OurAddNotice> {
  @override
  void initState() {
    super.initState();
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _addnotice(BuildContext context, OurNoticeDoc notice) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    String _returnString = await OurDatabase().addnoticeDoc(
        _currentuser.getCurrentUser.groupid,
        notice,
        _currentgroup.getCurrentGroup.name);

    if (_returnString == "Success") {
      setState(() {
        loadingcircle = false;
      });
      Navigator.pop(context);
    } else {
      setState(() {
        loadingcircle = false;
      });
    }
  }

  Widget _assignmentButton(context) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        getImage();
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
            Icon(Icons.assignment),
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

  TextEditingController _noticeTitleController = TextEditingController();

  TextEditingController _noticeDescriptionController = TextEditingController();
  TextEditingController _noticeSubjectController = TextEditingController();
  bool loadingcircle = false;

  List<String> _fileurl = List();
  List<String> _filelocation = List();
  List<String> _filename = List();
  bool loading = false;
  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Fill Notice Information",
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Ourcontener(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _noticeTitleController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title), hintText: "Title"),
                      maxLength: 20,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: _noticeSubjectController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.subject), hintText: "Subject"),
                      maxLength: 60,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                        controller: _noticeDescriptionController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.description),
                            hintText: "Description"),
                        minLines: 1,
                        maxLines: 5,
                        maxLengthEnforced: true),
                    SizedBox(
                      height: 10.0,
                    ),
                    _assignmentButton(context),
                    SizedBox(
                      height: 5.0,
                    ),
                    Flexible(
                      child: (_filename.length != null)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: ListView.builder(
                                shrinkWrap: true,
                                // scrollDirection: Axis.horizontal,
                                itemCount: _filename.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Card(
                                  color: Colors.white30,
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child:
                                              Text("    " + _filename[index])),
                                      IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              loading = !loading;
                                            });
                                            _filename.removeAt(index);
                                            _fileurl.removeAt(index);
                                          })
                                    ],
                                  )),
                                ),
                              ),
                            )
                          : Text(""),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 80),
                          child: Text(
                            "Send",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            loadingcircle = true;
                          });
                          OurNoticeDoc notice = OurNoticeDoc();
                          notice.noticetype = "Notice";
                          notice.name = _noticeTitleController.text;
                          notice.subject = _noticeSubjectController.text;
                          notice.description =
                              _noticeDescriptionController.text;
                          notice.fileurl = _fileurl;
                          notice.filenames = _filename;
                          _addnotice(context, notice);
                        })
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
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
      String imageLocation =
          '${_currentgroup.getCurrentGroup.name}/${_currentuser.getCurrentUser.uid}/$filename';
      setState(() {
        _filelocation.add(imageLocation);
      });

      // print(imageLocation);
      final StorageReference storageReference =
          FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);

      uploadTask.events.listen((event) {
        // print(event.snapshot.totalByteCount);
        print(event.type);
        // setState(() {
        //     // _isLoading = true;
        //     print(_progress);
        //     _progress = event.snapshot.bytesTransferred.toDouble() /
        //         event.snapshot.totalByteCount.toDouble();
        // });
        // }).onError((error) {
        //   // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(error.toString()), backgroundColor: Colors.red,) );
      });
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
          _fileurl.add(imageString);
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
