import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/root/root.dart';

import 'package:worldetor/state/currentuser.dart';

class OurDrawer extends StatefulWidget {
  @override
  _OurDrawerState createState() => _OurDrawerState();
}

class _OurDrawerState extends State<OurDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.greenAccent[100],
            child: Center(
              child: Consumer<CurrentUser>(
                builder: (BuildContext context, value, Widget child) {
                  return Column(
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 30, bottom: 10),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage("lib/assets/google_logo.png"),
                                fit: BoxFit.fill)),
                      ),
                      Text(
                        value.getCurrentUser.fullName,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      Text(
                        value.getCurrentUser.email,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Text(
                        value.getCurrentUser.groupid ?? " loding....",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("sign Out",
                style: TextStyle(fontSize: 18, color: Colors.black)),
            onTap: () async {
              CurrentUser _currentuser =
                  Provider.of<CurrentUser>(context, listen: false);

              String _returnstring = await _currentuser.signOut();
              if (_returnstring == "Success") {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => OurRoot()),
                    (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
