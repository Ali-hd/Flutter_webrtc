import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_rtc/models/user.dart';
import './database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create a user obj based on FirebaseUser response
  UserModal _userFromFirebaseUser(User user){
    return user != null ? UserModal(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserModal> get user {
    print('getting user from firebase');
    return _auth.authStateChanges().map(_userFromFirebaseUser);
          // .map((FirebaseUser user) => _userFromFirebaseUser(user));
          //same way above
  }

  // sign in anon
  Future signInAnon() async {
    try{
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  // sing in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password
      );
      User user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  //register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      User user = result.user;

    // create a new user profile in users collection
      await DatabaseService(uid: user.uid).createUserData(
        [], 'new name', 'no bio yet', 'url not provided', []
      );
      return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}