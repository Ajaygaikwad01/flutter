import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/models/notice.dart';
import 'package:worldetor/screens/root/root.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurAddAssignment extends StatefulWidget {
  @override
  _OurAddAssignmentState createState() => _OurAddAssignmentState();
}

class _OurAddAssignmentState extends State<OurAddAssignment> {
  void _addnotice(BuildContext context, OurNotice notice) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .addnotice(_currentuser.getCurrentUser.groupid, notice);

    if (_returnString == "Success") {
      Navigator.pop(context);
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => OurRoot(),
      //     ),
      //     (route) => false);
    }
  }

  TextEditingController _noticeTitleController = TextEditingController();
  TextEditingController _noticeSubjectController = TextEditingController();
  TextEditingController _noticepointController = TextEditingController();
  TextEditingController _noticeDescriptionController = TextEditingController();
  // DateTime _selecedSendDate = DateTime.now();
  DateTime _selecedtDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await DatePicker.showDateTimePicker(context, showTitleActions: true);
    if (picked != null && picked != _selecedtDate) {
      setState(() {
        _selecedtDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Assignment"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
                // children: [BackButton()],
                ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Ourcontener(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _noticeTitleController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.title), hintText: "Title"),
                    maxLength: 20,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _noticeSubjectController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.subject), hintText: "Subject"),
                    maxLength: 60,
                  ),
                  SizedBox(
                    height: 20.0,
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
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _noticepointController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.point_of_sale),
                        hintText: "point"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(DateFormat.yMMMMd("en_US").format(_selecedtDate)),
                  Text(DateFormat("H:mm").format(_selecedtDate)),
                  FlatButton(
                      onPressed: () => _selectDate(context),
                      child: Text("Selcet Due Date")),
                  RaisedButton(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                        child: Text(
                          "Send",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      onPressed: () {
                        OurNotice notice = OurNotice();
                        notice.noticetype = "Assignment";
                        notice.name = _noticeTitleController.text;
                        notice.subject = _noticeSubjectController.text;
                        notice.description = _noticeDescriptionController.text;
                        notice.point = int.parse(_noticepointController.text);
                        // notice.datesend = Timestamp.fromDate(_selecedSendDate);
                        notice.datecompleted =
                            Timestamp.fromDate(_selecedtDate);
                        _addnotice(context, notice);
                      })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
