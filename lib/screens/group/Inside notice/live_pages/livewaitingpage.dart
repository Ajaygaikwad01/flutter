import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/call.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/livedrawer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurLiveWaitingPage extends StatefulWidget {
  @override
  _OurLiveWaitingPageState createState() => _OurLiveWaitingPageState();
}

class _OurLiveWaitingPageState extends State<OurLiveWaitingPage> {
  final _channelController = TextEditingController();
  // String _chennelName;

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  void _alertDueDatedialog() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Due Date Changed",
      desc: DateFormat.yMMMMd("en_US").format(_selecedtDate) +
          " at " +
          DateFormat("H:mm").format(_selecedtDate),
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.green,
          //   gradient: LinearGradient(colors: [
          //     Color.fromRGBO(116, 116, 191, 1.0),
          //     Color.fromRGBO(52, 138, 199, 1.0)
          //   ]),
        )
      ],
    ).show();
  }

  DateTime _selecedtDate = DateTime.now();
  // DateTime _selecedSendDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await DatePicker.showDateTimePicker(context, showTitleActions: true);
    if (picked != null && picked != _selecedtDate) {
      setState(() {
        _selecedtDate = picked;
      });
    }
  }

  _dialogbox(BuildContext context, groupid, noticeid) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Change Due Date"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(DateFormat.yMMMMd("en_US").format(_selecedtDate)),
                // Text(DateFormat("H:mm").format(_selecedtDate)),
                Container(
                  height: 35,
                  width: 180,
                  child: RaisedButton(
                      onPressed: () => _selectDate(context),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.red),
                          Text("Selcet Due Date",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
              FlatButton(
                  onPressed: () async {
                    setState(() {
                      loadingcircle = true;
                    });
                    Navigator.of(context).pop();
                    _alertDueDatedialog();
                    await Firestore.instance
                        .collection("groups")
                        .document(groupid)
                        .collection("notice")
                        .document(noticeid)
                        .updateData({'datecompleted': _selecedtDate});

                    setState(() {
                      loadingcircle = false;
                    });

                    //

                    // Scaffold.of(context).showSnackBar(
                    //     new SnackBar(content: new Text("Due Date Updated")));
                  },
                  child: Text("Submit")),
            ],
          );
        });
  }

  Widget _extendDueDateButton(context, groupid, noticeid) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 160,
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () async {
            _dialogbox(context, groupid, noticeid);

            //  await progressdialog.show();
            // _loginUser(type: LoginType.google, context: context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          highlightElevation: 0,
          borderSide: BorderSide(color: Colors.grey),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.calendar_today),
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text(
                    'Change DueDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _extendStartDateButton(context, groupid, noticeid) {
  //   return Padding(
  //     padding: const EdgeInsets.all(2.0),
  //     child: Container(
  //       width: 160,
  //       child: OutlineButton(
  //         splashColor: Colors.grey,
  //         onPressed: () async {
  //           _dialogbox(context, groupid, noticeid);
  //           //  await progressdialog.show();
  //           // _loginUser(type: LoginType.google, context: context);
  //         },
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
  //         highlightElevation: 0,
  //         borderSide: BorderSide(color: Colors.grey),
  //         child: Padding(
  //           padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               Icon(Icons.calendar_today),
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 1),
  //                 child: Expanded(
  //                   child: Text(
  //                     'Change StartDate',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Scaffold(
          // backgroundColor: Color(0xFF21BFBD),
          body: Consumer<CurrentGroup>(
              builder: (BuildContext context, value, Widget child) {
        CurrentUser _currentuser =
            Provider.of<CurrentUser>(context, listen: false);
        return Container(
          color: Colors.cyan,
          child: ListView(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.cached),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {});
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green),
                                        Text("Refreshed"),
                                      ],
                                    ),
                                    duration: Duration(seconds: 1)));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.people),
                              color: Colors.white,
                              onPressed: () {
                                Widget retval;
                                retval = ChangeNotifierProvider(
                                  create: (context) => CurrentGroup(),
                                  child: OurLiveDrawer(),
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => retval),
                                );
                              },
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
                    Text("Waiting",
                        style: TextStyle(
                            // fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0)),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text("Room",
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Visibility(
                      visible: (_currentuser.getCurrentUser.uid ==
                          value.getCurrentGroup.leader),
                      child: _extendDueDateButton(context,
                          value.getCurrentGroup.id, value.getCurrentNotice.id),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(height: 1, width: 300, color: Colors.grey),
                    SizedBox(
                      height: 7,
                    ),
                    Expanded(
                      child: ListView(
                        // primary: false,
                        padding:
                            EdgeInsets.only(left: 25.0, right: 20.0, top: 15),
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(value.getCurrentNotice.name ?? "Loading...",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text(value.getCurrentNotice.subject ??
                                  "Loading..."),
                              SizedBox(height: 10),

                              Row(
                                children: [
                                  SizedBox(width: 20),
                                  Text("Created by: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                  Text(value.getCurrentGroup.leaderName ??
                                      "Loading..."),
                                ],
                              ),

                              // Text(value.getCurrentGroup. ?? "Loading..."),
                            ],
                          ),
                          RaisedButton(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 60),
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.live_tv,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      " Join Stream",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onPressed: () async {
                              onJoin();
                              setState(() {
                                loadingcircle = true;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Visibility(
                            visible: (_currentuser.getCurrentUser.uid ==
                                value.getCurrentGroup.leader),
                            child: RaisedButton(
                              color: Colors.red,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 60),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.tv_off_outlined,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " End Stream",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await Firestore.instance
                                    .collection("groups")
                                    .document(value.getCurrentGroup.id)
                                    .collection("notice")
                                    .document(value.getCurrentNotice.id)
                                    .updateData(
                                        {'datecompleted': Timestamp.now()});
                                _alertDueDatedialog();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      })),
    );
  }

  void _memberjoined() async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    try {
      await Firestore.instance
          .collection("groups")
          .document(_currentgroup.getCurrentGroup.id)
          .collection("notice")
          .document(_currentgroup.getCurrentNotice.id)
          .collection("joinmembers")
          .document(_currentuser.getCurrentUser.uid)
          .setData({'username': _currentuser.getCurrentUser.fullName});
    } catch (e) {
      print(e);
    }
  }

  Future<void> onJoin() async {
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);

    // update input validation
    setState(() {
      (_currentgroup.getCurrentNotice.name == null)
          ? _validateError = true
          : _validateError = false;
    });
    if (_currentgroup.getCurrentNotice.name != null) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();

      if (_currentuser.getCurrentUser.uid ==
          _currentgroup.getCurrentGroup.leader) {
        await Firestore.instance
            .collection("groups")
            .document(_currentgroup.getCurrentGroup.id)
            .collection("notice")
            .document(_currentgroup.getCurrentNotice.id)
            .updateData({'datelivestart': Timestamp.now()});
        setState(() {
          _role = ClientRole.Broadcaster;
        });
      } else {
        setState(() {
          _role = ClientRole.Audience;
        });
      }
      // push video page with given channel name
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: CallPage(
          channelName: _currentgroup.getCurrentNotice.name,
          role: _role,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
      setState(() {
        loadingcircle = false;
      });
      _memberjoined();
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CallPage(
      //       channelName: _currentgroup.getCurrentNotice.name,
      //       role: _role,
      //     ),
      //   ),
      // );
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
