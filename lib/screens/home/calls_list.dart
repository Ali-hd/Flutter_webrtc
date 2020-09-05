import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:flutter_web_rtc/models/call.dart';
import 'package:flutter_web_rtc/services/database.dart';
import 'package:flutter_web_rtc/shared/loading.dart';
import 'package:flutter_web_rtc/screens/call/call_screen.dart';


class CallsList extends StatefulWidget {
  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModal>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot){
          if(snapshot.hasData){
            UserData userData = snapshot.data;
            return ListView.builder(
            itemCount: userData.calls.length,
            itemBuilder: (context, index){
              return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Card(
                    margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.brown[100],
                        backgroundImage: NetworkImage('https://i.imgur.com/1Oteoyk.png'),
                      ),
                      title: Text('incoming call:'),
                      subtitle: Text('click to answer'),
                      onTap: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => CallScreen(
                            callIdProp: userData.calls[index],
                            )
                          )
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }else{
            return Loading();
          }
        }
    );
  }
}