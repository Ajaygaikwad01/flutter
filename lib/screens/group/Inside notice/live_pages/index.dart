import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

import './call.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  // String _chennelName;

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;
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
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
      builder: (BuildContext context, value, Widget child) {
        return Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title:
                  Text('Waiting room', style: TextStyle(color: Colors.white))),
          body: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(value.getCurrentNotice.name ?? "Loading..."),

                      // Expanded(
                      //     child: TextField(
                      //   controller: _channelController,
                      //   decoration: InputDecoration(
                      //     errorText:
                      //         _validateError ? 'Channel name is mandatory' : null,
                      //     border: UnderlineInputBorder(
                      //       borderSide: BorderSide(width: 1),
                      //     ),
                      //     hintText: 'Channel name',
                      //   ),
                      // ))
                    ],
                  ),
                  // Column(
                  //   children: [
                  //     ListTile(
                  //       title: Text(ClientRole.Broadcaster.toString()),
                  //       leading: Radio(
                  //         value: ClientRole.Broadcaster,
                  //         groupValue: _role,
                  //         onChanged: (ClientRole value) {
                  //           setState(() {
                  //             _role = value;
                  //           });
                  //         },
                  //       ),
                  //     ),
                  //     ListTile(
                  //       title: Text(ClientRole.Audience.toString()),
                  //       leading: Radio(
                  //         value: ClientRole.Audience,
                  //         groupValue: _role,
                  //         onChanged: (ClientRole value) {
                  //           setState(() {
                  //             _role = value;
                  //           });
                  //         },
                  //       ),
                  //     )
                  //   ],
                  // ),
                  RaisedButton(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                      child: Text(
                        "Join Stream",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: onJoin,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       vertical: 20, horizontal: 20),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: RaisedButton(
                  //           onPressed: onJoin,
                  //           child: Text('Join'),
                  //           color: Colors.blueAccent,
                  //           textColor: Colors.white,
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
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
