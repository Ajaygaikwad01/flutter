import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/group/Inside%20notice/assignmentAdnimPage.dart';
import 'package:worldetor/screens/group/Inside%20notice/attendanceAdminView.dart';
import 'package:worldetor/screens/group/Inside%20notice/floatingbutton.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/livewaitingpage.dart';
import 'package:worldetor/screens/group/Inside%20notice/noticepage.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurAlertPage extends StatefulWidget {
  @override
  _OurAlertPageState createState() => _OurAlertPageState();
}

class _OurAlertPageState extends State<OurAlertPage> {
  void _attendancedialog() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Success",
      desc: "Your Attendance is Submited",
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void _attendance(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);

    String _returnString = await OurDatabase().getattandance(
        _currentuser.getCurrentUser.groupid,
        noticeId,
        _currentuser.getCurrentUser.fullName,
        _currentuser.getCurrentUser.uid,
        _currentuser.getCurrentUser.uniqueId);
    if (_returnString == "Success") {
      _attendancedialog();
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Attenance Submited"),
          duration: Duration(seconds: 1)));
    }
  }

  void _removeNoticedialog(context, noticeId) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Delete",
      desc: "Are you Sure?",
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
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _removeNotice(context, noticeId);
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

  void _removeNotice(
    BuildContext context,
    String noticeId,
  ) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .removeNotice(_currentuser.getCurrentUser.groupid, noticeId);
    if (_returnString == "Success") {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Notification Dismissed"),
          duration: Duration(seconds: 1)));
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
      setState(() {
        loadingcircle = false;
      });
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurAttendanceAdminPage(),
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
      setState(() {
        loadingcircle = false;
      });
      Widget retval;
      retval = ChangeNotifierProvider(
        create: (context) => CurrentGroup(),
        child: OurAssignmentAdminPage(),
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
    }
  }

  void _openLive(
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
        child: OurLiveWaitingPage(),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => retval),
      );
    }
  }

  Timer _timer;
  var time = DateTime.now();

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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(value.getCurrentGroup.name ?? " loading....",
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          actions: <Widget>[
            IconButton(
              tooltip: "Refresh",
              icon: Icon(Icons.cached_outlined),
              onPressed: () async {
                setState(() {});
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        Text("Refreshed"),
                      ],
                    ),
                    duration: Duration(seconds: 1)));
              },
            ),
            IconButton(
              tooltip: "Report",
              icon: Icon(Icons.report),
              onPressed: () async {
                setState(() {});
                print("Reporting");
              },
            ),
          ],
        ),
        drawer: OurDrawer(),
        body: ModalProgressHUD(
          inAsyncCall: loadingcircle,
          child: Container(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(value.getCurrentGroup.id)
                  .collection("notice")
                  .orderBy("datesend", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: Text("empty"),
                  );
                } else {
                  return SmartRefresher(
                    enablePullDown: true,
                    // enablePullUp: true,
                    header: WaterDropHeader(),

                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder(
                        // reverse: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          // var now = DateTime.now();
                          var startLivedate;
                          if (snapshot.data.documents
                                  .elementAt(index)['noticetype'] ==
                              "Live") {
                            startLivedate = snapshot.data.documents
                                .elementAt(index)["datelivestart"]
                                .toDate();
                          }
                          var startLivediff;
                          if (snapshot.data.documents
                                  .elementAt(index)['noticetype'] ==
                              "Live") {
                            startLivediff =
                                startLivedate.difference(time).inMinutes;
                          } else {
                            startLivediff = 1;
                          }

                          var date;
                          if (snapshot.data.documents
                                  .elementAt(index)['noticetype'] !=
                              "Notice") {
                            date = snapshot.data.documents
                                .elementAt(index)["datecompleted"]
                                .toDate();
                          }
                          var diff;
                          if (snapshot.data.documents
                                  .elementAt(index)['noticetype'] !=
                              "Notice") {
                            diff = date.difference(time).inMinutes;
                          } else {
                            diff = 1;
                          }
                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            secondaryActions: <Widget>[
                              Visibility(
                                visible: (value.getCurrentGroup.leader ==
                                    _currentuser.getCurrentUser.uid),
                                child: IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.redAccent,
                                  icon: Icons.delete,
                                  onTap: () {
                                    if (value.getCurrentGroup.leader ==
                                        _currentuser.getCurrentUser.uid) {
                                      _removeNoticedialog(
                                          context,
                                          snapshot.data.documents
                                              .elementAt(index)
                                              .documentID
                                              .toString());
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          new SnackBar(
                                              content: new Text(
                                                  "You are not Authorized!")));
                                    }
                                  },
                                ),
                              )
                            ],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      alignment: Alignment.topCenter,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                              (snapshot.data.documents
                                                              .elementAt(index)[
                                                          "datesend"] !=
                                                      null)
                                                  ? DateFormat.E("en_US")
                                                      .format(snapshot
                                                          .data.documents
                                                          .elementAt(
                                                              index)["datesend"]
                                                          .toDate())
                                                  : "loading...",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text(
                                              (snapshot.data.documents
                                                              .elementAt(index)[
                                                          "datesend"] !=
                                                      null)
                                                  ? "    " +
                                                      DateFormat.d("en_US")
                                                          .format(snapshot
                                                              .data.documents
                                                              .elementAt(index)[
                                                                  "datesend"]
                                                              .toDate()) +
                                                      "    "
                                                  : "loading...",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text(
                                              (snapshot.data.documents
                                                              .elementAt(index)[
                                                          "datesend"] !=
                                                      null)
                                                  ? DateFormat.MMM("en_US")
                                                      .format(snapshot
                                                          .data.documents
                                                          .elementAt(
                                                              index)["datesend"]
                                                          .toDate())
                                                  : "loading...",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ],
                                      )),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Expanded(
                                    child: Bounce(
                                      duration: Duration(milliseconds: 100),
                                      onPressed: () async {
                                        if (snapshot.data.documents.elementAt(
                                                index)['noticetype'] ==
                                            "Assignment") {
                                          if (value.getCurrentGroup.leader ==
                                              _currentuser.getCurrentUser.uid) {
                                            // progressdialog.show();
                                            setState(() {
                                              loadingcircle = true;
                                            });
                                            _openAssignmentAdminView(
                                                context,
                                                snapshot.data.documents
                                                    .elementAt(index)
                                                    .documentID
                                                    .toString());
                                          } else {
                                            if (diff > 0) {
                                              setState(() {
                                                loadingcircle = true;
                                              });
                                              _openNotice(
                                                  context,
                                                  snapshot.data.documents
                                                      .elementAt(index)
                                                      .documentID
                                                      .toString());
                                            } else {
                                              Scaffold.of(context).showSnackBar(
                                                  new SnackBar(
                                                      content: new Text(
                                                          "Notification Expired")));
                                            }
                                          }
                                        } else if (snapshot.data.documents
                                                .elementAt(
                                                    index)['noticetype'] ==
                                            "Notice") {
                                          setState(() {
                                            loadingcircle = true;
                                          });
                                          _openNotice(
                                              context,
                                              snapshot.data.documents
                                                  .elementAt(index)
                                                  .documentID
                                                  .toString());
                                        } else if (snapshot.data.documents
                                                .elementAt(
                                                    index)['noticetype'] ==
                                            "Live") {
                                          if (value.getCurrentGroup.leader ==
                                              _currentuser.getCurrentUser.uid) {
                                            setState(() {
                                              loadingcircle = true;
                                            });
                                            _openLive(
                                                context,
                                                snapshot.data.documents
                                                    .elementAt(index)
                                                    .documentID
                                                    .toString());
                                          } else if (diff > 0) {
                                            setState(() {
                                              loadingcircle = true;
                                            });
                                            _openLive(
                                                context,
                                                snapshot.data.documents
                                                    .elementAt(index)
                                                    .documentID
                                                    .toString());
                                          } else {
                                            Scaffold.of(context).showSnackBar(
                                                new SnackBar(
                                                    content: new Text(
                                                        "Notification Expired")));
                                          }
                                        } else if (snapshot.data.documents
                                                .elementAt(
                                                    index)['noticetype'] ==
                                            "Attendance") {
                                          if (value.getCurrentGroup.leader ==
                                              _currentuser.getCurrentUser.uid) {
                                            setState(() {
                                              loadingcircle = true;
                                            });
                                            _openAttendanceAdminView(
                                                context,
                                                snapshot.data.documents
                                                    .elementAt(index)
                                                    .documentID
                                                    .toString());
                                          }
                                        }
                                      },
                                      child: Opacity(
                                        opacity: (diff <= 0) ? 0.4 : 1,
                                        child: Ourcontener(
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    (snapshot.data.documents
                                                                    .elementAt(
                                                                        index)[
                                                                'noticetype'] ==
                                                            "Assignment")
                                                        ? Icon(
                                                            Icons.assignment,
                                                            color:
                                                                Colors.orange,
                                                          )
                                                        : (snapshot.data
                                                                        .documents
                                                                        .elementAt(index)[
                                                                    'noticetype'] ==
                                                                "Notice")
                                                            ? Icon(Icons.bookmarks,
                                                                color:
                                                                    Colors.lime)
                                                            : (snapshot.data.documents.elementAt(index)[
                                                                        'noticetype'] ==
                                                                    "Live")
                                                                ? Icon(Icons.video_call,
                                                                    color: Colors
                                                                        .blue)
                                                                : Icon(Icons.check_circle,
                                                                    color: Colors
                                                                        .green),
                                                    Text(
                                                        " " +
                                                            snapshot.data.documents
                                                                    .elementAt(
                                                                        index)[
                                                                'noticetype'] +
                                                            ":",
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    Spacer(),
                                                    Visibility(
                                                      visible: (snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)[
                                                                  'noticetype'] ==
                                                              "Live" &&
                                                          diff >= 0 &&
                                                          startLivediff < 0),
                                                      child: AvatarGlow(
                                                        glowColor: Colors.blue,
                                                        endRadius: 15.0,
                                                        duration: Duration(
                                                            milliseconds: 2000),
                                                        repeat: true,
                                                        showTwoGlows: true,
                                                        repeatPauseDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    100),
                                                        child: Material(
                                                          elevation: 8.0,
                                                          shape: CircleBorder(),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[100],
                                                            child: Icon(
                                                              Icons
                                                                  .radio_button_on_outlined,
                                                              color: Colors.red,
                                                              size: 10,
                                                            ),
                                                            radius: 9.0,
                                                          ),
                                                        ),
                                                      ),
                                                      // child: Container(
                                                      //   decoration:
                                                      //       BoxDecoration(
                                                      //     color: Colors.green,
                                                      //     borderRadius:
                                                      //         BorderRadius
                                                      //             .circular(
                                                      //                 20.0),
                                                      //   ),
                                                      //   // color: Colors.redAccent,
                                                      //   child: Row(
                                                      //     children: [
                                                      //       (startLivediff < 0)
                                                      //           ? Icon(
                                                      //               Icons
                                                      //                   .alarm_outlined,
                                                      //               color: Colors
                                                      //                   .white,
                                                      //             )
                                                      //           : Text(""),
                                                      //       (startLivediff < 0)
                                                      //           ? Text(
                                                      //               "Running...",
                                                      //               style:
                                                      //                   TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontSize:
                                                      //                     17.0,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .bold,
                                                      //               ),
                                                      //             )
                                                      //           : Text(""),
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                    ),
                                                    Visibility(
                                                      visible: (snapshot
                                                                  .data.documents
                                                                  .elementAt(
                                                                      index)[
                                                              'noticetype'] ==
                                                          "Assignment"),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        // color: Colors.redAccent,
                                                        child: Text(
                                                          "  " +
                                                                  snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)['point']
                                                                      .toString() +
                                                                  "  " ??
                                                              "loading.....",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        snapshot.data.documents
                                                                    .elementAt(
                                                                        index)[
                                                                'name'] ??
                                                            "loading.....",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Text("Subject:  ",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.amber[900],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    Expanded(
                                                      child: Text(
                                                          snapshot.data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)[
                                                                  'subject'] ??
                                                              "loading.....",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            //  fontWeight: FontWeight.bold,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Visibility(
                                                visible: (snapshot
                                                            .data.documents
                                                            .elementAt(index)[
                                                        'noticetype'] ==
                                                    "Live"),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Text("Start Date:  ",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .amber[900],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                      Text(
                                                          (snapshot.data.documents
                                                                          .elementAt(
                                                                              index)[
                                                                      "datelivestart"] !=
                                                                  null)
                                                              ? DateFormat.yMMMEd("en_US").format(snapshot
                                                                      .data
                                                                      .documents
                                                                      .elementAt(index)[
                                                                          "datelivestart"]
                                                                      .toDate()) +
                                                                  " at- " +
                                                                  DateFormat("H:mm").format(snapshot
                                                                      .data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)["datelivestart"]
                                                                      .toDate())
                                                              : "loading.....",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            //  fontWeight: FontWeight.bold,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Visibility(
                                                visible: (snapshot
                                                            .data.documents
                                                            .elementAt(index)[
                                                        'noticetype'] !=
                                                    "Notice"),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Text("Due Date:  ",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .amber[900],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
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
                                                                  DateFormat("H:mm").format(snapshot
                                                                      .data
                                                                      .documents
                                                                      .elementAt(
                                                                          index)["datecompleted"]
                                                                      .toDate())
                                                              : "loading.....",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            //  fontWeight: FontWeight.bold,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Visibility(
                                                visible: (snapshot
                                                            .data.documents
                                                            .elementAt(index)[
                                                        'noticetype'] ==
                                                    "Attendance"),
                                                child: Container(
                                                    child: Column(
                                                  children: [
                                                    (diff > 0)
                                                        ? Row(
                                                            children: [
                                                              Spacer(),
                                                              Bounce(
                                                                onPressed: () {
                                                                  // CurrentUser
                                                                  //     _currentuser =
                                                                  //     Provider.of<
                                                                  //             CurrentUser>(
                                                                  //         context,
                                                                  //         listen:
                                                                  //             false);
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
                                                                            .elementAt(index)
                                                                            .documentID
                                                                            .toString());
                                                                  }
                                                                },
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        200),
                                                                child: Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                          .blue[
                                                                      300],
                                                                  size: 45,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 40,
                                                              ),
                                                              Bounce(
                                                                onPressed: () {
                                                                  Scaffold.of(
                                                                          context)
                                                                      .showSnackBar(new SnackBar(
                                                                          content:
                                                                              new Text("Your Responce is Saved")));
                                                                },
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        200),
                                                                child: Icon(
                                                                  Icons
                                                                      .highlight_remove,
                                                                  color: Colors
                                                                      .red[300],
                                                                  size: 45,
                                                                ),
                                                              ),
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
                                                              color: Colors
                                                                  .blue[300]),
                                                        ),
                                                        SizedBox(
                                                          width: 40,
                                                        ),
                                                        Text("Absent",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red[300])),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }
              },
            ),
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
