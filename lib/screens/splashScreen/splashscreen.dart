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
              children: [
                AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 90.0,
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
                        height: 70,
                      ),
                      radius: 60.0,
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
