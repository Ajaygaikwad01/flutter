import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/models/notice.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurLiveNotice extends StatefulWidget {
  @override
  _OurLiveNoticeState createState() => _OurLiveNoticeState();
}

class _OurLiveNoticeState extends State<OurLiveNotice> {
  @override
  void initState() {
    super.initState();
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _addnotice(BuildContext context, OurNotice notice) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    String _returnString = await OurDatabase().addnotice(
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

  TextEditingController _noticeTitleController = TextEditingController();

  TextEditingController _noticeDescriptionController = TextEditingController();
  TextEditingController _noticeSubjectController = TextEditingController();
  DateTime _selecedtDate = DateTime.now();
  DateTime _selecedStartLiveDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await DatePicker.showDateTimePicker(context, showTitleActions: true);
    if (picked != null && picked != _selecedtDate) {
      setState(() {
        _selecedtDate = picked;
      });
    }
  }

  Future<void> _selectStartLiveDate(BuildContext context) async {
    final DateTime picked =
        await DatePicker.showDateTimePicker(context, showTitleActions: true);
    if (picked != null && picked != _selecedStartLiveDate) {
      setState(() {
        _selecedStartLiveDate = picked;
      });
    }
  }

  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Fill Live Information",
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView(
          children: <Widget>[
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
                    Text(DateFormat.yMMMMd("en_US")
                        .format(_selecedStartLiveDate)),
                    Text(DateFormat("H:mm").format(_selecedStartLiveDate)),
                    FlatButton(
                        onPressed: () => _selectStartLiveDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.red),
                            Text("Select Start Date",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )),
                    SizedBox(height: 10),
                    Text(DateFormat.yMMMMd("en_US").format(_selecedtDate)),
                    Text(DateFormat("H:mm").format(_selecedtDate)),
                    FlatButton(
                        onPressed: () => _selectDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.red),
                            Text("Select Due Date",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )),
                    SizedBox(height: 10),
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
                          // await progressdialog.show();
                          setState(() {
                            loadingcircle = true;
                          });
                          OurNotice notice = OurNotice();
                          notice.noticetype = "Live";

                          notice.name = _noticeTitleController.text;
                          notice.subject = _noticeSubjectController.text;
                          notice.description =
                              _noticeDescriptionController.text;
                          notice.dateLiveStart =
                              Timestamp.fromDate(_selecedStartLiveDate);

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
      ),
    );
  }
}
