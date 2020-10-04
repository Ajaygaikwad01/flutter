import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:worldetor/screens/home/drawer.dart';

import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

import 'package:worldetor/widgets/HomeNavigator.dart';

class OurAlartPage extends StatefulWidget {
  @override
  _OurAlartPageState createState() => _OurAlartPageState();
}

class _OurAlartPageState extends State<OurAlartPage> {
  @override
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          title: Consumer<CurrentGroup>(
            builder: (BuildContext context, value, Widget child) {
              return Text(value.getCurrentGroup.name ?? " loding....");
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeNavigator()),
                    (route) => false);
              },
            ),
          ]),
      drawer: OurDrawer(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection("groups")
              .document(_currentgroup.getCurrentGroup.id)
              .collection("notice")
              .document(_currentgroup.getCurrentGroup.currentNoticeid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("empty"),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(5),
                child: Ourcontener(
                  child: ListView(children: [
                    Container(
                      color: Colors.amber,
                      alignment: Alignment.center,
                      child: Text(
                        snapshot.data['noticetype'] ?? "Loading...",
                        style: TextStyle(
                          // color: Colors.amber,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Title: ",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              snapshot.data['name'] ?? "Loading...",
                              style: TextStyle(
                                // color: Colors.amber,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Subject: ",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              snapshot.data['subject'] ?? "Loading...",
                              style: TextStyle(
                                // color: Colors.amber,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Description:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "-    ",
                            // style: TextStyle(
                            //   // color: Colors.amber,
                            //   fontSize: 15.0,
                            //   fontWeight: FontWeight.bold,
                            // ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data['description'] ?? "Loading...",
                              style: TextStyle(
                                // color: Colors.amber,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.amber,
                          size: 25,
                        ),
                        onPressed: () {
                          _bottomsheet(context);
                        })
                  ]),
                ),
              );
            }
          }),
    );
  }

  void _bottomsheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * .60,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Ourcontener(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Add Assignment"),
                        Spacer(),
                        IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.amber,
                              size: 25,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                    Text("Select your document and press send Button")
                  ],
                ),
              ),
            ),
          );
        });
  }
}
