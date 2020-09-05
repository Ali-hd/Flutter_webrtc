import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:flutter_web_rtc/models/call.dart';
import 'package:flutter_web_rtc/services/database.dart';
import 'package:flutter_web_rtc/shared/loading.dart';
import 'package:flutter_web_rtc/screens/call/call_screen.dart';


class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModal>(context);
    //you can use provider instead of streambuilder 
    // final userData = Provider.of<UserData>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot){
          if(snapshot.hasData){
            UserData userData = snapshot.data;
            return ListView.builder(
            itemCount: userData.friends.length,
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
                      title: Text('id:' + userData.friends[index]['id']),
                      subtitle: Text('name: ${userData.friends[index]['name']} & ${userData.bio}'),
                      onTap: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => CallScreen(
                            friend: userData.friends[index],
                            user: user
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