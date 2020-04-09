import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/home_screen.dart';


class LoginScreen extends StatefulWidget 
{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  bool _obscurePassword = true;

  void _togglePasswordVisibility() 
  {
    setState(() 
    {
      _obscurePassword = !_obscurePassword;
    });
  }

  TextEditingController emailController    = new TextEditingController();

  TextEditingController passwordController = new TextEditingController();

  bool temp = false;

  bool _isLoading = false;

  var jsonData;

  var response;

  bool _isLoggedIn = false;

  Map userProfile;

  final facebookLogin = FacebookLogin();

  final _formKey = GlobalKey<FormState>();

  _loginWithFB() async
  {

    final result = await facebookLogin.logInWithReadPermissions(['email']);

    switch (result.status) 
    {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = convert.jsonDecode(graphResponse.body);
        print(profile);
        setState(() 
        {
          userProfile = profile;
          _isLoggedIn = true;
        });
        getToken(profile);
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLoggedIn = false );
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLoggedIn = false );
        break;
    }

  }

  SharedPreferences sharedPreferences;

  void initState()
  {
    super.initState();
    setRememberedDetail();
  }

  Future<bool> rememberMe(String email) async
  {
    if(email != null)
    {
      return sharedPreferences.setString('user_email', email);
    }
  }

  void setRememberedDetail() async
  {
    sharedPreferences = await SharedPreferences.getInstance();

    String userEmail = sharedPreferences.getString('user_email');

    if(userEmail != null)
    {
      emailController.text = userEmail;
    }
  }

  getToken(Map data) async
  {
    setState(() 
    {
      _isLoading = true;
    });

    Map socialData = 
    {
      'email'    : data['email'].toString(),
      'id'       : data['id'].toString(),
      'name'     : data['name'].toString(),
    };

    response = await http.post("http://megabrain-enem.com.br/API/api/socialSignUp",body:socialData);

    if(response.statusCode == 200)
    {
      jsonData = convert.jsonDecode(response.body);
      setState(() 
      {
        _isLoading = false;
        sharedPreferences.setString("token", jsonData['access_token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => HomeScreen()), (Route<dynamic> route) => false);
      });
    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Looks Like We\'re having trouble signing you up using facebook. Please Try Again or check your internet connectivity.');
      
      print(response.body);
    }
  }

  signIn(String email, String password) async
  {
    if(temp == true)
    {
      await rememberMe(email);
      print(sharedPreferences.get('user_email'));
    }

    setState(() 
    {
      _isLoading = true;
    });
    Map data = 
    {
      'email'    : email,
      'password' : password,
    };

    response = await http.post("http://megabrain-enem.com.br/API/api/auth/login",body:data);

    if(response.statusCode == 200)
    {
      jsonData = convert.jsonDecode(response.body);
      setState(() 
      {
        _isLoading = false;
        sharedPreferences.setString("token", jsonData['access_token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => HomeScreen()), (Route<dynamic> route) => false);
      });
    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Looks Like the entered Email or Password is invalid Or your account is Inactive.');
      
      print(response.body);
    }
  }

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
          body: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLoading ? 
              Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
              ),
              ) 
              : Form(
                key: _formKey,
                  child: ListView(
                  // spacing: 8.0, // gap between adjacent chips
                  // runSpacing: 4.0, 
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                            "images/applogo.png",
                            height: 120.0,
                        ),
                      ),
                      Center(
                        child: Text(
                        'MegaBrain ENEM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color:Colors.orange[500],
                        fontSize: 25.0,
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
                      SizedBox(height: 25.0),
                      TextFormField(
                        validator: (value) 
                        {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter email';
                                }
                                return null;
                        },
                        obscureText: false,
                        controller: emailController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Email",
                            icon: Icon(Icons.email),                        
                            // border:InputBorder.none,
                       ),
                      ),
                      SizedBox(height: 25.0),
                      TextFormField(
                        validator: (value) {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                        obscureText: _obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Password",
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
                                onChanged: (bool newValue) 
                                {
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
                        onPressed: ()
                        {
                          Navigator.pushNamed(context, 'password_recovery');
                        },
                        )
                          ],
                        ),
                      ),
                SizedBox(height:15.0),
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
                              

                                    Alert(
                                context: context,
                                style: AlertStyle(
                                  backgroundColor: Colors.grey[300],
                                  
                                  isCloseButton: false,
                                ),
                                type: AlertType.info,
                                title: "LOG In",
                                desc: "Are You Sure You Want to Log In.",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "YES",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: ()
                                    {
                                      
                                      Navigator.pop(context);

                                      Scaffold.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                        backgroundColor:Colors.orange[500], content: Text('Processing. Please Wait!'),
                                        ),
                                        );
                                        
                                      signIn(emailController.text, passwordController.text);

                                      

                                     
                                    },
                                    color: Colors.orange[500],
                                  ),
                                  DialogButton(
                                    child: Text(
                                      "NO",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: ()
                                    {
                                      setState(() 
                                      {
                                          _isLoading = false;
                                      });

                                      Navigator.pop(context);
                                      // Navigator.pushNamed(context,"home_screen");
                                    },
                                    color: Colors.orange[500],
                                  )
                                ],
                              ).show();

                            }
                            else
                            {
                              
                              // Navigator.pushNamed(context,"home_screen");
                              Future.delayed(const Duration(milliseconds: 2500), () 
                              {

                                setState(() 
                                {
                                    _isLoading = false;
                                });

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
                              'Log In',
                            ),
                      ),
                            MaterialButton(
                              onPressed: () 
                              {
                                _loginWithFB();
                              },
                              minWidth: 150.0,
                              color: Colors.blue[500],
                              height: 42.0,
                              child: Text(
                                  'Facebook Login',
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
                        onPressed: (){
                          Navigator.pushNamed(context, 'registration_screen');
                        },
                        ),
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
