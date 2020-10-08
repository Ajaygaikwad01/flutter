import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/group/Inside%20notice/AssignmentSubmitionView.dart';
import 'package:worldetor/screens/group/Inside%20notice/attendanceView.dart';
import 'package:worldetor/screens/group/Inside%20notice/floatingbutton.dart';
import 'package:worldetor/screens/group/Inside%20notice/noticeview.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurNoticePage extends StatefulWidget {
  @override
  _OurNoticePageState createState() => _OurNoticePageState();
}

class _OurNoticePageState extends State<OurNoticePage> {
  Timer _timer;
  var time = DateTime.now();
  void _attendance(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);

    String _returnString = await OurDatabase().getattandance(
        _currentuser.getCurrentUser.groupid,
        noticeId,
        _currentuser.getCurrentUser.fullName,
        _currentuser.getCurrentUser.uid);
    if (_returnString == "Success") {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: new Text("Attenance Submited")));
    }
  }

  void _removeNotice(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .removeNotice(_currentuser.getCurrentUser.groupid, noticeId);
    if (_returnString == "Success") {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Notification Dismissed")));
    }
  }

  void _openAttendanceAdminView(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .openNotice(_currentuser.getCurrentUser.groupid, noticeId);

    if (_returnString == "Success") {
      progressdialog.hide();
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurAttendanceView(),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
    }
  }

  void _openAssignmentAdminView(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .openNotice(_currentuser.getCurrentUser.groupid, noticeId);

    if (_returnString == "Success") {
      progressdialog.hide();
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurAssignmentSubmitionView(),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
    }
  }

  void _openNotice(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .openNotice(_currentuser.getCurrentUser.groupid, noticeId);

    if (_returnString == "Success") {
      progressdialog.hide();
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurNoticeView(),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
    // _startTimer();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    progressdialog.update(
      message: "Opening....",
    );
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(value.getCurrentGroup.name ?? " loding...."),
        ),
        drawer: OurDrawer(),
        body: Container(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection("groups")
                .document(value.getCurrentGroup.id)
                .collection("notice")
                .orderBy("datesend", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text("empty"),
                );
              } else {
                return ListView.builder(
                    // reverse: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (snapshot.data.documents
                                  .elementAt(index)['noticetype'] ==
                              "Assignment" ||
                          snapshot.data.documents
                                  .elementAt(index)['noticetype'] ==
                              "notice") {
                        // var now = DateTime.now();
                        var date = snapshot.data.documents
                            .elementAt(index)["datecompleted"]
                            .toDate();
                        var diff = date.difference(time).inMinutes;
                        return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.redAccent,
                                icon: Icons.delete,
                                onTap: () {
                                  _removeNotice(
                                      context,
                                      snapshot.data.documents
                                          .elementAt(index)
                                          .documentID
                                          .toString());
                                },
                              )
                            ],
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Ourcontener(
                                    child: Column(
                                      children: [
                                        Container(
                                          child: ListTile(
                                              title: Column(
                                                children: [
                                                  (diff <= 0)
                                                      ? Container(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .amber[900],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons
                                                                  .access_alarms),
                                                              Text(
                                                                " " +
                                                                        snapshot
                                                                            .data
                                                                            .documents
                                                                            .elementAt(index)['noticetype'] +
                                                                        "  Expired" +
                                                                        "  !!!" ??
                                                                    "loading.....",
                                                                style:
                                                                    TextStyle(
                                                                  // color: Colors.white,
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.amber,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          // color: Colors.amber,

                                                          child: Text(
                                                            "  " +
                                                                    snapshot
                                                                        .data
                                                                        .documents
                                                                        .elementAt(
                                                                            index)['noticetype'] +
                                                                    ":" ??
                                                                "loading...",
                                                            style: TextStyle(
                                                              // color: Colors.white,
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    snapshot.data.documents
                                                                .elementAt(
                                                                    index)[
                                                            'name'] ??
                                                        "loading.....",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Subject: ",
                                                        style: TextStyle(
                                                          color: Colors.amber,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)[
                                                                  'subject'] ??
                                                              "loading.....",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13.0,
                                                            // fontWeight:
                                                            //     FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: (snapshot
                                                                .data.documents
                                                                .elementAt(
                                                                    index)[
                                                            'noticetype'] ==
                                                        "Assignment"),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Points: ",
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data
                                                                  .documents
                                                                  .elementAt(index)[
                                                                      'point']
                                                                  .toString() ??
                                                              "loading.....",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13.0,
                                                            // fontWeight:
                                                            // FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Due On: ",
                                                        style: TextStyle(
                                                          color: Colors.amber,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        (snapshot.data.documents
                                                                        .elementAt(
                                                                            index)[
                                                                    "datecompleted"] !=
                                                                null)
                                                            ? DateFormat.yMMMEd("en_US").format(snapshot
                                                                    .data
                                                                    .documents
                                                                    .elementAt(index)[
                                                                        "datecompleted"]
                                                                    .toDate()) +
                                                                " at- " +
                                                                DateFormat("H:mm")
                                                                    .format(snapshot
                                                                        .data
                                                                        .documents
                                                                        .elementAt(
                                                                            index)["datecompleted"]
                                                                        .toDate())
                                                            : "loading.....",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                          // fontWeight:
                                                          //      FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: (snapshot
                                                                .data.documents
                                                                .elementAt(
                                                                    index)[
                                                            'noticetype'] !=
                                                        "attendance"),
                                                    child: RaisedButton(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            (diff == 0 ||
                                                                    diff < 0)
                                                                ? " !!! EXPIRED !!!"
                                                                : "Tap for More Info...",
                                                            style: TextStyle(
                                                              // fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          (diff <= 0)
                                                              ? Scaffold.of(
                                                                      context)
                                                                  .showSnackBar(
                                                                      new SnackBar(
                                                                          content: new Text(
                                                                              "Notification is Expired")))
                                                              : _openNotice(
                                                                  context,
                                                                  snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)
                                                                      .documentID
                                                                      .toString());
                                                        }),
                                                  )
                                                ],
                                              ),
                                              onTap: () {
                                                CurrentUser _currentuser =
                                                    Provider.of<CurrentUser>(
                                                        context,
                                                        listen: false);
                                                if (value.getCurrentGroup
                                                        .leader ==
                                                    _currentuser
                                                        .getCurrentUser.uid) {
                                                  progressdialog.show();
                                                  if (snapshot.data.documents
                                                              .elementAt(index)[
                                                          'noticetype'] ==
                                                      "Assignment") {
                                                    _openAssignmentAdminView(
                                                        context,
                                                        snapshot.data.documents
                                                            .elementAt(index)
                                                            .documentID
                                                            .toString());
                                                  } else {
                                                    progressdialog.hide();
                                                    _openNotice(
                                                        context,
                                                        snapshot.data.documents
                                                            .elementAt(index)
                                                            .documentID
                                                            .toString());
                                                  }
                                                } else {
                                                  if (diff <= 0) {
                                                    Scaffold.of(context)
                                                        .showSnackBar(new SnackBar(
                                                            content: new Text(
                                                                "Notification is Expired only Admin can Access")));
                                                  } else {
                                                    progressdialog.show();
                                                    _openNotice(
                                                        context,
                                                        snapshot.data.documents
                                                            .elementAt(index)
                                                            .documentID
                                                            .toString());
                                                  }
                                                }
                                              }),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            // alignment: Alignment.center,
                                            color: Colors.black12,
                                            child: Row(
                                              children: [
                                                Text(
                                                  (snapshot.data.documents
                                                                  .elementAt(
                                                                      index)[
                                                              "datesend"] !=
                                                          null)
                                                      ? DateFormat.yMMMMEEEEd(
                                                              "en_US")
                                                          .format(snapshot
                                                              .data.documents
                                                              .elementAt(index)[
                                                                  "datesend"]
                                                              .toDate())
                                                      : "loading...",
                                                  style: TextStyle(
                                                    // color: Colors.black12,
                                                    fontSize: 13.0,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  (DateFormat("H:mm").format(snapshot
                                                              .data.documents
                                                              .elementAt(index)[
                                                                  "datesend"]
                                                              .toDate()) !=
                                                          null)
                                                      ? DateFormat("H:mm")
                                                          .format(snapshot
                                                              .data.documents
                                                              .elementAt(index)[
                                                                  "datesend"]
                                                              .toDate())
                                                      : "loading...",
                                                  style: TextStyle(
                                                    // color: Colors.black26,
                                                    fontSize: 13.0,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ));
                      } else if (snapshot.data.documents
                              .elementAt(index)['noticetype'] ==
                          "attendance") {
                        var date = snapshot.data.documents
                            .elementAt(index)["datecompleted"]
                            .toDate();
                        var diff = date.difference(time).inMinutes;
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.redAccent,
                              icon: Icons.delete,
                              onTap: () {
                                _removeNotice(
                                    context,
                                    snapshot.data.documents
                                        .elementAt(index)
                                        .documentID
                                        .toString());
                              },
                            )
                          ],
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Ourcontener(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: ListTile(
                                            title: Column(
                                              children: [
                                                (diff <= 0)
                                                    ? Container(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.amber[900],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        // color: Colors.amber,

                                                        child: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .access_alarms),
                                                            Text(
                                                              " " +
                                                                      snapshot
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)['noticetype'] +
                                                                      "  Expired" +
                                                                      "  !!!" ??
                                                                  "loading.....",
                                                              style: TextStyle(
                                                                // color: Colors.white,
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(
                                                        color: Colors.amber,
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: Text(
                                                          " " +
                                                                  snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)['noticetype'] +
                                                                  ":" ??
                                                              "loading.....",
                                                          style: TextStyle(
                                                            // color: Colors.white,
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                Text(
                                                  snapshot.data.documents
                                                          .elementAt(
                                                              index)['name'] ??
                                                      "loading.....",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Subject: ",
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        snapshot.data.documents
                                                                    .elementAt(
                                                                        index)[
                                                                'subject'] ??
                                                            "loading.....",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                          // fontWeight:
                                                          //     FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Due On: ",
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      (snapshot.data.documents
                                                                      .elementAt(index)[
                                                                  "datecompleted"] !=
                                                              null)
                                                          ? DateFormat.yMMMEd("en_US")
                                                                  .format(snapshot
                                                                      .data
                                                                      .documents
                                                                      .elementAt(index)[
                                                                          "datecompleted"]
                                                                      .toDate()) +
                                                              " at- " +
                                                              DateFormat("H:mm")
                                                                  .format(snapshot
                                                                      .data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)["datecompleted"]
                                                                      .toDate())
                                                          : "loading.....",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                (diff > 0)
                                                    ? Row(
                                                        children: [
                                                          Spacer(),
                                                          IconButton(
                                                              splashColor:
                                                                  Colors.grey,
                                                              icon: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .blue[300],
                                                                size: 35,
                                                              ),
                                                              onPressed: () {
                                                                CurrentUser
                                                                    _currentuser =
                                                                    Provider.of<
                                                                            CurrentUser>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                if (_currentuser
                                                                        .getCurrentUser
                                                                        .uniqueId ==
                                                                    null) {
                                                                  Scaffold.of(
                                                                          context)
                                                                      .showSnackBar(new SnackBar(
                                                                          content:
                                                                              new Text("Failed Please Add uniqueId in profile")));
                                                                } else {
                                                                  _attendance(
                                                                      context,
                                                                      snapshot
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)
                                                                          .documentID
                                                                          .toString());
                                                                }
                                                              }),
                                                          SizedBox(
                                                            width: 30,
                                                          ),
                                                          IconButton(
                                                              splashColor:
                                                                  Colors.grey,
                                                              icon: Icon(
                                                                Icons.clear,
                                                                color: Colors
                                                                    .red[300],
                                                                size: 35,
                                                              ),
                                                              onPressed: null),
                                                          Spacer(),
                                                        ],
                                                      )
                                                    : Text(""),
                                                Row(
                                                  children: [
                                                    Spacer(),
                                                    Text(
                                                      "present",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blue[300]),
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Text("Absent",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .red[300])),
                                                    Spacer(),
                                                  ],
                                                )
                                              ],
                                            ),
                                            onTap: () async {
                                              // progressdialog.show();
                                              CurrentUser _currentuser =
                                                  Provider.of<CurrentUser>(
                                                      context,
                                                      listen: false);

                                              if (value
                                                      .getCurrentGroup.leader ==
                                                  _currentuser
                                                      .getCurrentUser.uid) {
                                                progressdialog.show();
                                                _openAttendanceAdminView(
                                                    context,
                                                    snapshot.data.documents
                                                        .elementAt(index)
                                                        .documentID
                                                        .toString());
                                              }
                                            }),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          color: Colors.black12,
                                          child: Row(
                                            children: [
                                              Text(
                                                (snapshot.data.documents
                                                                .elementAt(
                                                                    index)[
                                                            "datesend"] !=
                                                        null)
                                                    ? " " +
                                                        DateFormat.yMMMMEEEEd(
                                                                "en_US")
                                                            .format(snapshot
                                                                .data.documents
                                                                .elementAt(index)[
                                                                    "datesend"]
                                                                .toDate())
                                                    : "loading...",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                (DateFormat("H:mm").format(
                                                            snapshot
                                                                .data.documents
                                                                .elementAt(index)[
                                                                    "datesend"]
                                                                .toDate()) !=
                                                        null)
                                                    ? DateFormat("H:mm").format(
                                                            snapshot
                                                                .data.documents
                                                                .elementAt(index)[
                                                                    "datesend"]
                                                                .toDate()) +
                                                        " "
                                                    : "loading...",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    });
              }
            },
          ),
        ),
        floatingActionButton: Consumer<CurrentUser>(
            builder: (BuildContext context, value2, Widget child) {
          if (value.getCurrentGroup.leader == value2.getCurrentUser.uid) {
            return OurFloatButton();
          } else {
            return Text("");
          }
        }),
      );
    });
  }
}
