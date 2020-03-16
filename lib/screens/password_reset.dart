import 'package:flutter/material.dart';
import 'package:megabrain/screens/new_password.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class PasswordCodeVerify extends StatefulWidget 
{
  final String email;

  PasswordCodeVerify(this.email);

  @override
  _PasswordCodeVerifyState createState() => _PasswordCodeVerifyState();
}

class _PasswordCodeVerifyState extends State<PasswordCodeVerify> 
{
  String email;

  bool _obscureVerificationCode = true;

  void _toggleVerificationCodeVisibility() 
  {
    setState(() 
    {
      _obscureVerificationCode = !_obscureVerificationCode;
    });
  }

  @override
  void initState()
  {
    super.initState();

    setUserEmail(widget.email);
  }

  setUserEmail(dynamic email)
  {
    this.email = email;
  }

  TextEditingController passwordCodeController    = new TextEditingController();

  bool temp = false;

  bool _isLoading = false;

  var jsonData;

  var response;

  final _formKey = GlobalKey<FormState>();

  sendToken() async
  {
    setState(() 
    {
      _isLoading = true;
    });

    Map data =
    {
      'email'         : email,
      'token'         : passwordCodeController.text,
    };

    response   = await http.post('http://megabrain-enem.com.br/API/api/auth/verifyPasswordToken', body:data);

    jsonData = convert.jsonDecode(response.body);

    print(passwordCodeController.text);

    print(email);

    print(jsonData);

    if(response.statusCode == 200)
    {
      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Your Password Reset Security Code has been matched successfully. You can now Choose new Password for your account');

    }
    else
    {

      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Something Went Wrong. Check your verification code and internet connectivity and try again.');
    }
  }

  showPasswordResetScreen() async
  {
      await sendToken();

      if(response.statusCode == 200)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)
        {
            return NewPassword(email);

        }));
      }
  }

  @override
  Widget build(BuildContext context) 
  {
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
          body: Builder(
            builder: (context) => _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Form(
                key: _formKey,
                  child: Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 1.0, 
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
                        'Password Reset Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color:Colors.white,
                        fontSize: 20.0,
                        ),
                      ),
                      ),
                      SizedBox(height: 45.0),
                      TextFormField(
                        validator: (value) 
                        {
                            if (value.isEmpty) 
                            {
                              return 'Please enter password reset verification code';
                            }
                            return null;
                        },
                        obscureText: _obscureVerificationCode,
                        controller: passwordCodeController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Password Reset Verification Code",
                            icon: Icon(Icons.lock), 
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureVerificationCode
                                ? Icons.visibility_off
                                : Icons.visibility,
                                ),
                              onPressed: () 
                              {
                                _toggleVerificationCodeVisibility();
                              },
                          ),                       
                            // border:InputBorder.none,
                       ),
                      ),
                      SizedBox(height: 25.0),
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                      
                           MaterialButton(
                            onPressed: () 
                            {

                              setState(() 
                              {
                                  _isLoading = true;
                              });
                           

                            if (_formKey.currentState.validate()) 
                            {
                                showPasswordResetScreen();
                            }
                            else
                            {
                              
                              // Navigator.pushNamed(context,"home_screen");
                              Future.delayed(const Duration(milliseconds: 2500), () 
                              {

                                Scaffold.of(context)
                                  .showSnackBar(SnackBar(
                                    backgroundColor: Colors.black87,
                                    
                                    content: 
                                    Text('Unable to process. Incomplete Information!',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),),
                                    ),
                                    );

                              });

                              
                            }
                              
                            }, 
                            color: Colors.orange[500],
                            minWidth: 150.0,
                            height: 42.0,
                            child: Text(
                              'Password Reset Verify',
                            ),
                      ),
                        ]
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ),
    );
  }
}