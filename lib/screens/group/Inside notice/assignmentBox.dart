import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldetor/screens/group/pdfviewer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';
import 'package:permission_handler/permission_handler.dart';

class OurAssignmentBox extends StatefulWidget {
  @override
  _OurAssignmentBoxState createState() => _OurAssignmentBoxState();
}

class _OurAssignmentBoxState extends State<OurAssignmentBox> {
  void initState() {
    super.initState();
    getpermission();
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void getpermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  String downlodingMessage = " ";
  bool _isDownloading = false;
  ProgressDialog progressdialog;
  double _percentage = 0;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    // progressdialog.update(maxProgress: percentage,message: downlodingMessage);
    // progressdialog.update(message: "Downloading...");

    return Consumer<CurrentGroup>(
      builder: (BuildContext context, value, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Document List"),
          ),
          body: Container(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(value.getCurrentGroup.id)
                  .collection("notice")
                  .document(value.getCurrentGroup.currentNoticeid)
                  .collection("assignment")
                  .document(value.getCurrentGroup.currentAssignmentsenderid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    child: Center(
                      child: Text("empty"),
                    ),
                  );
                } else {
                  if (snapshot.data.data == null) {
                    return Container(
                      child: Center(
                        child: Text("empty"),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data["fileUrl"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        //snapshot.data["fileUrl"][index]
                                        snapshot.data["fileName"][index] ??
                                            "Loading..."),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      splashColor: Colors.grey,
                                      icon: Icon(Icons.preview),
                                      onPressed: () async {
                                        String url =
                                            snapshot.data["fileUrl"][index];

                                        Widget retval;
                                        retval = ChangeNotifierProvider(
                                            create: (context) => CurrentGroup(),
                                            child: Ourpdfviewer());
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => retval,
                                              settings: RouteSettings(
                                                  arguments: url)),
                                        );
                                      }),
                                  IconButton(
                                      splashColor: Colors.grey,
                                      icon: Icon(Icons.download_sharp),
                                      onPressed: () async {
                                        setState(() {
                                          _isDownloading = !_isDownloading;
                                        });
                                        progressdialog.show();
                                        progressdialog.update(
                                            message: "Downloading ....",
                                            progress: _percentage);

                                        var dir = await ExtStorage
                                            .getExternalStoragePublicDirectory(
                                                ExtStorage.DIRECTORY_DOWNLOADS);

                                        Dio dio = Dio();
                                        dio.download(
                                          snapshot.data["fileUrl"][index],
                                          "${dir}/${snapshot.data["fileName"][index]}",
                                          onReceiveProgress: (count, total) {
                                            var percentage =
                                                count / total * 100;
                                            _percentage = percentage;
                                            setState(() {
                                              print(percentage);
                                              downlodingMessage =
                                                  percentage.floor().toString();
                                            });
                                            if (downlodingMessage == "100") {
                                              progressdialog.hide();
                                            }
                                          },
                                        );
                                      })
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
