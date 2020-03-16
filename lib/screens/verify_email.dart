import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class EmailVerify extends StatefulWidget 
{
  final id;

  EmailVerify(this.id);

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> 
{
  bool _obscureVerificationCode = true;

  void _toggleVerificationCodeVisibility() 
  {
    setState(() 
    {
      _obscureVerificationCode = !_obscureVerificationCode;
    });
  }
  String userId;

  @override
  void initState()
  {
    super.initState();

    setUserId(widget.id);
  }

  setUserId(dynamic id)
  {
    userId = id;
  }

  TextEditingController emailVerificationController    = new TextEditingController();

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
      'id'    : userId,
      'token' : emailVerificationController.text,
    };

    response   = await http.post('http://megabrain-enem.com.br/API/api/auth/verifyToken', body:data);

    jsonData = convert.jsonDecode(response.body);

    print(data);

    if(response.statusCode == 200)
    {
      setState(() 
      {
        _isLoading = false;
      });

      print(jsonData);

      Fluttertoast.showToast(msg: 'Your Account has been verfied successfully. You can now Log In');

    }
    else
    {

      print(jsonData);

      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Something Went Wrong. Check your verification code and internet connectivity and try again.');
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
              padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                        'Account Verification',
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
                                  return 'Please enter email verification code';
                                }
                                return null;
                        },
                        obscureText: _obscureVerificationCode,
                        controller: emailVerificationController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Email Verification Code",
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
                                sendToken();
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
                              'Verify Account',
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