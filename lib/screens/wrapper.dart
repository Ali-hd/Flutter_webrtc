
import 'package:flutter_web_rtc/screens/authentication/authentication.dart';
import 'package:flutter_web_rtc/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_rtc/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModal>(context);

    // return either Home or Authenticate widget
    if(user == null){
      return Authentication();
    }else{
      return Home();
    }
  }
}