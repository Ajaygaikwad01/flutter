import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Ourcontener(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(
                //   height: 30,
                // ),
                AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 100.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Material(
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Image.asset(
                        "lib/assets/logo.PNG",
                        height: 80,
                      ),
                      radius: 70.0,
                    ),
                  ),
                ),
                CircularProgressIndicator(),
              ],
            ),
            // Text("Loding......."),
          ),
        ),
      ),
    );
  }
}
