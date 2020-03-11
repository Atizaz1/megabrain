import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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



class PersonalInformation extends StatefulWidget 
{
  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> 
{

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

    bornDateController.text = _user['borndate'];

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

  updateUserProfile(String email, String password,String confirm_password, String nickname, String fullname,int sex,String course) async
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
      'nickname'                 : nickname,
      'fullname'                 : fullname,
      'email'                    : email,
      'password'                 : 'null',
      'password_confirmation'    : 'null',
      'borndate'                 : bornDateController.text,
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

    //print(data);

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

      Fluttertoast.showToast(msg: 'Something Went Wrong. Please check your profile details or internet connectivity and try again.');
                                        
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
  

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchUserData();
    await fetchStateList();
    setUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text('Home',
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
      drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  image:DecorationImage(
                    image: AssetImage('images/applogo2.png'),
                    fit:BoxFit.contain
                    ),
                  color: Colors.white,
                ),
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/biol.jpg'),
                title: Text('Biology',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/chem.jpg'),
                title: Text('Chemistry',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/math.jpg'),
                title: Text('Maths',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/physics.jpg'),
                title: Text('Physics',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/library_add_check.png'),
                title: Text('Remember',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/config.png'),
                title: Text('Configuration',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/news.png',
                width: 55.0,),
                title: Text('News',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            ],
        ),
          ),
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
                                  if (_formKey.currentState.validate() && _radioValue1 >= 0 && passwordController.text == confirmPasswordController.text
                                  && passwordController.text.length >=8 && confirmPasswordController.text.length>=8 && _dropDownMenuCities !=null) 
                                  {

                                     updateUserProfile(emailController.text,passwordController.text,confirmPasswordController.text, nicknameController.text,fullnameController.text,_radioValue1, courseController.text );

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
                                          
                                         
                                         //_formKey.currentState.reset();

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

                                      if(passwordController.text != confirmPasswordController.text)
                                      {
                                        Fluttertoast.showToast(msg: 'Password and confirm password fields do not match. Please try Again.');
                                      }

                                      if(passwordController.text.length < 8 || confirmPasswordController.text.length < 8)
                                      {
                                        Fluttertoast.showToast(msg: 'Minimum length criteria for password and confirm password is not achieved. Please try again.');
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
    );
  }
}
