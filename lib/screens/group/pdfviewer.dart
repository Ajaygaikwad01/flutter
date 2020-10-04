import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class Ourpdfviewer extends StatefulWidget {
  @override
  _OurpdfviewerState createState() => _OurpdfviewerState();
}

class _OurpdfviewerState extends State<Ourpdfviewer> {
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  PDFDocument doc;
  @override
  Widget build(BuildContext context) {
    String url = ModalRoute.of(context).settings.arguments;
    viewNow() async {
      doc = await PDFDocument.fromURL(url);
      setState(() {});
    }

    Widget loading() {
      viewNow();
      if (doc == null) {
        return Text("loading....");
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("pdf viewer")),
      body:
          Container(child: doc == null ? loading() : PDFViewer(document: doc)),
    );
  }
}
