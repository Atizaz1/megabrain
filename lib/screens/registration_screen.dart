import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  
  bool temp = false;

  int _radioValue1 = -1;

  void _handleRadio(int value) 
  {
    setState(() 
    {
      _radioValue1 = value;
    });
  }

  var textController = new TextEditingController();

  DateTime selectedDate = DateTime.now();

  var dateFormatter = new DateFormat('yyyy-MM-dd');

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() 
      {
        selectedDate = picked;
        textController.text = dateFormatter.format(selectedDate);
      });
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
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              child: Wrap(
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
                    SizedBox(height: 15.0,),
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
                    SizedBox(height: 45.0),
                    TextFormField(
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Nick Name",
                          icon: Icon(Icons.person),                        
                          // border:InputBorder.none,
                     ),
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Full Name",
                          icon: Icon(Icons.person),
                          // border:InputBorder.none,
                     ),
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Email",
                          icon: Icon(Icons.email),
                          // border:InputBorder.none,
                     ),
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Password",
                          icon: Icon(Icons.lock),
                          // border:InputBorder.none,
                     ),
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Confirm Password",
                          icon: Icon(Icons.lock),
                          // border:InputBorder.none,
                     ),
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Birth Date",
                              icon: Icon(Icons.date_range),
                        ),
                        controller: textController,
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
                              onPressed: () {
                                // debugPrint('222');
                              }
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
    );
  }
}
