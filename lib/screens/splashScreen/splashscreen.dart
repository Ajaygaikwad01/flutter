import 'package:flutter/material.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Ourcontener(
          child: Center(
            child: CircularProgressIndicator(),
            // Text("Loding......."),
          ),
        ),
      ),
    );
  }
}
