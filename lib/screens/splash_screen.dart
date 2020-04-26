import 'dart:async';

import 'package:flutter/material.dart';
import 'package:megabrain/screens/welcome_screen.dart';
 
 class SplashScreen extends StatefulWidget 
 {
    @override                         
    State<StatefulWidget> createState() 
    {
      return SplashState();
    }
  }

class SplashState extends State<SplashScreen> 
{

  startTime() async 
  {
    var duration = new Duration(seconds: 6);
    return new Timer(duration, route);
  }

  @override
  void initState() 
  {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: initScreen(context),
    );
  }

  route() 
  {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => WelcomeScreen()
      )
    ); 
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset("images/applogo.png"),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Text(
              "Mega Brain ENEM",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 1,
           )
         ],
       ),
      ),
    );
  }
}