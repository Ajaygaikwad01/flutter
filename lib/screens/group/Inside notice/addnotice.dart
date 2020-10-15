import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:provider/provider.dart';
import 'package:worldetor/models/notice.dart';

import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurAddNotice extends StatefulWidget {
  @override
  _OurAddNoticeState createState() => _OurAddNoticeState();
}

class _OurAddNoticeState extends State<OurAddNotice> {
  void _addnotice(BuildContext context, OurNotice notice) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase()
        .addnotice(_currentuser.getCurrentUser.groupid, notice);

    if (_returnString == "Success") {
      await progressdialog.hide();
      Navigator.pop(context);
    }
  }

  TextEditingController _noticeTitleController = TextEditingController();

  TextEditingController _noticeDescriptionController = TextEditingController();
  TextEditingController _noticeSubjectController = TextEditingController();
  // DateTime _selecedtDate = DateTime.now();
  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime picked =
  //       await DatePicker.showDateTimePicker(context, showTitleActions: true);
  //   if (picked != null && picked != _selecedtDate) {
  //     setState(() {
  //       _selecedtDate = picked;
  //     });
  //   }
  // }

  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);
    progressdialog.style(
      message: "Loading....",
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Fill Notice Information",
            style: TextStyle(color: Colors.white)),
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
                  // Text(DateFormat.yMMMMd("en_US").format(_selecedtDate)),
                  // Text(DateFormat("H:mm").format(_selecedtDate)),
                  // FlatButton(
                  //     onPressed: () => _selectDate(context),
                  //     child: Text("Selcet Due Date")),
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
                      onPressed: () async {
                        await progressdialog.show();

                        OurNotice notice = OurNotice();
                        notice.noticetype = "notice";
                        notice.name = _noticeTitleController.text;
                        notice.subject = _noticeSubjectController.text;
                        notice.description = _noticeDescriptionController.text;
                        // notice.datesend = Timestamp.fromDate(_selecedSendDate);
                        // notice.datecompleted =
                        //     Timestamp.fromDate(_selecedtDate);
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
