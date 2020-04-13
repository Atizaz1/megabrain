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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';

class StateLocation 
{
    int stateCode;
    int countryCode;
    String stateNickname;
    String stateName;

    StateLocation({
        this.stateCode,
        this.countryCode,
        this.stateNickname,
        this.stateName,
    });

    factory StateLocation.fromJson(Map<String, dynamic> json) => StateLocation(
        stateCode: json["state_code"],
        countryCode: json["country_code"],
        stateNickname: json["state_nickname"],
        stateName: json["state_name"],
    );

    Map<String, dynamic> toJson() => {
        "state_code": stateCode,
        "country_code": countryCode,
        "state_nickname": stateNickname,
        "state_name": stateName,
    };
}


class PersonalInformation extends StatefulWidget 
{
  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> 
{

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

  List<String> _suggestionCities;

  bool temp = false;

  List<StateLocation> _states;

  List<DropdownMenuItem<String>> _dropDownMenuStates;

  String _selectedState;

  List _cities;

  List<DropdownMenuItem<String>> _dropDownMenuCities;

  String _selectedCity;

  int _radioValue1 = -1;

  List<StateLocation> stateFromJson(String str) 
  {
    return List<StateLocation>.from(convert.jsonDecode(str).map((x) => StateLocation.fromJson(x)));
  }

  String stateToJson(List<StateLocation> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

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

  String userId;

  SharedPreferences sharedPreferences;

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

  fetchUserData() async
  {
    setState(() 
    {
      _isLoading = true;
    });


    print(sharedPreferences.get('token'));

    String token = sharedPreferences.get('token');

    Map<String,String> authorizationHeaders=
    {
      'Content-Type'  : 'application/json',
      'Accept'        : 'application/json',
      'Authorization' : 'Bearer $token',
    };

    response = await http.post("http://megabrain-enem.com.br/API/api/auth/me",headers: authorizationHeaders);

    jsonData = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _user = jsonData;

      print(_user['userId']);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonData);
                                        
    }
  }

  setUserData()
  {
    emailController.text    = _user['email'];

    nicknameController.text = _user['nickname'];

    fullnameController.text = _user['fullname'];

    var tempDate = DateTime.parse(_user['borndate']);

    bornDateController.text = dateFormatter.format(tempDate);

    courseController.text   = _user['course'];

    if(_user['sex']  == 'Male')
    {
      _handleRadio(0);
    }
    else if(_user['sex']  == 'Female')
    {
      _handleRadio(1);
    }

    if(_user['state'] != null)
    {
      int index = -1;

      for(var i=0; i<_dropDownMenuStates.length; i++ )
      {  
        String mainString = _dropDownMenuStates[i].child.toString();

        String substr = mainString.substring(6,mainString.length-2);
        
        if(substr == _user['state'])
        {
          index = i;
          break;
        }

      }
      
      if(index >= 0)
      {        
        _selectedState = _dropDownMenuStates[index].value;
      }
    }

    if(_user['city'] != null)
    {
      print(_user['city']);

      int index = -1;

      for(var i=0; i<_dropDownMenuCities.length; i++ )
      {  
        String mainString = _dropDownMenuCities[i].child.toString();

        // print(mainString);

        String substr = mainString.substring(6,mainString.length-2);

        print(substr);
        
        if(substr == _user['city'])
        {
          index = i;
          break;
        }

      }
      
      if(index >= 0)
      {        
        _selectedCity = _dropDownMenuCities[index].value;
      }
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
  
  Pattern pattern =
  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  var _user;

  updateUserProfile(String password,String confirm_password,int sex,String course, String borndate) async
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
    
    Map<String,String> data = 
    {
      'userId'                   : _user['userId'].toString(),
      'nickname'                 : nicknameController.text,
      'fullname'                 : fullnameController.text,
      'email'                    : emailController.text,
      'borndate'                 : _borndate,
      'sex'                      : gender,
      'photo'                    : 'null',
      'course'                   : course,
      'state'                    : _selectedState,
      'city'                     : 'null',
    };

    if( (password.isNotEmpty && confirm_password.isNotEmpty) && (password == confirm_password) )
    {
      data['password']              = password;
      data['password_confirmation'] = confirm_password;
    }

    if(_dropDownMenuCities != null)
    {
      data['city'] = _selectedCity;
    }

    if (tmpFile != null)
    { 
      base64Image   = base64Encode(tmpFile.readAsBytesSync());

      fileName      = tmpFile.path.split("/").last;

      data['photo'] = base64Image+','+fileName;
    }

    print(data);

    //print(bornDateController.text);

    String token = sharedPreferences.get('token');

    Map<String,String> authorizationHeaders=
    {
      'Content-Type'  : 'application/x-www-form-urlencoded',
      'Authorization' : 'Bearer $token',
    };

    // data = convert.jsonEncode(data);

    response = await http.post("http://megabrain-enem.com.br/API/api/auth/updateUserProfile", headers: authorizationHeaders,body:data);

    jsonData = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _user = jsonData['user'];

      print(_user['userId']);

      Fluttertoast.showToast(msg: 'You profile has been updated successfully.');

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonData);

      Fluttertoast.showToast(msg: 'Errors have been notified. Please correct the notified errors or check internet connectivity and try again.');
                                        
    }
  }

  static Color fromHex(String hexString) 
  {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  final Color color = fromHex('#754D8B');

  checkLoginStatus() async
  {
    sharedPreferences = await SharedPreferences.getInstance();

    if(sharedPreferences.get('token') == null)
    {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
    }
  }

  @override
  void initState()
  {
    super.initState();
    checkLoginAndFetchDetails();
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

  String _errors;
  
  handleErrors(var json)
  {
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

      var errorList = ['These issues need to be solved to process your request for update of personal information'+'\n'+'\n',_emailErrors,_nicknameErrors,_fullnameErrors,_photoErrors,_passwordErrors,_password_confirmationErrors,_borndateErrors,_courseErrors,_stateErrors,_cityErrors,_sexErrors];
      
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
        if( (_password.isNotEmpty && _confirm_password.isNotEmpty) && (_password == _confirm_password) || (_password.isEmpty && _confirm_password.isEmpty) )
        {
          await updateUserProfile(_password,_confirm_password,_radioValue1, _course, _borndate);
          
          if(response.statusCode  == 200) 
          {
            setUserData();
          }
          else if(response.statusCode == 422)
          {
            await handleErrors(jsonData);

            showErrorMessages();
            
            _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.black87,content: Text('Unable to process. Invalid Information!', style: TextStyle(color: Colors.red,),),),);
          }  
        }
        else
        {
          Fluttertoast.showToast(msg: 'In order to update password. Both password fields needs to have same characters and length.'); 
        }
      }
    }
    else
    {
        if(_radioValue1 < 0)
        {
          Fluttertoast.showToast(msg: 'Please select your gender');
        }

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.black87,content: 
            Text('Unable to process. Incomplete Information!',
            style: TextStyle(color: Colors.red,),
            ),
          ),
        );  
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
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchUserData();
    await fetchStateList();
    // await fetchCityList2();
    await fetchCityList(_user['state']);
    setUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text('Personal Information',
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: Colors.orange,
        actions: <Widget>
        [ 
          PopupMenuButton<int>(
            color: Colors.white,
          itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>
                  [ 
                    Icon(
                      Icons.power,
                      color:Colors.black
                    ),
                    FlatButton(
                      onPressed: ()
                      {
                          sharedPreferences.clear();
                          sharedPreferences.commit();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
                      },
                      child: Text(
                        "LogOut",
                        style: TextStyle(
                          color: Colors.black,
                        ),              
                      ),
                    ),
                  ]
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>
                  [ 
                    Icon(
                      Icons.book,
                      color:Colors.black
                    ),
                    FlatButton(
                      onPressed: ()
                      {
                          
                      },
                      child: Text(
                        "Personal Information",
                        style: TextStyle(
                          color: Colors.black,
                        ),              
                      ),
                    ),
                  ]
                  ),
                ),
              ],
          icon: Icon(Icons.more_vert),
          offset: Offset(0, 100),
        )

        ],
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
                          'Personal Information',
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
                          validator: (value) {
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
                            if(value.length < 8 && value.isNotEmpty)
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
                            if(value.length < 8 && value.isNotEmpty)
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
                                    // subtitle: Text('${suggestion['city_name']}'),
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
                                  'Update Information',
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
    );
  }
}
