import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/call.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color(0xFF21BFBD),
        body: Consumer<CurrentGroup>(
            builder: (BuildContext context, value, Widget child) {
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
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.menu),
                            color: Colors.white,
                            onPressed: () {},
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
              ),
              child: ListView(
                // primary: false,
                padding: EdgeInsets.only(left: 25.0, right: 20.0, top: 15),
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(value.getCurrentNotice.name ?? "Loading...",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(value.getCurrentNotice.subject ?? "Loading..."),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text("Created by: ",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent)),
                          Text(
                              value.getCurrentGroup.leaderName ?? "Loading..."),
                        ],
                      ),

                      // Text(value.getCurrentGroup. ?? "Loading..."),
                    ],
                  ),
                  RaisedButton(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 60),
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
                    onPressed: () {
                      onJoin();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }));
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
        setState(() {
          _role = ClientRole.Broadcaster;
        });
      } else {
        setState(() {
          _role = ClientRole.Audience;
        });
      }
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _currentgroup.getCurrentNotice.name,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
