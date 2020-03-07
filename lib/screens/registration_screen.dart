import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:megabrain/screens/verify_email.dart';


class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  
  bool temp = false;

  List _states;

  List<DropdownMenuItem<String>> _dropDownMenuStates;

  String _selectedState;

  List _cities;

  List<DropdownMenuItem<String>> _dropDownMenuCities;

  String _selectedCity;

  int _radioValue1 = -1;

  void _handleRadio(int value) 
  {
    setState(() 
    {
      _radioValue1 = value;
    });
  }

  TextEditingController emailController           = new TextEditingController();

  TextEditingController passwordController        = new TextEditingController();

  TextEditingController confirmPasswordController = new TextEditingController();

  TextEditingController nicknameController        = new TextEditingController();

  TextEditingController fullnameController        = new TextEditingController();

  TextEditingController bornDateController        = new TextEditingController();

  TextEditingController courseController          = new TextEditingController();

  DateTime selectedDate = DateTime.now();

  var dateFormatter = new DateFormat('yyyy-MM-dd');

  bool _isLoading = false;

  var jsonData;

  var response;

  var jsonCityData;

  var cityResponse;

  var jsonStateData;

  var stateResponse;

  Future<File> file;
 
  String base64Image;

  String verifyToken;
 
  File tmpFile;

  List<DropdownMenuItem<String>> buildAndGetStateMenuItems(List _states) 
  {
    List<DropdownMenuItem<String>> items = new List();

    for (dynamic state in _states) 
    {
      print(state);

      items.add(new DropdownMenuItem(value: state['state_name'], child: new Text(state['state_name'])));
    }

    return items;
  }

  void changedDropDownState(String selectedState) 
  {
    setState(() 
    {
      _selectedState = selectedState;
    });

    fetchCityList(selectedState);
  }

  List<DropdownMenuItem<String>> buildAndGetCityMenuItems(List _cities) 
  {
    List<DropdownMenuItem<String>> items = new List();

    for (dynamic city in _cities) 
    {
      print(city);

      items.add(new DropdownMenuItem(value: city['city_name'], child: new Text(city['city_name'])));
    }

    return items;
  }

  void changedDropDownCity(String selectedCity) 
  {
    setState(() 
    {
      _selectedCity = selectedCity;
    });
  }

  fetchStateList() async
  {
    setState(() 
    {
      _isLoading = true;
    });
    // String token = sharedPreferences.get('token');

    // Map<String,String> authorizationHeaders=
    // {
    //   'Content-Type'  : 'application/json',
    //   'Accept'        : 'application/json',
    //   'Authorization' : 'Bearer $token',
    // };

    stateResponse = await http.get("http://megabrain-enem.com.br/API/api/state");

    jsonStateData = convert.jsonDecode(stateResponse.body);

    if(stateResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _states = jsonStateData;

      print(_states);

      _dropDownMenuStates = buildAndGetStateMenuItems(_states);

      _selectedState = _dropDownMenuStates[0].value;

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonStateData);
                                        
    }
  }

  fetchCityList(String stateName) async
  {
    setState(() 
    {
      _isLoading = true;
    });
    // String token = sharedPreferences.get('token');

    // Map<String,String> authorizationHeaders=
    // {
    //   'Content-Type'  : 'application/json',
    //   'Accept'        : 'application/json',
    //   'Authorization' : 'Bearer $token',
    // };

    cityResponse = await http.get("http://megabrain-enem.com.br/API/api/getCitiesListByStateName/$stateName");

    jsonCityData = convert.jsonDecode(cityResponse.body);

    if(cityResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _cities = jsonCityData['cities'];

      print(_cities);

      _dropDownMenuCities = buildAndGetCityMenuItems(_cities);

      _selectedCity = _dropDownMenuCities[0].value;

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonCityData);
                                        
    }
  }

  static final Random _random = Random.secure();

  String createCryptoRandomString([int length = 32]) 
  {
      var values = List<int>.generate(length, (i) => _random.nextInt(256));

      return base64Url.encode(values);
  }
  
  sendMail(receipientEmail) async
  {
    String username = ''; //Sender Email;
    String password = ''; //Sender Email's password;

    final smtpServer = gmail(username, password); 

    //print(verifyToken);
    
    final message = Message()
      ..from = Address(username)
      ..recipients.add(receipientEmail)
      ..subject = 'Verify Account' 
      ..text = 'You have been registered successfully at MegaBrain.\nEmail Verification Code: $verifyToken\nEnter this code in your app to verify your account.\n\n\nDisclaimer: If you did not sign up. You can safely disregard this email.'; 

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
 
  chooseImage() 
  {
    setState(() 
    {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          // base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }


 void fetchDetails() async
 {
    await fetchStateList();
 }

  @override
  void initState() 
  {
    super.initState();
    fetchDetails();
  } 

  Future<Null> _selectDate(BuildContext context) async 
  {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1970, 1),
        lastDate: DateTime(2200));
    if (picked != null && picked != selectedDate)
      setState(() 
      {
        selectedDate = picked;
        bornDateController.text = dateFormatter.format(selectedDate);
      });
  }

  final _formKey = GlobalKey<FormState>();

  var _user;

  register(String email, String password,String confirm_password, String nickname, String fullname,int sex,String course) async
  {
    setState(() 
    {
      _isLoading = true;
    });

    String gender;

    String fileName;  

    if(sex == 0)
    {
      gender = 'Male';
    }
    else if(sex == 1)
    {
      gender = 'Female';
    }
    
    verifyToken = createCryptoRandomString(6);

    Map data = 
    {
      'nickname'                 : nickname,
      'fullname'                 : fullname,
      'email'                    : email,
      'password'                 : password,
      'password_confirmation'    : confirm_password,
      'borndate'                 : bornDateController.text,
      'sex'                      : gender,
      'photo'                    : 'null',
      'course'                   : course,
      'verifyToken'              : verifyToken,
      'isVerify'                 : '0',
      'state'                    : _selectedState,
      'city'                     : 'null',
    };

    if (tmpFile != null)
    { 
      base64Image   = base64Encode(tmpFile.readAsBytesSync());

      fileName      = tmpFile.path.split("/").last;

      data['photo'] = base64Image+','+fileName;
    }

    if(_dropDownMenuCities != null)
    {
      data['city'] = _selectedCity;
    }

    //print(data);

    //print(bornDateController.text);

    response = await http.post("http://megabrain-enem.com.br/API/api/auth/register",body:data);

    jsonData = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      sendMail(emailController.text);

      _user = jsonData['user'];

      print(_user['userId']);

      Fluttertoast.showToast(msg: 'You have registered successfully. Verify your account for use.');

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonData);

      Fluttertoast.showToast(msg: 'Something Went Wrong. Please check your registration details or internet connectivity and try again.');
                                        
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
              child: _isLoading ? Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
              ),
              ) : Container(
                child: Form(
                      key: _formKey,
                      child: ListView(
                    // spacing:4.0, // gap between adjacent chips
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
                        SizedBox(height: 10.0,),
                        Center(
                          child: Text(
                          'REGISTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          color:Colors.white,
                          fontSize: 20.0,
                          ),
                        ),
                        ),
                        SizedBox(height: 35.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter nick name';
                              }
                              return null;
                            },
                          obscureText: false,
                          controller: nicknameController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Nick Name",
                              icon: Icon(Icons.person),                        
                              // border:InputBorder.none,
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter full name';
                              }
                              return null;
                            },
                          controller: fullnameController,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Full Name",
                              icon: Icon(Icons.person),
                              // border:InputBorder.none,
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) 
                              {
                                return 'Please enter valid email';
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
                        SizedBox(height: 15.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Password",
                              icon: Icon(Icons.lock),
                              // border:InputBorder.none,
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter password again';
                              }
                              return null;
                            },
                          obscureText: true,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Confirm Password",
                              icon: Icon(Icons.lock),
                              // border:InputBorder.none,
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter course name';
                              }
                              return null;
                            },
                          obscureText: false,
                          controller: courseController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Please enter course name",
                              icon: Icon(Icons.book),
                              // border:InputBorder.none,
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                              obscureText: false,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter birth date';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  hintText: "Birth Date",
                                  icon: Icon(Icons.date_range),
                            ),
                            controller: bornDateController,
                            onTap: () => _selectDate(context),
                            readOnly: true,
                          ),
                          SizedBox(height:15.0),
                          Center(
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children:<Widget>
                              [
                                Radio(
                                  value: 0, 
                                  groupValue: _radioValue1,
                                  onChanged: _handleRadio,
                                ),
                                Text('Male',
                                  style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 20.0,
                                  ),
                              ),
                              Radio(
                                  value: 1, 
                                  groupValue: _radioValue1,
                                  onChanged: _handleRadio,
                                ),
                                Text('Female',
                                  style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 20.0,
                                  ),
                              ),
                              ]
                            ),
                          ),
                          TextFormField(
                            readOnly: true,
                            obscureText: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  hintText: "Upload Photo",
                                  icon: Icon(Icons.file_upload),
                                  suffixIcon: IconButton(
                                  icon: Icon(Icons.folder_open),
                                  color: Colors.yellow,
                                  onPressed: () 
                                  {
                                    chooseImage();
                                  }
                                  ),
                                  ),
                            ),
                            Center(
                              child:showImage()
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text("Please select a state: "),
                            DropdownButton(
                              value: _selectedState,
                              items: _dropDownMenuStates,
                              onChanged: changedDropDownState,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text("Please select a city: "),
                            DropdownButton(
                              value: _selectedCity,
                              items: _dropDownMenuCities,
                              onChanged: changedDropDownCity,
                            ),
                            Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MaterialButton(
                                onPressed: () 
                                {
                                  if (_formKey.currentState.validate() && _radioValue1 >= 0) 
                                  {

                                     register(emailController.text,passwordController.text,confirmPasswordController.text, courseController.text,nicknameController.text,_radioValue1, fullnameController.text );
                                    _formKey.currentState.save();

                                    _formKey.currentState.reset();
                                    Scaffold.of(context)
                                        .showSnackBar(SnackBar(backgroundColor:Colors.orange[500],
                                        content: Text('Processing. Please Wait!'),
                                        ),
                                        );

                                      Future.delayed(const Duration(milliseconds: 20000), () 
                                      {
                                        
                                        if(response.statusCode == 200)
                                        {
                                          String userId = _user['userId'].toString();
                                          Navigator.push(context, MaterialPageRoute(builder: (context){
                                            return EmailVerify(userId);
                                          }));
                                         
                                         _formKey.currentState.reset();

                                        }
                                        
                                        
                                        // Alert(
                                        //     context: context,
                                        //     style: AlertStyle(
                                        //       backgroundColor: Colors.grey[300],
                                              
                                        //       isCloseButton: false,
                                        //     ),
                                        //     type: AlertType.info,
                                        //     title: "Information",
                                        //     desc: "Please verify your email to confirm your account.",
                                        //     buttons: [
                                        //       DialogButton(
                                        //         child: Text(
                                        //           "RESEND",
                                        //           style: TextStyle(color: Colors.white, fontSize: 20),
                                        //         ),
                                        //         onPressed: ()
                                        //         {
                                        //           Navigator.pop(context);

                                        //           sendMail(emailController.text);
                                                  
                                        //         },
                                        //         color: Colors.orange[500],
                                        //       ),
                                        //       DialogButton(
                                        //         child: Text(
                                        //           "Close",
                                        //           style: TextStyle(color: Colors.white, fontSize: 20),
                                        //         ),
                                        //         onPressed: () => Navigator.pop(context),
                                        //         color: Colors.orange[500],
                                        //       )
                                        //     ],
                                        //   ).show();
                                        

                                      });


                                  
                                  }
                                  else
                                  {
                                    Future.delayed(const Duration(milliseconds: 2500), () 
                                    {
                                      if(_radioValue1 < 0)
                                      {
                                        Fluttertoast.showToast(msg: 'Please select your gender');
                                      }

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
                                minWidth: 150.0,
                                color: Colors.orange[500],
                                height: 42.0,
                                child: Text(
                                  'Save Information',
                                ),
                              ),
                            ),
                          ),
                          
                            // controller: textController,
                            // onTap: () => _selectDate(context),
                      ],
                    ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
