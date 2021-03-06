import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/group/Inside%20notice/assignmentBox.dart';
import 'package:worldetor/screens/group/Inside%20notice/noticepage.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurAssignmentAdminPage extends StatefulWidget {
  @override
  _OurAssignmentAdminPageState createState() => _OurAssignmentAdminPageState();
}

class _OurAssignmentAdminPageState extends State<OurAssignmentAdminPage> {
  @override
  void initState() {
    super.initState();
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _deletedialog(groupId, noticeId, assignmentId) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Remove",
      desc: "Are you sure?",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Remove",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _removename(groupId, noticeId, assignmentId);
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void _removename(groupId, noticeId, assignmentId) async {
    setState(() {
      loadingcircle = true;
    });
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("notice")
        .document(noticeId)
        .collection("assignment")
        .document(assignmentId)
        .delete();
    setState(() {
      loadingcircle = false;
    });
  }

  void _openNotice(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .openNotice(_currentuser.getCurrentUser.groupid, noticeId);

    if (_returnString == "Success") {
      setState(() {
        loadingcircle = false;
      });
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurNoticePage(),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
    } else {
      setState(() {
        loadingcircle = false;
      });
    }
  }

  Widget _previewButton(context, uniqueId) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: 140,
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () async {
            setState(() {
              loadingcircle = true;
            });
            _openNotice(context, uniqueId);
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
                Icon(Icons.preview),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 13,
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
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
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

                    await Firestore.instance
                        .collection("groups")
                        .document(groupid)
                        .collection("notice")
                        .document(noticeid)
                        .updateData({'datecompleted': _selecedtDate});
                    setState(() {
                      loadingcircle = false;
                    });
                    Navigator.of(context).pop();
                    _alertDueDatedialog();
                    // Scaffold.of(context).showSnackBar(
                    //     new SnackBar(content: new Text("Due Date Updated")));
                  },
                  child: Text("Submit")),
            ],
          );
        });
  }

  Widget _extendButton(context, groupid, noticeid) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 160,
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () async {
            _dialogbox(context, groupid, noticeid);
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

  bool loading = false;
  // double _progress;
  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Consumer<CurrentGroup>(
          builder: (BuildContext context, value, Widget child) {
        return Scaffold(
          backgroundColor: Colors.cyan,
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(value.getCurrentGroup.id)
                  .collection("notice")
                  .document(value.getCurrentGroup.currentNoticeid)
                  .collection("assignment")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.data.documents == null) {
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
                                      Row(
                                        children: [
                                          Icon(Icons.people_alt,
                                              color: Colors.white),
                                          Text(
                                            " " +
                                                snapshot.data.documents.length
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Padding(
                          padding: EdgeInsets.only(left: 40.0),
                          child: Row(
                            children: <Widget>[
                              Text("Assignment",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0)),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Text("Submissions",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24.0)),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: MediaQuery.of(context).size.height - 155.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(75.0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _previewButton(
                                      context, value.getCurrentNotice.id),
                                  _extendButton(
                                      context,
                                      value.getCurrentGroup.id,
                                      value.getCurrentNotice.id),
                                ],
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                  height: 1, width: 300, color: Colors.grey),
                              SizedBox(
                                height: 7,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // String name = snapshot.data.documents.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1, horizontal: 10),
                                      child: Slidable(
                                        actionPane: SlidableDrawerActionPane(),
                                        actionExtentRatio: 0.30,
                                        secondaryActions: <Widget>[
                                          IconSlideAction(
                                            caption: 'Delete',
                                            color: Colors.redAccent,
                                            icon: Icons.delete,
                                            onTap: () {
                                              setState(() {
                                                loading = !loading;
                                              });
                                              _deletedialog(
                                                  value.getCurrentGroup.id,
                                                  value.getCurrentNotice.id,
                                                  snapshot.data.documents
                                                      .elementAt(index)
                                                      .documentID);
                                            },
                                          )
                                        ],
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Bounce(
                                            duration:
                                                Duration(milliseconds: 110),
                                            onPressed: () async {
                                              await Firestore.instance
                                                  .collection("groups")
                                                  .document(
                                                      value.getCurrentGroup.id)
                                                  .updateData({
                                                "currentAssignmentSenderid":
                                                    snapshot.data.documents
                                                        .elementAt(index)
                                                        .documentID,
                                              });

                                              Widget retval;
                                              retval = ChangeNotifierProvider(
                                                create: (context) =>
                                                    CurrentGroup(),
                                                child: OurAssignmentBox(),
                                              );
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) => retval,
                                              ));
                                            },
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 9.0,
                                                        spreadRadius: 5.0,
                                                        offset: Offset(
                                                          4.0,
                                                          3.5,
                                                        )),
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      snapshot.data.documents
                                                                  .elementAt(
                                                                      index)[
                                                              "userName"] ??
                                                          "Loading...",
                                                    ),
                                                    Spacer(),
                                                    StreamBuilder(
                                                        stream: Firestore
                                                            .instance
                                                            .collection(
                                                                "groups")
                                                            .document(value
                                                                .getCurrentGroup
                                                                .id)
                                                            .collection(
                                                                "notice")
                                                            .document(value
                                                                .getCurrentNotice
                                                                .id)
                                                            .snapshots(),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    dynamic>
                                                                snapshot2) {
                                                          if (snapshot2.data ==
                                                              null) {
                                                            return Container();
                                                          } else {
                                                            return Visibility(
                                                              visible: (snapshot2
                                                                      .data[
                                                                          "markedId"]
                                                                      .contains(snapshot
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)
                                                                          .documentID) ==
                                                                  false),
                                                              child: FlatButton(
                                                                minWidth: 5,
                                                                onPressed:
                                                                    () async {
                                                                  // _attendbutton(
                                                                  //     value
                                                                  //         .getCurrentNotice
                                                                  //         .point,
                                                                  //     value
                                                                  //         .getCurrentGroup
                                                                  //         .id,
                                                                  //     snapshot
                                                                  //         .data
                                                                  //         .documents
                                                                  //         .elementAt(
                                                                  //             index)
                                                                  //         .documentID,
                                                                  //     value
                                                                  //         .getCurrentNotice
                                                                  //         .id);
                                                                  value.adminMarkedAssignment(
                                                                      value
                                                                          .getCurrentNotice
                                                                          .point,
                                                                      value
                                                                          .getCurrentGroup
                                                                          .id,
                                                                      snapshot
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)
                                                                          .documentID,
                                                                      value
                                                                          .getCurrentNotice
                                                                          .id,
                                                                      value
                                                                          .getCurrentNotice
                                                                          .name);
                                                                  // setState(() {
                                                                  //   loading =
                                                                  //       !loading;
                                                                  // });

                                                                  Scaffold.of(
                                                                          context)
                                                                      .showSnackBar(new SnackBar(
                                                                          content:
                                                                              new Text("Assignment mark Added")));
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .check_box_sharp,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 24,
                                                                    ),
                                                                    Text(
                                                                        "Check",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            color:
                                                                                Colors.blueAccent)),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
      }),
    );
  }
}
