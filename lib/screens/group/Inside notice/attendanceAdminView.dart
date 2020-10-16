import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurAttendanceAdminPage extends StatefulWidget {
  @override
  _OurAttendanceAdminPageState createState() => _OurAttendanceAdminPageState();
}

class _OurAttendanceAdminPageState extends State<OurAttendanceAdminPage> {
  @override
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _deletedialog(groupId, noticeId, name, nameid) {
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
            _removename(groupId, noticeId, name, nameid);
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

  void _alertDueDatedialog() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Success",
      desc: "Due Date Changed",
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

  void _removename(groupId, noticeId, name, nameid) async {
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("notice")
        .document(noticeId)
        .updateData({
      "attendynames": FieldValue.arrayRemove([name]),
      "attendyid": FieldValue.arrayRemove([nameid]),
    });
  }

  void _flotingdialogbox(groupId) {
    TextEditingController _uniqueIdcontroller = TextEditingController();
    DateTime time = DateTime.now();
    String currentTime = DateFormat.yMMMMd("en_US").format(time);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Manual Attendance"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _uniqueIdcontroller,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label_important_outlined),
                      hintText: "UniqueId/CollegeId/RollNo"),
                )
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
                    await Firestore.instance
                        .collection("groups")
                        .document(groupId)
                        .collection("groupTotalAttendance")
                        .document(_uniqueIdcontroller.text)
                        .updateData({
                      //  'id': _docref.documentID,
                      currentTime: "present",
                    });

                    Navigator.of(context).pop();
                    _alertDueDatedialog();
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: new Text("Attendance marked")));
                  },
                  child: Text("Sunmit")),
            ],
          );
        });
  }

  void attendbutton(groupid, indexval) async {
    DateTime time = DateTime.now();
    String currentTime = DateFormat.yMMMMd("en_US").format(time);

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    int noticepoint = 1;
    DocumentSnapshot docref = await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("group_member")
        .document(indexval)
        .get();
    var currntpoint = docref.data["attend"];
    int totalpoint = currntpoint + noticepoint;

    print(totalpoint);
    await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("group_member")
        .document(indexval)
        .updateData({"attend": totalpoint});
    // await OurDatabase().groupTotalAttendance(
    //     groupid, _currentuser.getCurrentUser.uniqueId, currentTime);
    await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("groupTotalAttendance")
        .document(_currentuser.getCurrentUser.uniqueId)
        .updateData({
      //  'id': _docref.documentID,
      currentTime: "present",
    });
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
                Text(DateFormat.yMMMMd("en_US").format(_selecedtDate)),
                Text(DateFormat("H:mm").format(_selecedtDate)),
                FlatButton(
                    onPressed: () => _selectDate(context),
                    child: Text("Selcet Due Date")),
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
                    await Firestore.instance
                        .collection("groups")
                        .document(groupid)
                        .collection("notice")
                        .document(noticeid)
                        .updateData({'datecompleted': _selecedtDate});

                    Navigator.of(context).pop();
                    _alertDueDatedialog();
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: new Text("Unique Id Updated")));
                  },
                  child: Text("Sunmit")),
            ],
          );
        });
  }

  Widget _extendButton(context, groupid, noticeid) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: 165,
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
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
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

  @override
  Widget build(BuildContext context) {
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
                                    Row(
                                      children: [
                                        Icon(Icons.people_alt,
                                            color: Colors.white),
                                        Text(
                                          " " +
                                              snapshot
                                                  .data["attendynames"].length
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
                      SizedBox(height: 25.0),
                      Padding(
                        padding: EdgeInsets.only(left: 40.0),
                        child: Row(
                          children: <Widget>[
                            Text("Attendees",
                                style: TextStyle(
                                    // fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0)),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Text("List",
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
                        child:
                            // primary: false,
                            // padding:
                            //     EdgeInsets.only(left: 25.0, right: 18.0, top: 15),
                            Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _extendButton(context, value.getCurrentGroup.id,
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
                                itemCount: snapshot.data["attendynames"].length,
                                itemBuilder: (BuildContext context, int index) {
                                  String name =
                                      snapshot.data["attendynames"][index];
                                  String nameid =
                                      snapshot.data["attendyid"][index];

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
                                            // setState(() {
                                            //   loading = !loading;
                                            // });
                                            _deletedialog(
                                                value.getCurrentGroup.id,
                                                value.getCurrentNotice.id,
                                                name,
                                                nameid);
                                          },
                                        )
                                      ],
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Bounce(
                                          duration: Duration(milliseconds: 110),
                                          onPressed: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
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
                                            child: Row(
                                              children: [
                                                Text("  " +
                                                        snapshot.data[
                                                                "attendynames"]
                                                            [index] ??
                                                    "Loading "),
                                                Spacer(),
                                                FlatButton(
                                                    onPressed: () {
                                                      attendbutton(
                                                          value.getCurrentGroup
                                                              .id,
                                                          snapshot.data[
                                                                  "attendyid"]
                                                              [index]);

                                                      _removename(
                                                          value.getCurrentGroup
                                                              .id,
                                                          value.getCurrentNotice
                                                              .id,
                                                          name,
                                                          nameid);

                                                      Scaffold.of(context)
                                                          .showSnackBar(new SnackBar(
                                                              content: new Text(
                                                                  "Attendance marked")));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .check_box_sharp,
                                                            color: Colors
                                                                .blueAccent),
                                                        Text(
                                                          "Check",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    )),
                                                // IconButton(
                                                //     splashColor: Colors.grey,
                                                //     icon: Icon(
                                                //         Icons.check_box_sharp,

                                                //         color:
                                                //             Colors.blueAccent),
                                                //     onPressed: () async {

                                                //     }),
                                                // SizedBox(width: 10),
                                              ],
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Manual Attendance",
          backgroundColor: Colors.blue,
          onPressed: () {
            _flotingdialogbox(value.getCurrentGroup.id);
          },
        ),
      );
    });
  }
}
