import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool temp = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/loginbackground.jpg"), fit:BoxFit.cover
                ),
              ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, 
                children: <Widget>[
                  Center(
                    child: Image.asset(
                        "images/applogo.png",
                        height: 150.0,
                    ),
                  ),
                  Center(
                    child: Text(
                    'MegaBrain ENEM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color:Colors.orange[500],
                    fontSize: 30.0,
                    ),
                  ),
                  ),
                  SizedBox(height: 15.0,),
                  Center(
                    child: Text(
                    'LOG IN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color:Colors.white,
                    fontSize: 20.0,
                    ),
                  ),
                  ),
                  SizedBox(height: 45.0),
                  TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Email",
                        icon: Icon(Icons.email),                        
                        // border:InputBorder.none,
                   ),
                  ),
                  SizedBox(height: 25.0),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Password",
                        icon: Icon(Icons.lock),
                        // border:InputBorder.none,
                   ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    // margin: EdgeInsets.only(right:50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Checkbox(
                            value: temp,
                            onChanged: (bool newValue) {
                              setState(() {
                                temp = newValue;
                              });
                            },
                          ),
                        Text('Remember Me?',
                        style: TextStyle(
                    color:Colors.white,
                    fontSize: 20.0,
                    ),),
                    FlatButton(child:Text('Forgot Password',
                        style: TextStyle(
                    color:Colors.white,
                    fontSize: 15.0,
                    ),
                    ),
                    onPressed: (){},
                    )
                      ],
                    ),
                  ),
            SizedBox(height:15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  
                       MaterialButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'home_screen');
                        }, 
                        color: Colors.orange[500],
                        minWidth: 150.0,
                        height: 42.0,
                        child: Text(
                          'Log In',
                        ),
                  ),
                        MaterialButton(
                          onPressed: () {
                            
                          },
                          minWidth: 150.0,
                          color: Colors.blue[500],
                          height: 42.0,
                          child: Text(
                            'Social Login',
                          ),
                        ),
                    ]
                  ),
                  Center(

                    child: FlatButton(
                       child:Text('Don\'t have an account! Register',
                       style: TextStyle(
                       color:Colors.white,
                       fontSize: 17.5,
                    ),
                    ),
                    onPressed: (){},
                    ),
                  ),
                ],
              ),
          ),
        ),
    );
  }
}
