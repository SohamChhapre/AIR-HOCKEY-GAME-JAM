import 'package:air_hockey/AppState.dart';
import 'package:air_hockey/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/logo.png',
            height: 150,
            width: 150,
          ),
          SizedBox(height: 10),
          Text("Welcome to our new experience",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),),
          SizedBox(height:10),
          Text("Choose Player",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              )),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blueAccent)),
                onPressed: () async {
                  print("Player 1");
                  await Provider.of<AppState>(context, listen: false).setPlayer("1");
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>HomeScreen()));
                },
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("PLayer 1".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
              ),
              SizedBox(width: 20),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blueAccent)),
                onPressed: () async{
                  print("Player 2");
                  await Provider.of<AppState>(context, listen: false).setPlayer("2");
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>HomeScreen()));
                },
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Player 2".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
