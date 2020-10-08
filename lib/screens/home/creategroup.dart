import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/root/root.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurCreateGroup extends StatefulWidget {
  @override
  _OurCreateGroupState createState() => _OurCreateGroupState();
}

class _OurCreateGroupState extends State<OurCreateGroup> {
  void _createGroup(
      BuildContext context, String groupName, String description) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase().createGroup(
        groupName,
        description,
        _currentuser.getCurrentUser.uid,
        _currentuser.getCurrentUser.fullName,
        _currentuser.getCurrentUser.email,
        _currentuser.getCurrentUser.uniqueId);

    if (_returnString == "Success") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OurRoot(),
          ),
          (route) => false);
    }
  }

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupdescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
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
                    controller: _groupNameController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.group), hintText: "Group Name"),
                    maxLength: 25,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _groupdescriptionController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.description),
                        hintText: "Group Description"),
                    maxLength: 50,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                        child: Text(
                          "Create",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      onPressed: () {
                        CurrentUser _currentuser =
                            Provider.of<CurrentUser>(context, listen: false);
                        if (_currentuser.getCurrentUser.uniqueId != null) {
                          _createGroup(context, _groupNameController.text,
                              _groupdescriptionController.text);
                        } else {
                          print("uniqueid not avilable");
                          // Scaffold.of(context).showSnackBar(new SnackBar(
                          //     content: new Text("Please add Unique ID")));
                        }
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
