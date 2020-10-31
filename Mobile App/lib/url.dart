import 'package:air_hockey/AppState.dart';
import 'package:air_hockey/detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class UrlScreen extends StatefulWidget {
  @override
  _UrlScreenState createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  TextEditingController _controller=new TextEditingController();
  bool isLoading=false;
  @override
  void initState() {
       getUrl();
    super.initState();
  }
  void getUrl()async {
    var temp=await  Provider.of<AppState>(context, listen: false).getUrl();
    setState(() {
      _controller.text=temp;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 150,
              width: 150,
            ),
            SizedBox(height: 10,
            ),
            Text("Please enter displayed URL",style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),),
            SizedBox(height:10),
            Container(
              margin:EdgeInsets.symmetric(horizontal: 40,vertical: 10),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.settings_ethernet,color: Colors.blueAccent),
                  hintText: 'ex: 192.168.1.101',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(16),
                  fillColor: Colors.white,
                ),
              ),
            ),
            isLoading?Container(padding:EdgeInsets.all(5),child: CircularProgressIndicator()):RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blueAccent)),
              onPressed: () async {
                setState(() {
                  isLoading=true;
                });
                print("Connect");
                try {
                  await Provider.of<AppState>(context, listen: false)
                      .openConnection(_controller.text);
                  Future.delayed(const Duration(seconds:1), () {
                    setState(() {
                      isLoading=false;
                    });
                    Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => DetailScreen()));
                  });
                }
                catch(e){
                  _showDialog();
                  setState(() {
                    isLoading=false;
                  });

                }
              },
              color: Colors.white,
              textColor: Colors.blueAccent,
              child: Text("Connect".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Connection Failed"),
          content: new Text("Please enter correct IP address"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
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
