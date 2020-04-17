import 'package:flutter/material.dart';
import 'package:megabrain/screens/password_reset.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer2/mailer.dart';


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

      Fluttertoast.showToast(msg: 'Password Reset Process Initiated Successfully. Please wait.');

    }
    else
    {

      setState(() 
      {
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'We are having trouble with Password Reset Process Initiation. Please try again or check you internet connectivity or email address.');

      if(response.statusCode == 422)
      {
        Fluttertoast.showToast(msg: 'Looks like there is not user associated with the email address you provided. Check your email address try again.');
      }

      if(response.statusCode == 500)
      {
        Fluttertoast.showToast(msg: 'Looks like server is down. Please try again after sometime.');
      }
    }
  }

  bool _isMailSent = false;

  sendMail(receipientEmail) async
  {
    String username = 'nao-responda@megabrain-enem.com.br'; 
    String password = 'Pmpartner7871'; 

    // final smtpServer = gmail(username, password); 

    String token     = jsonData['token'].toString();

    print(token);
    
    // final message = Message()
    //   ..from = Address(username)
    //   ..recipients.add(receipientEmail)
    //   ..subject = 'Verify Account' 
    //   ..text = 'We have received Password Reset Request for your account.\nEmail Verification Code: $token\nEnter this code in your app to reset your account password.\n\n\nDisclaimer: If you did not initiate password recovery process. You can safely disregard this email.'; 

    // try 
    // {
    //   final sendReport = await send(message, smtpServer);

    //   print('Message sent: ' + sendReport.toString()); 
    // } 
    // on MailerException catch (e) 
    // {
    //   print('Message not sent. \n'+ e.toString()); 
    // }

    var options = new SmtpOptions()
    ..hostName  = 'smtpi.kinghost.net'
    ..port      = 587
    ..username  = username
    ..password  = password;
  

    var transport = new SmtpTransport(options);

    var envelope = new Envelope()
    ..from = username
    ..fromName = 'MegaBrain ENEM'
    ..recipients = [receipientEmail]
    ..subject = 'Password Recovery'
    // ..text = 'We have received Password Reset Request for your account.\nPassword Recovery Verification Code: $token\nEnter this code in your app to reset your account password.\n\n\nDisclaimer: If you did not initiate password recovery process. You can safely disregard this email.'
    ..html ='''<!DOCTYPE html>
<html>
<head>

  <meta charset="utf-8">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>Password Recover</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
  /**
   * Google webfonts. Recommended to include the .woff version for cross-client compatibility.
   */
  @media screen {
    @font-face {
      font-family: 'Source Sans Pro';
      font-style: normal;
      font-weight: 400;
      src: local('Source Sans Pro Regular'), local('SourceSansPro-Regular'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlBM0YzuT7MdOe03otPbuUS0.woff) format('woff');
    }

    @font-face {
      font-family: 'Source Sans Pro';
      font-style: normal;
      font-weight: 700;
      src: local('Source Sans Pro Bold'), local('SourceSansPro-Bold'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/toadOcfmlt9b38dHJxOBGFkQc6VGVFSmCnC_l7QZG60.woff) format('woff');
    }
  }

  /**
   * Avoid browser level font resizing.
   * 1. Windows Mobile
   * 2. iOS / OSX
   */
  body,
  table,
  td,
  a {
    -ms-text-size-adjust: 100%; /* 1 */
    -webkit-text-size-adjust: 100%; /* 2 */
  }

  /**
   * Remove extra space added to tables and cells in Outlook.
   */
  table,
  td {
    mso-table-rspace: 0pt;
    mso-table-lspace: 0pt;
  }

  /**
   * Better fluid images in Internet Explorer.
   */
  img {
    -ms-interpolation-mode: bicubic;
  }

  /**
   * Remove blue links for iOS devices.
   */
  a[x-apple-data-detectors] {
    font-family: inherit !important;
    font-size: inherit !important;
    font-weight: inherit !important;
    line-height: inherit !important;
    color: inherit !important;
    text-decoration: none !important;
  }

  /**
   * Fix centering issues in Android 4.4.
   */
  div[style*="margin: 16px 0;"] {
    margin: 0 !important;
  }

  body {
    width: 100% !important;
    height: 100% !important;
    padding: 0 !important;
    margin: 0 !important;
  }

  /**
   * Collapse table borders to avoid space between cells.
   */
  table {
    border-collapse: collapse !important;
  }

  a {
    color: #1a82e2;
  }

  img {
    height: auto;
    line-height: 100%;
    text-decoration: none;
    border: 0;
    outline: none;
  }
  </style>

</head>
<body style="background-color: #e9ecef;">

  <!-- start preheader -->
  <div class="preheader" style="display: none; max-width: 0; max-height: 0; overflow: hidden; font-size: 1px; line-height: 1px; color: #fff; opacity: 0;">
    Recover Password
  </div>
  <!-- end preheader -->

  <!-- start body -->
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <!-- start logo -->
    <tr>
      <td align="center" bgcolor="#e9ecef">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
          <tr>
            <td align="center" valign="top" style="padding: 10px 10px;">
              <a href="http://www.megabrain-enem.com.br" target="_blank" style="display: inline-block;">
                <img src="http://www.megabrain-enem.com.br/logo_megaBrain-ENEM.png" alt="Logo" border="0" width="68" style="display: block; width: 68px; max-width: 68px; min-width: 68px;">
              </a>
            </td>
          </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end logo -->

    <!-- start hero -->
    <tr>
      <td align="center" bgcolor="#e9ecef">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
          <tr>
            <td align="left" bgcolor="#ffffff" style="padding: 10px 10px 0; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; border-top: 3px solid #d4dadf;">
              <h1 style="margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -1px; line-height: 48px;">Reset Your Password</h1>
            </td>
          </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end hero -->

    <!-- start copy block -->
    <tr>
      <td align="center" bgcolor="#e9ecef">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">

          <!-- start copy -->
          <tr>
            <td align="left" bgcolor="#ffffff" style="padding: 10px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
              <p style="margin: 0;">We have received Password Reset Request for your account.<br>
Password Recovery Verification Code below.<br>
Enter this code in your app to reset your account password.</p>
            </td>
          </tr>
          <!-- end copy -->

          <!-- start button -->
          <tr>
            <td align="left" bgcolor="#ffffff">
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td align="left" bgcolor="#ffffff" style="padding: 10px;">
                    <table border="0" cellpadding="0" cellspacing="0">
                      <tr>
                        <td align="left" bgcolor="#1a82e2" style="border-radius: 6px;">
                          <text  style="display: inline-block; padding: 6px 26px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 24px; color: #ffffff; text-decoration: none; border-radius: 6px;"><b>$token</b></text>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- end button -->

          <!-- start copy -->
          <tr>
            <td align="left" bgcolor="#ffffff" style="padding: 10px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 20px; border-bottom: 3px solid #d4dadf">
              <p style="margin: 0;"><b>MegaBrain ENEM</b> Team</p>
            </td>
          </tr>
          <!-- end copy -->

        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end copy block -->

    <!-- start footer -->
    <tr>
      <td align="center" bgcolor="#e9ecef" style="padding: 5px;">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">

          <!-- start permission -->
          <tr>
            <td align="center" bgcolor="#e9ecef" style="padding: 6px 6px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 14px; line-height: 20px; color: #666;">
              <p style="margin: 0;">MegaBrain ENEM - Biologia | Física | Matemática | Química</p>
Disclaimer: If you did not initiate password recovery process. You can safely disregard this email.
            </td>
          </tr>
          <!-- end permission -->
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end footer -->

  </table>
  <!-- end body -->

</body>
</html>''';

    await transport.send(envelope)
    .then((_){
      
      print('email sent!');

      setState(()
      {
         _isMailSent = true;
      });

    })
    .catchError((e) 
    { 
      print('Error: $e');
      
      setState(()
      {
         _isMailSent = false;
      });

    });
  }

  sendPasswordVerificationDetails() async
  {
      await getToken();

      await sendMail(emailController.text);

      notifyStatus();
  }

  notifyStatus()
  {
    if(response.statusCode == 200 && _isMailSent)
    {
      Navigator.push(context, MaterialPageRoute(builder: (context)
      {
          return PasswordCodeVerify(emailController.text);
      }));
    }
    else if(! _isMailSent)
    {
      Fluttertoast.showToast(msg: 'We are having trouble sending you password recovery email. Please try again');
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
                  child: ListView(
                  // spacing: 8.0, // gap between adjacent chips
                  // runSpacing: 1.0, 
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) 
                        {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter your email address';
                                }
                                else
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
                      SizedBox(height: 65.0),
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
                                sendPasswordVerificationDetails();
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