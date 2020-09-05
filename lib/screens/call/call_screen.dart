import 'dart:convert';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:flutter_web_rtc/services/database.dart';
import 'package:flutter_web_rtc/shared/loading.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_web_rtc/models/call.dart';

class CallScreen extends StatefulWidget {

  final Map<String, dynamic> friend;
  final UserModal user;
  final String callIdProp;
  CallScreen({this.friend, this.user, this.callIdProp});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  


  bool _offer = false;
  bool candSubmit = false;
  String icecandidate;
  String callerOffer;
  String calleeAnswer;
  String callId;

  RTCPeerConnection _peerConnection;
  MediaStream _localStream;

  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();

  final sdpController = TextEditingController();
  

  @override
  dispose(){
    super.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
      print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&${widget.callIdProp}');
      if(widget.callIdProp == null){  
        _createOffer().then((offer){
        callerOffer = offer;
        });
      }
    });
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _createPeerConnection() async{
    Map<String, dynamic> configuration = {
      "iceServers":[
        {"url": "stun:stun.l.google.com:19302"}
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": "true",
        "OfferToReceiveVideo": "true"
      },
      "optional": []
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream);

    pc.onIceCandidate = (e) async{
      if(e.candidate != null && candSubmit != true){
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex
        }));
        candSubmit = true;
        icecandidate = json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex
        });
          if(callerOffer != null){
            DatabaseService().createCall(widget.user.uid, callerOffer, widget.friend['id'].trim()).then((id){
            setState((){
              callId = id;
            });
          });
        }

        if(calleeAnswer != null){
          DatabaseService(callId: widget.callIdProp).updateCallData(calleeAnswer, icecandidate);
        }
      }
    };

    pc.onIceConnectionState = (e){
      print('onIceConnectionState: $e');
    };

    pc.onAddStream = (stream){
      print('onAddStream' + stream.id);
    };

    return pc;
  }

  _getUserMedia() async{
    final Map<String, dynamic> mediaConstraints = {
      'audio': 'true',
      'video': {
        'facingMode': 'user'
      },
    }; 
    MediaStream stream = await navigator.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = stream;
    _localRenderer.mirror = true;

    return stream;
  }

  _createOffer() async{
    RTCSessionDescription description = await _peerConnection
      .createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);
    String sessionString = json.encode(session);
    print('creating offer');
    print(sessionString);
    _offer = true;

    _peerConnection.setLocalDescription(description);

    return sessionString;
  }

  void _setRemoteDescription(String jsonString) async{
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    RTCSessionDescription description = new RTCSessionDescription(
      sdp, _offer ? 'answer' : 'offer' );

    print(description.toMap());

    await _peerConnection.setRemoteDescription(description);

    if(widget.callIdProp != null){
      _createAnswer().then((answer){
          calleeAnswer = answer;
        });
    }
  }

  _createAnswer() async{
    RTCSessionDescription description = await _peerConnection
      .createAnswer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);
    print(json.encode(session));

    _peerConnection.setLocalDescription(description);

    return json.encode(session);
  }

  void _setCandidate(String jsonString) async{
    dynamic session = await jsonDecode('$jsonString');
    print(session['Candidate']);

    dynamic candidate = new RTCIceCandidate(
      session['candidate'], session['sdpMid'], session['sdpMlineIndex']
    );

    await _peerConnection.addCandidate(candidate);
  }

  void startCall() async {
    
  }

  bool joined = false;

  @override
  Widget build(BuildContext context) {

    // final userData = Provider.of<UserData>(context);
    if(callId != null || widget.callIdProp != null){
      return StreamBuilder<Call>(
      stream: DatabaseService(callId: callId?? widget.callIdProp).callData,
      builder: (context, snapshot) {

        if(snapshot.hasData){
          if(widget.callIdProp == null && snapshot.data.calleeAnswer != null){
          print('didnt recive call id prop & setting remote description ${snapshot.data.calleeAnswer}');
          _setRemoteDescription(snapshot.data.calleeAnswer);
        }

        if(widget.callIdProp != null && snapshot.data.callerOffer != null){
          print('recieve call id & setting remote description ${snapshot.data.callerOffer}');
          _setRemoteDescription(snapshot.data.callerOffer);
        }

        if(snapshot.data.accepted){
          print('received callee ice and setting it ${snapshot.data.calleeIce}');
          _setCandidate(snapshot.data.calleeIce);
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async{
              print(snapshot.data);
              // await DatabaseService(uid: user.uid).updateUserData('newly updated from call');
            },
              child: Icon(Icons.call),
              backgroundColor: Colors.green[600],
          ),
          backgroundColor: Colors.orange[200],
          appBar: AppBar(
              title: Text('Call'),
              backgroundColor: Colors.red[400],
            ),
            body: Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                children: [
                  Flexible(
                    child: RTCVideoView(_localRenderer)
                  ),
                  Text(widget.friend != null ? widget.friend['name'] : ''),
                  Flexible(
                    child: RTCVideoView(_remoteRenderer)
                  )
                ],
              ),
            ),
        );
        }else{
          return Loading();
        }
      }
    );
    }else{
      return Loading();
    }
  }
}