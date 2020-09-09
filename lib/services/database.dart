import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:flutter_web_rtc/models/call.dart';

class DatabaseService {
  
  final String uid;
  final UserData userInfo;
  final String callId;
  DatabaseService({ this.uid, this.userInfo, this.callId});

  //collection reference
  final CollectionReference callsCollection = FirebaseFirestore.instance.collection('calls');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future createUserData(List friends, String name, String bio, String imgUrl, List calls) async {
    return await usersCollection.doc(uid).set({
      'friends': friends,
      'name': name,
      'bio': bio,
      'imgUrl' : imgUrl,
      'calls' : calls
    });
  }

  // call list from snapshot
  List<Call> _callsListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Call(
        callerId: doc.data()['callerId'],
        calleeId: doc.data()['calleeId'],
        callerOffer: doc.data()['callerOffer'] ?? '',
        callerIce: doc.data()['callerIce'] ?? 0,
        calleeAnswer: doc.data()['caleeAnswer'] ?? '0',
        calleeIce: doc.data()['calleeIce'],
        accepted: doc.data()['accepted']
      );
    }).toList();
  }

  // userData from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot){
    print(snapshot.data()['bio']);

    return UserData(
      bio: snapshot.data()['bio'],
      name: snapshot.data()['name'],
      friends: snapshot.data()['friends'],
      imgUrl: snapshot.data()['imgUrl'],
      calls: snapshot.data()['calls']
    );
  }

  Call _callDataFromSnapshot(DocumentSnapshot snapshot){
    print(snapshot.data()['bio']);

    return Call(
      callerId: snapshot.data()['callerId'],
      calleeId: snapshot.data()['calleeId'],
      callerOffer: snapshot.data()['callerOffer'],
      callerIce: snapshot.data()['callerIce'],
      calleeAnswer: snapshot.data()['calleeAnswer'],
      calleeIce: snapshot.data()['calleeIce'],
      accepted: snapshot.data()['accepted'],
    );
  }

  //get calls Stream
  Stream<List<Call>> get calls {
    return callsCollection.snapshots()
      .map(_callsListFromSnapshot);
  }

  // get userDate document stream
  Stream<UserData> get userData {
    print('got user data');
    return usersCollection.doc(uid).snapshots()
      .map(_userDataFromSnapshot);
  }

  // get a call stream
  Stream<Call> get callData {
    print('getting call data');
    return callsCollection.doc(callId).snapshots()
      .map(_callDataFromSnapshot);
  }

  Future<List> get popUserCalls async{
    List calls = [];

    userInfo.calls.map((call){
       callsCollection.doc(call).get().then((doc){
          calls.add(doc);
        }
       );
    });

    return calls;
  } 

  Future updateUserData(String bio) async {
    return await usersCollection.doc(uid).update({
      'bio': bio,
    });
  }

  Future updateCallAnswer(String calleeAnswer) async {
    return await callsCollection.doc(callId).update({
      'calleeAnswer' : calleeAnswer,
      'accepted' : true
    });
  }

  Future updateCalleeCandidate(String calleeIce) async {
    return await callsCollection.doc(callId).update({
      'calleeIce' : calleeIce,
    });
  }

  Future updateCallerCandidate(String callerIce) async {
    return await callsCollection.doc(callId).update({
      'callerIce' : callerIce,
    });
  }

  Future<String> createCall(String callerId, String callerOffer, String friendId) async {
    DocumentReference docRef = await callsCollection.add({
      'callerId': callerId,
      'callerOffer': callerOffer,
      'accepted' : false,
      'calleeId' : friendId
    });

    await usersCollection.doc(friendId).update({
      'calls': FieldValue.arrayUnion([docRef.id])
    });

    print('creating call at database');
    print(docRef.id);

    return docRef.id;
  }


}