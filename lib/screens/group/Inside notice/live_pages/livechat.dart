import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurLiveChat extends StatefulWidget {
  @override
  _OurLiveChatState createState() => _OurLiveChatState();
}

class _OurLiveChatState extends State<OurLiveChat> {
  @override
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
    // _startTimer();
  }

  TextEditingController _chatController = TextEditingController();
  // DateTime _currentDate = DateTime.now();
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

  _chatlist() {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    return Consumer<CurrentGroup>(
      builder: (BuildContext context, value, Widget child) {
        return Container(
          child: StreamBuilder(
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
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.data.documents == null) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                (_currentuser.getCurrentUser.uid !=
                                        snapshot.data.documents
                                            .elementAt(index)["senderId"])
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 140),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          // width: 50,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius:
                                                  BorderRadius.circular(18.0)),
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    snapshot.data.documents
                                                            .elementAt(index)[
                                                        "sendername"],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                    )),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    snapshot.data.documents
                                                        .elementAt(
                                                            index)["message"],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    )),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    DateFormat("H:mm").format(
                                                        snapshot.data.documents
                                                            .elementAt(index)[
                                                                "senddate"]
                                                            .toDate()),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white)),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 140),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          // width: 50,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                                  BorderRadius.circular(18.0)),
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    snapshot.data.documents
                                                            .elementAt(index)[
                                                        "sendername"],
                                                    style: TextStyle(
                                                      // color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                    )),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    snapshot.data.documents
                                                        .elementAt(
                                                            index)["message"],
                                                    style: TextStyle(
                                                      // color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    )),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    DateFormat("H:mm").format(
                                                        snapshot.data.documents
                                                            .elementAt(index)[
                                                                "senddate"]
                                                            .toDate()),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      // color: Colors.white,
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                              ],
                            );
                          }),
                    );
                  }
                }
              }),
        );
      },
    );
  }

  _chatbox() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Flexible(
              child: TextFormField(
            style: TextStyle(color: Colors.white),
            controller: _chatController,
            decoration:
                InputDecoration(prefixIcon: Icon(Icons.chat), hintText: "Chat"),
          )),
          IconButton(
              icon: Icon(Icons.send, color: Colors.blueAccent, size: 35),
              onPressed: () {
                _sendmessage(_chatController.text);
                _chatController.clear();
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Live Stream', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cached),
            color: Colors.white,
            onPressed: () {
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
        ],
      ),
      body: Stack(children: <Widget>[
        _chatlist(),
        _chatbox(),
      ]),
    );
  }
}
