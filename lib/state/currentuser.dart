import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:worldetor/models/user.dart';
import 'package:worldetor/services/database.dart';

class CurrentUser extends ChangeNotifier {
  OurUser _currentUser = OurUser();

  OurUser get getCurrentUser => _currentUser;

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> onStartUp() async {
    String retval = "Error";
    try {
      FirebaseUser _firebaseUser = await _auth.currentUser();
      _currentUser = await OurDatabase().getUserInfo(_firebaseUser.uid);
      if (_currentUser != null) {
        retval = "Success";
      }
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> signOut() async {
    String retval = "Error";
    try {
      await _auth.signOut();
      _currentUser = OurUser();

      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> signUpUser(
      String email, String password, String fullName) async {
    String retval = "Error";

    OurUser _user = OurUser();
    try {
      AuthResult _authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _user.uid = _authResult.user.uid;
      _user.email = _authResult.user.email;
      _user.fullName = fullName;

      String _returnString = await OurDatabase().createUser(_user);
      if (_returnString == "Success") {
        retval = "Success";
      }
    } catch (e) {
      retval = e.message;
    }

    return retval;
  }

  Future<String> logInWithEmail(String email, String password) async {
    String retval = "Error";
    try {
      AuthResult _authresult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      _currentUser = await OurDatabase().getUserInfo(_authresult.user.uid);
      if (_currentUser != null) {
        retval = "Success";
      }
    } on PlatformException catch (e) {
      retval = e.message;
    }

    return retval;
  }

  Future<String> logInWithGoogle() async {
    String retval = "Error";
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    OurUser _user = OurUser();
    try {
      GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      // ignore: deprecated_member_use
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);

      AuthResult _authresult = await _auth.signInWithCredential(credential);

      if (_authresult.additionalUserInfo.isNewUser) {
        _user.uid = _authresult.user.uid;
        _user.email = _authresult.user.email;
        _user.fullName = _authresult.user.displayName;
        OurDatabase().createUser(_user);
      }
      _currentUser = await OurDatabase().getUserInfo(_authresult.user.uid);
      if (_currentUser != null) {
        retval = "Success";
      }
    } on PlatformException catch (e) {
      retval = e.message;
    }

    return retval;
  }
}
