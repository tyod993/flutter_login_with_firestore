import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

//-Trevor last edit 7/27/2020

class AuthHandler {
  static const int GOOGLE = 0;
  static const int FIREBASE = 1;
  static const int FACEBOOK = 2;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser user;

  bool isAuthenticated;

  //Keep constructor empty
  AuthHandler();

  ///   Errors:
  ///
  ///  * `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
  ///  * `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
  ///  * `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.

  Future<FirebaseUser> loginWithEmail(email, password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      return result.user;
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  //Maybe we should assume that the user can click to login with google option to create a new account as well.
  //Look at source code here
  //https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/lib/google_sign_in.dart
  //to find all possible errors and place them here in the future.
  Future<FirebaseUser> loginWithGoogle() async {
    try {
      final GoogleSignInAccount _googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication _googleAuthentication =
          await _googleSignInAccount.authentication;

      final AuthCredential _credential = GoogleAuthProvider.getCredential(
          idToken: _googleAuthentication.idToken,
          accessToken: _googleAuthentication.accessToken);

      final AuthResult _result = await _auth.signInWithCredential(_credential);
      user = _result.user;

      print("Successful login using Google user = $user");
      return _result.user;
    } catch (e) {
      print(e);
      return e;
    }
  }

  ///If you're trying to use this feature in your development enviroment you must task to Trevor
  ///about getting a hash for the Facebook Dev account.
  ///
  ///In not sure if I have facebook set up in the dev console yet. If youre on IOS and facebook login doesnt work let me know -Trevor
  ///If you have a problem check the docs here https://github.com/roughike/flutter_facebook_login
  dynamic loginWithFacebook() async {
    try {
      final FacebookLogin _facebookLogin = FacebookLogin();
      final FacebookLoginResult _result = await _facebookLogin.logIn(['email']);

      if (_result != null) {
        FacebookAccessToken accessToken = _result.accessToken;
        final AuthCredential authCredential =
            FacebookAuthProvider.getCredential(accessToken: accessToken.token);
        final AuthResult _authResult =
            await _auth.signInWithCredential(authCredential);
        return _authResult.user;
      }
    } catch (e) {
      print(e);
      return e;
    }
  }

  /// Errors:
  ///
  ///  * `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///  * `ERROR_INVALID_EMAIL` - If the email address is malformed.
  ///  * `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account
  //Not sure if we want to add an email varififcation or not. -T
  //This needs Error option comments -T
  Future<FirebaseUser> registerWithEmailAndPassword(email, password) async {
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      return _result.user;
    } catch (e) {
      print(e);
      return e;
    }
  }

//This may cause problems in the future if the we dont observe the FirebaseAuthPlatform.
  void signOut() {
    _auth.signOut();
    user = null;
  }
}
