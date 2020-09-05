import 'package:flutter/material.dart';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:flutter_web_rtc/screens/home/calls_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_rtc/services/auth.dart';
import 'package:flutter_web_rtc/models/call.dart';
import 'package:flutter_web_rtc/services/database.dart';
import './friend_list.dart';
import 'package:flutter_web_rtc/screens/call/call_screen.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModal>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot){
        return Scaffold(
        backgroundColor: Colors.orange[200],
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            // Navigator.push(
            //   context, 
            //   MaterialPageRoute(
            //     builder: (_) => CallScreen(
            //       userData: snapshot.data
            //       )
            //     )
            //   );
            },
          child: Icon(Icons.search),
          backgroundColor: Colors.green[600],
        ),
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Colors.red[400],
          actions: [
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async{
                await _auth.signOut();
              },
            )
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: FriendList()
              ),
              Flexible(
                flex: 1,
                child: CallsList()
              )
            ],
          )
        ),
      );
      }
    );
  }
}