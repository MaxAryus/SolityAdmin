import 'dart:convert';

import 'package:SolityAdmin/tabController.dart';
import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class CallScreeb extends StatefulWidget {
  CallScreeb({
    this.roomID,
    this.usernames,
    this.eventID,
  });

  final roomID;
  final eventID;
  final List<String> usernames;
  @override
  _CallScreebState createState() => _CallScreebState();
}

class _CallScreebState extends State<CallScreeb> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  bool videoDisabled = false;

  final usersUID = <int>[];
  final usersInfo = [];
  var username;

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initializeAgora();
  }

  @override
  void dispose() {
    // clear users

    // _engine.destroy();
    super.dispose();
  }

  Future<void> initializeAgora() async {
    // if (APP_ID.isEmpty) {
    //   setState(() {
    //     _infoStrings.add(
    //       'APP_ID missing, please provide your APP_ID in settings.dart',
    //     );
    //     _infoStrings.add('Agora Engine is not starting');
    //   });
    //   return;
    // }

    await _initAgoraRtcEngine();

    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    // await _engine.joinChannel(null, widget.roomID.toString(), 'null', 0);
    var _prefs = await SharedPreferences.getInstance();
    username = _prefs.getString('firstname');
    await _engine.joinChannelWithUserAccount(null, widget.roomID, username);
    removeUserFromEvent(widget.eventID);
  }

  //  Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create('78ea2b8d8d2e479a8a2fd3cd485f1b27');
    _engine.enableVideo();
    // _engine.enableLocalVideo(true);
    _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    _engine.setClientRole(ClientRole.Broadcaster);
    _engine.enableWebSdkInteroperability(true);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
          if (code == ErrorCode.StartCamera) {
            setState(() {
              _engine.leaveChannel();
              _onCallEnd(context);
            });
          }
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          usersInfo.clear();
          usersUID.clear();

          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) async {
        setState(() {
          final info = 'userJoined: $uid';
          // this.muted = true;
          // _engine.enableVideo();
          // _engine.enableLocalVideo(true);
          // _engine.enableLocalVideo(false);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          usersUID.remove(uid);
          for (int i = 0; i < usersUID.length; i++) {
            if (usersUID[i] == uid) {
              usersInfo.removeAt(i);
            }
          }
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
        });
      },
      userInfoUpdated: (uid, userInfo) {
        setState(() {
          usersUID.add(userInfo.uid);
          usersInfo.add(userInfo.userAccount);
        });
      },
      localVideoStateChanged: (localVideoState, error) {
        // print('object');
        // print(localVideoState);
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (ClientRole.Broadcaster == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }

    usersUID.forEach((int uid) {
      list.add(RtcRemoteView.SurfaceView(uid: uid));
    });
    return list;
  }

  _getUsernames() {
    List<String> names = [];
    usersInfo.forEach((name) {
      names.add(name);
    });
    return names;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(
        child: Container(
      child: view,
      color: Colors.black,
    ));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views, String name) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
        child: Stack(
      children: [
        Row(
          children: wrappedViews,
        ),
        // SafeArea(
        // child:
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            alignment: Alignment.bottomLeft,
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        // ),
      ],
    ));
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    final _usernames = _getUsernames();

    switch (views.length) {
      case 1:
        return Container(
            color: Colors.amberAccent,
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]], username),
            _expandedVideoRow([views[1]], _usernames[0]),
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]], username),
            _expandedVideoRow([views[1]], _usernames[0]),
            _expandedVideoRow([views[2]], _usernames[1]),
          ],
        );

      case 4:
        return Column(
          children: [
            _expandedVideoRow([views[0]], username),
            _expandedVideoRow([views[1]], _usernames[0]),
            _expandedVideoRow([views[2]], _usernames[1]),
            _expandedVideoRow([views[3]], _usernames[2]),
          ],
        );
      default:
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.green,
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return null;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    // if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _showAlertDialog(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  _showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text(
        "Ja",
      ),
      onPressed: () async {
        _users.clear();
        usersInfo.clear();
        usersUID.clear();
        // destroy sdk
        usersInfo.clear();
        usersUID.clear();
        await _engine.leaveChannel();
        await _onCallEnd(context);
      },
    );

    Widget abbruchButton = FlatButton(
      child: Text("Abbrechen"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Achtung!"),
      content: Text(
        "Sie sind dabei das Event zu verlassen, nach dem verlassen ist es nicht mehr möglich beizurteten! \nWollen Sie das Evetn wirklich verlassen?",
      ),
      actions: [
        okButton,
        abbruchButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _onCallEnd(BuildContext context) async {
    var id = widget.eventID;

    http.Response response =
        await http.post('https://api.go-omi.com/deleteEvent', headers: {
      'Accept': 'application/json',
    }, body: {
      'id': '$id',
    });

    Navigator.pushReplacement(
      context,
      new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new HomeController(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }

  Future removeUserFromEvent(id) async {
    final prefs = await SharedPreferences.getInstance();

    var token = prefs.get('token');

    http.Response request =
        await http.post('https://api.go-omi.com/signOutFromEvent', headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'id': '$id',
    });
    print(request.body);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
