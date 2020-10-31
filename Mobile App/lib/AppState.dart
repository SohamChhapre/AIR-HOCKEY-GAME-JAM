import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_socket_channel/io.dart';

class AppState {
  String _player = "1";
  String _url = "";
  String _port = "7310";
  String xAngle = "0.0", yAngle = "0.0", angles = "";
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  IOWebSocketChannel _accelerometerChannel, _sliderChannel, _buttonChannel;

  Future<void> setPlayer(String number) {
    _player = number;
    return null;
  }

  get getPlayer {
    return _player;
  }

  IOWebSocketChannel getAccelerationChannel() {
    return _accelerometerChannel;
  }

  IOWebSocketChannel getSliderChannel() {
    return _sliderChannel;
  }

  IOWebSocketChannel getButtonChannel() {
    return _buttonChannel;
  }

  Future<String> getUrl() async {
    print("Shared preference url get");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('url');
    if (stringValue != null) _url = stringValue;
    return _url;
  }

  Future<void> setUrl(String url) async {
    _url = url;
    print("Shared preference url set");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('url', url);
  }

  Future<IOWebSocketChannel> createSocket(String url)async {
    // ignore: close_sinks
    final socket = await WebSocket.connect(url).timeout(Duration(seconds: 1));
    return IOWebSocketChannel(socket);
  }

  Future<void> openConnection(String url) async {
    await setUrl(url);
    try {
      _accelerometerChannel = await createSocket("ws://" + url + ":" + _port + "/accelerometer");
      _sliderChannel = await createSocket("ws://" + url + ":" + _port + "/slider");
      _buttonChannel = await createSocket("ws://" + url + ":" + _port + "/button");
    }catch(e){
      throw Exception();
    }
    return null;
  }

  Future<void> reopenConnection() {
    stopSubscription();
    closeConnection();
    openConnection(_url);
    sendSensorData();
    return null;
  }

  void closeConnection() {
    _accelerometerChannel.sink.close();
    _buttonChannel.sink.close();
    _sliderChannel.sink.close();
    return null;
  }

  void sendSensorData() {
    _streamSubscriptions.add(AeyriumSensor.sensorEvents.listen((event) {
      double xInclination = -(event.pitch * (180 / math.pi));
      double yInclination = (event.roll * (180 / math.pi));
      xAngle = "${xInclination.round()}";
      yAngle = "${yInclination.round()}";
      angles = xAngle + "," + yAngle;
      if (_accelerometerChannel != null) {
        _accelerometerChannel.sink.add("$_player:$angles");
      }
    }));
  }

  void sendSliderMessage(String message) {
    if (_sliderChannel != null) {
      _sliderChannel.sink.add("$_player:$message");
    }
  }

  void sendSliderData(double value) {
    if (_sliderChannel != null) {
      _sliderChannel.sink.add("$_player: $value");
    }
  }

  void sendButtonData() {
    if (_buttonChannel != null) {
      _buttonChannel.sink.add("$_player: 1");
    }
  }

  void stopSubscription() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
