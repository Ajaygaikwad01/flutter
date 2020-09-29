import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurChatPaage extends StatefulWidget {
  @override
  _OurChatPaageState createState() => _OurChatPaageState();
}

class _OurChatPaageState extends State<OurChatPaage> {
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CurrentGroup>(
          builder: (BuildContext context, value, Widget child) {
            return Text(value.getCurrentGroup.name ?? " loding....");
          },
        ),
      ),
      drawer: OurDrawer(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [],
      ),
    );
  }
}
