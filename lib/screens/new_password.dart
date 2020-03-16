import 'package:flutter/material.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class NewPassword extends StatefulWidget 
{
  final String email;

  NewPassword(this.email);

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> 
{
  String email;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() 
  {
    setState(() 
    {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() 
  {
    setState(() 
    {
      _obscureConfirmPassword = !_obscureConfirmPassword;
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

  TextEditingController newpasswordController    = new TextEditingController();

  TextEditingController newpasswordConfirmController    = new TextEditingController();


  bool temp = false;

  bool _isLoading = false;

  var jsonData;

  var response;

  final _formKey = GlobalKey<FormState>();

  setPassword() async
  {
    setState(() 
    {
      _isLoading = true;
    });

    Map data =
    {
      'email'    : email,
      'password' : newpasswordController.text,
    };

    response   = await http.post('http://megabrain-enem.com.br/API/api/auth/resetPassword', body:data);

    jsonData = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {
      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Your Password has been reset successfully. You can now Log In with new Password');

    }
    else
    {

      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Something Went Wrong. Check your internet connectivity and try again.');
    }
  }

  showLoginScreen() async
  {
      await setPassword();

      if(response.statusCode == 200)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)
        {
          return LoginScreen();
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
            builder: (context) => Padding(
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
                      SizedBox(height: 10.0,),
                      Center(
                        child: Text(
                        'Set New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color:Colors.white,
                        fontSize: 20.0,
                        ),
                      ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) 
                        {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter new password';
                                }
                                return null;
                        },
                        obscureText: _obscurePassword,
                        controller: newpasswordController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Enter new password",
                            icon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                                ),
                              onPressed: () 
                              {
                                _togglePasswordVisibility();
                              },
                              ),                        
                            // border:InputBorder.none,
                       ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) 
                        {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter new password again';
                                }
                                return null;
                        },
                        obscureText: _obscureConfirmPassword,
                        controller: newpasswordConfirmController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Enter new password again",
                            icon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                                ),
                              onPressed: () 
                              {
                                _toggleConfirmPasswordVisibility();
                              },
                              ),                        
                            // border:InputBorder.none,
                       ),
                      ),
                      SizedBox(height: 10.0),
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
                                showLoginScreen();
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