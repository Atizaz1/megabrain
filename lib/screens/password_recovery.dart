import 'package:flutter/material.dart';
import 'package:megabrain/screens/password_reset.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class PasswordVerify extends StatefulWidget 
{
  // final id;

  // PasswordVerify(this.id);

  @override
  _PasswordVerifyState createState() => _PasswordVerifyState();
}

class _PasswordVerifyState extends State<PasswordVerify> 
{
  // String userId;

  @override
  void initState()
  {
    super.initState();

    // setUserId(widget.id);
  }

  // setUserId(dynamic id)
  // {
  //   userId = id;
  // }

  TextEditingController emailController    = new TextEditingController();

  bool temp = false;

  bool _isLoading = false;

  var jsonData;

  var response;

  final _formKey = GlobalKey<FormState>();

  getToken() async
  {
    setState(() 
    {
      _isLoading = true;
    });

    Map data =
    {
      'email' : emailController.text,
    };

    response   = await http.post('http://megabrain-enem.com.br/API/api/auth/passwordResetInit', body:data);

    jsonData = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {
      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Your Password Reset verification code has been sent successfully.');

    }
    else
    {

      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Something Went Wrong. Check your email address and internet connectivity and try again.');
    }
  }

  sendMail(receipientEmail) async
  {
    String username  = 'atizaz.ahmad07@gmail.com'; //Sender Email;
    String password  = 'AaZ_D6590'; //Sender Email's password;

    final smtpServer = gmail(username, password); 

    String token     = jsonData['token'];

    print(token);
    
    final message = Message()
      ..from = Address(username)
      ..recipients.add(receipientEmail)
      ..subject = 'Verify Account' 
      ..text = 'We have received Password Reset Request for your account.\nEmail Verification Code: $token\nEnter this code in your app to reset your account password.\n\n\nDisclaimer: If you did not initiate password recovery process. You can safely disregard this email.'; 

    try 
    {
      final sendReport = await send(message, smtpServer);

      print('Message sent: ' + sendReport.toString()); 
    } 
    on MailerException catch (e) 
    {
      print('Message not sent. \n'+ e.toString()); 
    }
  }

  showVerificationScreen() async
  {
      await getToken();

      await sendMail(emailController.text);

      Navigator.push(context, MaterialPageRoute(builder: (context)
      {
          return PasswordCodeVerify(emailController.text);

      }));
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
                        'Password Recovery',
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
                                  return 'Please enter your email address';
                                }
                                return null;
                        },
                        obscureText: false,
                        controller: emailController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Email Address",
                            icon: Icon(Icons.email),                        
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
                                showVerificationScreen();
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
                              'Recover Password',
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