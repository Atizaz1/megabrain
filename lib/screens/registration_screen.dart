import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mailer2/mailer.dart';
import 'dart:math';
import 'package:megabrain/screens/verify_email.dart';
import 'package:megabrain/main.dart';


class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class StateLocation 
{
    int stateCode;
    int countryCode;
    String stateNickname;
    String stateName;

    StateLocation
    ({
        this.stateCode,
        this.countryCode,
        this.stateNickname,
        this.stateName,
    });

    factory StateLocation.fromJson(Map<String, dynamic> json) => StateLocation
    (
        stateCode: json["state_code"],
        countryCode: json["country_code"],
        stateNickname: json["state_nickname"],
        stateName: json["state_name"],
    );

    Map<String, dynamic> toJson() => 
    {
        "state_code": stateCode,
        "country_code": countryCode,
        "state_nickname": stateNickname,
        "state_name": stateName,
    };
}

class RandomDigits {
  static const MaxNumericDigits = 17;
  static final _random = Random();

  static int getInteger(int digitCount) {
    if (digitCount > MaxNumericDigits || digitCount < 1) throw new RangeError.range(0, 1, MaxNumericDigits, "Digit Count");
    var digit = _random.nextInt(9) + 1;  // first digit must not be a zero
    int n = digit;

    for (var i = 0; i < digitCount - 1; i++) {
      digit = _random.nextInt(10);
      n *= 10;
      n += digit;
    }
    return n;
  }

  static String getString(int digitCount) {
    String s = "";
    for (var i = 0; i < digitCount; i++) {
      s += _random.nextInt(10).toString();
    }
    return s;
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {

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

  List<String> getSuggestions(String query) 
  {
    List<String> matches = List();

    matches.addAll(_suggestionCities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));

    return matches;
  }
  
  bool temp = false;

  List<StateLocation> _states;

  List<DropdownMenuItem<String>> _dropDownMenuStates;

  String _selectedState;

  List _cities;

  List<String> _suggestionCities;

  List<DropdownMenuItem<String>> _dropDownMenuCities;

  List<StateLocation> stateFromJson(String str) 
  {
    return List<StateLocation>.from(convert.jsonDecode(str).map((x) => StateLocation.fromJson(x)));
  }

  String stateToJson(List<StateLocation> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

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

  TextEditingController _typeAheadController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  var dateFormatter = new DateFormat('dd-MM-yyyy');

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

  List<DropdownMenuItem<String>> buildAndGetStateMenuItems(List<StateLocation> _states) 
  {
    List<DropdownMenuItem<String>> items = new List();

    for (var i = 0; i < _states.length ; i++) 
    {
      items.add(new DropdownMenuItem(value: _states[i].stateName, child: new Text(_states[i].stateName)));
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

    _suggestionCities = new List<String>();

    for (dynamic city in _cities) 
    {
      print(city);

      _suggestionCities.add(city['city_name']);

      items.add(new DropdownMenuItem(value: city['city_name'], child: new Text(city['city_name'])));
    }

    print(_suggestionCities);

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

      _states = stateFromJson(stateResponse.body);

      print(_states.first.stateName);

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

      _cities = jsonCityData;

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

  fetchCityList2() async
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

    String stateCode = 1.toString();

    cityResponse = await http.get("http://megabrain-enem.com.br/API/api/getCitiesListByStateCode/$stateCode");

    jsonCityData = convert.jsonDecode(cityResponse.body);

    if(cityResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _cities = jsonCityData;

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
  
  bool _isMailSent = false;

  sendMail(receipientEmail) async
  {
    String username = 'nao-responda@megabrain-enem.com.br'; 
    String password = 'Pmpartner7871';   

    //final smtpServer = gmail(username, password); 

    //print(verifyToken);
    
    // final message = Message()
    //   ..from = Address(username)
    //   ..recipients.add(receipientEmail)
    //   ..subject = 'Verify Account' 
    //   ..text = 'You have been registered successfully at MegaBrain.\nEmail Verification Code: $verifyToken\nEnter this code in your app to verify your account.\n\n\nDisclaimer: If you did not sign up. You can safely disregard this email.'; 

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
    ..subject = 'Verify Account'
    ..text = 'You have been registered successfully at MegaBrain.\nEmail Verification Code: $verifyToken\nEnter this code in your app to verify your account.\n\n\nDisclaimer: If you did not sign up. You can safely disregard this email.'; 

    Fluttertoast.showToast(msg: 'Processing your registration Request. Please Wait');

    await transport.send(envelope)
    .then((_)
    {
      print('email sent!');

      _isMailSent = true;

    })
    .catchError((e) 
    { 
      print('Error: $e');

      Fluttertoast.showToast(msg: 'Registration Email could not be send. $e');
      
      _isMailSent = false;

    });
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
    await fetchCityList2();
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
        print(bornDateController.text);
      });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _user;

  var _emailErrors;

  var _nicknameErrors;

  var _fullnameErrors;

  var _passwordErrors;

  var _password_confirmationErrors;

  var _borndateErrors;

  var _sexErrors;

  var _photoErrors;

  var _stateErrors;

  var _cityErrors;

  var _tokenErrors;

  var _courseErrors;

  String _email, _password, _confirm_password, _nickname, _fullname, _course, _borndate;

  int _sex;

  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  register(_password, _confirm_password, _course, _sex, _borndate) async
  {
    setState(() 
    {
      _isLoading = true;
    });

    String gender;

    String fileName;  

    if(_sex == 0)
    {
      gender = 'Male';
    }
    else if(_sex == 1)
    {
      gender = 'Female';
    }
    
    // verifyToken = createCryptoRandomString(6);
    verifyToken = RandomDigits.getInteger(4).toString();

    Map data = 
    {
      'nickname'                 : nicknameController.text,
      'fullname'                 : fullnameController.text,
      'email'                    : emailController.text,
      'password'                 : _password,
      'password_confirmation'    : _confirm_password,
      'borndate'                 : _borndate,
      'sex'                      : gender,
      'photo'                    : 'null',
      'course'                   : _course,
      'verifyToken'              : verifyToken,
      'isVerify'                 : '0',
      'state'                    : _selectedState,
      'city'                     : 'null',
    };

    print(data);

    if (tmpFile != null)
    { 
      base64Image   = base64Encode(tmpFile.readAsBytesSync());

      fileName      = tmpFile.path.split("/").last;

      data['photo'] = base64Image+','+fileName;

      print(_nickname);

      print(_fullname);

      print(_email);
    }

    if(_dropDownMenuCities != null)
    {
      data['city'] = _selectedCity;
    }

    print(data);

    print(bornDateController.text);

    response = await http.post("http://megabrain-enem.com.br/API/api/auth/register",body:data);

    // jsonData = convert.jsonDecode(response.body);

    // if(response.statusCode == 200)
    // {

    //   setState(() 
    //   {
    //     _isLoading = false;
    //   });

    //   if(_errors == null)
    //   {
    //     print("no errors");

    //     await sendMail(emailController.text);

    //     _user = jsonData['user'];

    //     print(_user['userId']);

    //     Fluttertoast.showToast(msg: 'You have registered successfully. Verify your account for use.');
    //   }
    //   else
    //   {
    //     Fluttertoast.showToast(msg: 'Errors have been notified. Please correct the notified errors or check internet connectivity and try again.');
    //   }

    // }
    // else
    // {
    //   setState(()
    //   {
    //     _isLoading = false;
    //   });
      
    //   print(jsonData);

    //   Fluttertoast.showToast(msg: 'Errors have been notified. Please correct the notified errors or check internet connectivity and try again.');
                                        
    // }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _errors;
  
  handleErrors(var json)
  {
    _errors = null;
    if(json['errors'] != null)
    {
      if(json['errors']['email'] != null)
      {
        for(dynamic emailError in json['errors']['email'])
        {
          _emailErrors = emailError+'\n';
          // print(_emailErrors);
        }
      }
      if(json['errors']['nickname'] != null)
      {
        for(dynamic nickError in json['errors']['nickname'])
        {
           _nicknameErrors = nickError+'\n';
          // print(_nicknameErrors);
        }
      }
      if(json['errors']['fullname'] != null)
      {
        for(dynamic fullnameError in json['errors']['fullname'])
        {
           _fullnameErrors = fullnameError+'\n';
          // print(_fullnameErrors);
        }
      }
      if(json['errors']['password'] != null)
      {
        for(dynamic passwordError in json['errors']['password'])
        {
           _passwordErrors = passwordError+'\n';
          // print(_passwordErrors);
        }
      }
      if(json['errors']['password_confirmation'] != null)
      {
        for(dynamic confirmpasswordError in json['errors']['password_confirmation'])
        {
           _password_confirmationErrors = confirmpasswordError+'\n';
          // print(_password_confirmationErrors);
        }
      }
      if(json['errors']['borndate'] != null)
      {
        for(dynamic dobError in json['errors']['borndate'])
        {
           _borndateErrors = dobError+'\n';
          // print(_borndateErrors);
        }
      }
      if(json['errors']['course'] != null)
      {
        for(dynamic courseError in json['errors']['course'])
        {
           _courseErrors = courseError+'\n';
          // print(_courseErrors);
        }
      }
      if(json['errors']['state'] != null)
      {
        for(dynamic stateError in json['errors']['state'])
        {
           _stateErrors = stateError+'\n';
          // print(_stateErrors);
        }
      }
      if(json['errors']['city'] != null)
      {
        for(dynamic cityError in json['errors']['city'])
        {
           _cityErrors = cityError+'\n';
          // print(_cityErrors);
        }
      }
      if(json['errors']['sex'] != null)
      {
        for(dynamic sexError in json['errors']['sex'])
        {
           _sexErrors = sexError+'\n';
          // print(_sexErrors);
        }
      }
      if(json['errors']['photo'] != null)
      {
        for(dynamic photoError in json['errors']['photo'])
        {
           _photoErrors = photoError+'\n';
          // print(_photoErrors);
        }
      }

      // String _errors = '$_emailErrors$_nicknameErrors$_fullnameErrors$_photoErrors$_passwordErrors$_password_confirmationErrors$_borndateErrors$_courseErrors$_stateErrors$_cityErrors$_sexErrors';

      var errorList = ['These issues need to be solved to process your registration'+'\n'+'\n',_emailErrors,_nicknameErrors,_fullnameErrors,_photoErrors,_passwordErrors,_password_confirmationErrors,_borndateErrors,_courseErrors,_stateErrors,_cityErrors,_sexErrors];
      
      var _temp = StringBuffer();
      
      errorList.forEach((item)
      {
        if(item != null)
        {
          _temp.write(item);
        }

      });

      _errors = _temp.toString();

      print(_errors);

    }
  }

   void showErrorMessages() 
   {
    showDialog(
    context: context,
    builder: (BuildContext context) 
    {
      return AlertDialog(
        title: Text(_errors !=null ? 'Errors' : 'Information'),
        content: Text(_errors !=null ? _errors:'Registration Success'),
        actions: <Widget>[
          RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
      
    });
  }

  void formSubmit() async
  {
    final form = _formKey.currentState;

    if (form.validate() && _radioValue1 >= 0) 
    {
      form.save();

      RegExp regex = new RegExp(pattern);

      if(fullnameController.text.isEmpty)
      {
        Fluttertoast.showToast(msg:  'Please enter full name');
      }
      else if(fullnameController.text.length < 3)
      {
        Fluttertoast.showToast(msg:  'Full Name can not be short than 3 characters minimum');
      }
      else if(nicknameController.text.isEmpty)
      {
        Fluttertoast.showToast(msg:  'Please enter nick name');
      }
      else if(nicknameController.text.length < 3)
      {
        Fluttertoast.showToast(msg:  'Nick Name can not be short than 3 characters minimum');
      }
      else if(emailController.text.isEmpty)
      {
        Fluttertoast.showToast(msg:  'Please enter email address');
      }
      else if(!regex.hasMatch(emailController.text) )
      {
        Fluttertoast.showToast(msg:  'Please enter valid email address');
      }
      else
      {
        
        _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:Colors.orange[500], content: Text('Processing. Please Wait!'),),);

        await register(_password, _confirm_password, _course, _radioValue1, _borndate);

        jsonData = convert.jsonDecode(response.body);

        if(response.statusCode  == 200) 
        {
          setState(() 
          {
            _isLoading = false;
          });

          await sendMail(emailController.text);

          _user = jsonData['user'];

          print(_user['userId']);

          Fluttertoast.showToast(msg: 'You have registered successfully. Verify your account for use.');
          
          String userId = _user['userId'].toString();
          
          Navigator.push(context, MaterialPageRoute(builder: (context)
          {
            return EmailVerify(userId);
          }));

        }
        else if(response.statusCode == 422 || response.statusCode != 200)
        {
          setState(()
          {
            _isLoading = false;
          });
            
          print(jsonData);

          Fluttertoast.showToast(msg: 'Errors have been notified. Please correct the notified errors or check internet connectivity and try again.');

          await handleErrors(jsonData);

          showErrorMessages();

          if(_radioValue1 < 0)
          {
            Fluttertoast.showToast(msg: 'Please select your gender');
          }

          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.black87,content: Text('Unable to process. Incomplete Information!', style: TextStyle(color: Colors.red,),),),);
        }
      }
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
          key: _scaffoldKey,
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
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please enter nick name';
                              }
                              else if(value.length < 3)
                              {
                                return 'Nick Name can not be short than 3 characters minimum';
                              }
                              else
                                return null;
                          },
                          obscureText: false,
                          onSaved: (value)
                          {
                             _nickname = value;
                          },
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
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please enter full name';
                              }
                              else if(value.length < 3)
                              {
                                return 'Full Name can not be short than 3 characters minimum';
                              }
                              else
                                return null;
                          },
                          controller: fullnameController,
                          onSaved: (value)
                          {
                             _fullname = value;
                          },
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
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value)
                          {
                             _email = value;
                          },
                          validator: (value) 
                          {
                            RegExp regex = new RegExp(pattern);
                            if (!regex.hasMatch(value) )
                            {
                              return 'Please Enter Valid Email';
                            }
                            else if(value.isEmpty)
                            {
                              return 'Email Cannot be Blank';
                            }
                            else
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
                          onSaved: (value)
                          {
                             _password = value;
                          },
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please enter password';
                              }
                              else if(value.length < 8)
                              {
                                return 'Password Length cannot be less than 8 Characters';
                              }
                              else
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
                        SizedBox(height: 15.0),
                        TextFormField(
                          onSaved: (value){
                             _confirm_password = value;
                          },
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please enter password again';
                              }
                              else if(value.length < 8)
                              {
                                return 'Confirm Password Length cannot be less than 8 Characters';
                              }
                              else
                                return null;
                          },
                          obscureText: _obscureConfirmPassword,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Confirm Password",
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
                        SizedBox(height: 15.0),
                        TextFormField(
                          onSaved: (value){
                             _course = value;
                          },
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please enter course name';
                              }
                              else if(value.length < 3)
                              {
                                return 'Coure Name cannot be less than 3 Characters';
                              }
                              else
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
                              onSaved: (value)
                              {
                                _borndate = value;
                              },
                              validator: (value) 
                              {
                                if (value.isEmpty) 
                                {
                                  return 'Please enter birth date';
                                }
                                else
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
                          TextField(
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
                                    FocusScope.of(context).unfocus(focusPrevious: true);
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
                            Text("Please Select a State: "),
                            DropdownButton(
                              value: _selectedState,
                              items: _dropDownMenuStates,
                              onChanged: changedDropDownState,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text("Please Select a City: "),
                              TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _typeAheadController,
                                ),
                                loadingBuilder: (BuildContext context)
                                {
                                  return Text('Loading... ');
                                },
                                suggestionsCallback: (pattern)
                                {
                                  return getSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) 
                                {
                                  return ListTile(
                                    leading: Icon(Icons.location_city),
                                    title: Text(suggestion),
                                    // subtitle: Text('${suggestion}'),
                                  );
                                },
                                onSuggestionSelected: (suggestion) 
                                {
                                  _typeAheadController.text = suggestion;

                                  int index = -1;

                                  for(var i = 0; i < _dropDownMenuCities.length ; i++)
                                  {
                                    print(_dropDownMenuCities[i].value);
                                    if(_dropDownMenuCities[i].value == suggestion)
                                    {
                                      index = i;
                                      break;
                                    }
                                  }
                                  if(index >= 0)
                                  {
                                    setState(() 
                                    {
                                      _selectedCity = _dropDownMenuCities[index].value;
                                    });
                                  }
                                  else
                                  {
                                    setState(() 
                                    {
                                      _selectedCity = _dropDownMenuCities[0].value;
                                    });
                                  }


                                },
                              ),
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
                                  formSubmit();
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
