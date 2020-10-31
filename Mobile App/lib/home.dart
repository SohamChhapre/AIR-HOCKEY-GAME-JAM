import 'dart:async';
import 'package:air_hockey/AppState.dart';
import 'package:air_hockey/detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _value = 0;
  int _start = 30;
  bool isActive = true;
  Timer _timer;




  void startTimer() {
    setState(() {
      isActive=false;
    });
    const oneSec = const Duration(seconds: 1);
    if (_timer != null) {
      _timer.cancel();
      _start = 30;
    }
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            isActive=true;
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.blueAccent,
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Disappear".toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5
                    ),),
                    SizedBox(height: 15),
                    isActive
                        ? SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: FloatingActionButton(
                              heroTag: "B",
                              child: Icon(
                                Icons.fiber_manual_record,
                                size: 40,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Provider.of<AppState>(context, listen: false)
                                    .sendButtonData();
                                startTimer();
                              },
                            ),
                          )
                        : SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: FloatingActionButton(
                                heroTag: "A",
                                child: Icon(
                                  Icons.fiber_manual_record,
                                  size: 40,
                                  color: Colors.red[100],
                                ),
                                onPressed: null),
                          ),
                    Opacity(
                      opacity: isActive ? 0 : 1,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: Text("$_start s",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    )
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo.png',
                      height: 250,
                      width: 250,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blueAccent)),
                      onPressed: () {
                        print("Change Player");
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => DetailScreen()));
                      },
                      color: Colors.white,
                      textColor: Colors.blueAccent,
                      child: Text("Change Player".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blueAccent)),
                      onPressed: () async {
                        print("Reconnect");
                        try {
                          await Provider.of<AppState>(context, listen: false)
                              .reopenConnection();
                        } catch (e) {
                          _showDialog();
                        }
                      },
                      color: Colors.white,
                      textColor: Colors.blueAccent,
                      child: Text("Reconnect".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        inactiveTrackColor: Colors.white24,
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 12.0,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 20.0),
                        overlayColor: Colors.white.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 40.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 10,
                        activeColor: Colors.white,
                        value: _value,
                        onChangeEnd: (value) {
//                          print('End');
                          Provider.of<AppState>(context, listen: false)
                              .sendSliderMessage("Stop");
                        },
                        onChangeStart: (value) {
//                          print('Start');
                          Provider.of<AppState>(context, listen: false)
                              .sendSliderMessage("Start");
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _value = newValue;
                          });
                          Provider.of<AppState>(context, listen: false)
                              .sendSliderData(newValue);
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
   @override
  void dispose() {
    super.dispose();
  }
  @override
  void deactivate() {
    Wakelock.disable();
    Provider.of<AppState>(context, listen: false).stopSubscription();
    if(_timer!=null)
       _timer.cancel();
    // TODO: implement deactivate
    super.deactivate();
  }
  @override
  void initState() {
    Wakelock.enable();
    Provider.of<AppState>(context, listen: false).sendSensorData();
    super.initState();
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Connection Failed"),
          content: new Text("Connection was broken please Reconnect"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
