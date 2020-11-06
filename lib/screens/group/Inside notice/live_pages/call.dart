import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/livechat.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/livedrawer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

import './settings.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool hidecam = false;
  RtcEngine _engine;
  TextEditingController _chatController = TextEditingController();
  @override
  void dispose() {
    // CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    // CurrentGroup _currentgroup =
    //     Provider.of<CurrentGroup>(context, listen: false);
    // await Firestore.instance
    //     .collection("groups")
    //     .document(_currentgroup.getCurrentGroup.id)
    //     .collection("notice")
    //     .document(_currentgroup.getCurrentNotice.id)
    //     .collection("joinmembers")
    //     .document(_currentuser.getCurrentUser.uid)
    //     .delete();
    // clear users
    _users.clear();

    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();

    super.dispose();
    print("leave");

    // try {
    // await Firestore.instance
    //     .collection("groups")
    //     .document(_currentgroup.getCurrentGroup.id)
    //     .collection("notice")
    //     .document(_currentgroup.getCurrentNotice.id)
    //     .collection("joinmembers")
    //     .document(_currentuser.getCurrentUser.uid)
    //     .delete();
    // print("ajay gaikwad");
    // } catch (e) {
    // print("erros " + e);
    // }
    // _memberleft();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  // void _memberleft() async {
  //   CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
  //   CurrentGroup _currentgroup =
  //       Provider.of<CurrentGroup>(context, listen: false);
  //   try {
  //     await Firestore.instance
  //         .collection("groups")
  //         .document(_currentgroup.getCurrentGroup.id)
  //         .collection("notice")
  //         .document(_currentgroup.getCurrentNotice.id)
  //         .collection("joinmembers")
  //         .document(_currentuser.getCurrentUser.uid)
  //         .delete();
  //     print("ajay gaikwad");
  //   } catch (e) {
  //     print("erros " + e);
  //   }
  // }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // ignore: deprecated_member_use
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void _sendmessage(message) async {
    try {
      CurrentUser _currentuser =
          Provider.of<CurrentUser>(context, listen: false);
      CurrentGroup _currentgroup =
          Provider.of<CurrentGroup>(context, listen: false);
      await Firestore.instance
          .collection("groups")
          .document(_currentgroup.getCurrentGroup.id)
          .collection("notice")
          .document(_currentgroup.getCurrentNotice.id)
          .collection("chats")
          .add({
        'senderId': _currentuser.getCurrentUser.uid,
        'sendername': _currentuser.getCurrentUser.fullName,
        'message': message,
        'senddate': Timestamp.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  /// Toolbar layout
  Widget get _toolbar {
    if (widget.role == ClientRole.Audience) {
      return Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Flexible(
                    child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _chatController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.chat),
                    hintText: "Chat",
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                  ),
                )),
                IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent, size: 35),
                    onPressed: () {
                      _sendmessage(_chatController.text);
                      _chatController.clear();
                      // print("send");
                    })
              ],
            ),
          ],
        ),
      );
    }
    // final views = _getRenderViews();
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye),
              Text("viewers [${_users.length.toString()}]",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Spacer(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: _onDesableCamera,
                  child: Icon(
                    hidecam ? Icons.videocam_off : Icons.videocam,
                    color: hidecam ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: hidecam ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                ),
                RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                    child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _chatController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.chat),
                    hintText: "Chat",
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                  ),
                )),
                IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent, size: 35),
                    onPressed: () {
                      _sendmessage(_chatController.text);
                      _chatController.clear();
                      // print("send");
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          // alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Consumer<CurrentGroup>(
              builder: (BuildContext context, value, Widget child) {
            return StreamBuilder(
                stream: Firestore.instance
                    .collection("groups")
                    .document(value.getCurrentGroup.id)
                    .collection("notice")
                    .document(value.getCurrentNotice.id)
                    .collection("chats")
                    .orderBy("senddate", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Text("empty"),
                    );
                  } else {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            snapshot.data.documents.elementAt(
                                                    index)["sendername"] ??
                                                "Loading..",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11)),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          snapshot.data.documents.elementAt(
                                                  index)["message"] ??
                                              "Loading..",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                });
          }),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onDesableCamera() {
    setState(() {
      hidecam = !hidecam;
    });
    // print(hidecam);
    // _engine.muteLocalVideoStream(hidecam);
    // _engine.muteAllRemoteVideoStreams(muted);
    if (hidecam == true) {
      _engine.disableVideo();
    } else if (hidecam == false) {
      _engine.enableVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Live Stream', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
              icon: Icon(Icons.chat_rounded),
              onPressed: () {
                Widget retval;
                retval = ChangeNotifierProvider(
                  create: (context) => CurrentGroup(),
                  child: OurLiveChat(),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => retval),
                );
              })
        ],
      ),
      backgroundColor: Colors.black,
      drawer: OurLiveDrawer(),
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar,
          ],
        ),
      ),
    );
  }
}
