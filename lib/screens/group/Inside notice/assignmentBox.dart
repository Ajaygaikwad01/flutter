import 'package:flutter/material.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurAssignmentBox extends StatefulWidget {
  @override
  _OurAssignmentBoxState createState() => _OurAssignmentBoxState();
}

class _OurAssignmentBoxState extends State<OurAssignmentBox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Ourcontener(
          child: ListView(children: [
            Column(
              children: [
                Container(
                    color: Colors.amber,
                    alignment: Alignment.center,
                    child: Text(
                      "Assignment",
                      style: TextStyle(
                        // color: Colors.amber,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
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
                          "Title is here",
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
                          "subject is here",
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Description: ",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "               ",
                            style: TextStyle(
                              // color: Colors.amber,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
