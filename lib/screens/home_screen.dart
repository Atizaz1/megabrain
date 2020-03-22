import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:megabrain/screens/saved_images_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/area_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget 
{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class Subject 
{
    int ssCode;
    String ssName;

    Subject({
        this.ssCode,
        this.ssName,
    });

    factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        ssCode: json["ss_code"],
        ssName: json["ss_name"],
    );

    Map<String, dynamic> toJson() => {
        "ss_code": ssCode,
        "ss_name": ssName,
    };
}

class _HomeScreenState extends State<HomeScreen> 
{
  SharedPreferences sharedPreferences;

  final facebookLogin = FacebookLogin();

  _logout()
  {
    facebookLogin.logOut();
    sharedPreferences.remove('token');
    sharedPreferences.commit();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
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

    print(sharedPreferences.get('token'));

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
  
  List<Subject> subjectList;

  bool _isLoading = false;

  var subjectResponse;
  
  var jsonSubjectData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchSubjectList();
    await fetchUserData();
  }

  List<Subject> subjectFromJson(String str) 
  {
    return List<Subject>.from(convert.jsonDecode(str).map((x) => Subject.fromJson(x)));
  }

  String subjectToJson(List<Subject> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

  var userResponse;

  var userJsonData;

  var _user;

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

    userResponse = await http.post("http://megabrain-enem.com.br/API/api/auth/me",headers: authorizationHeaders);

    userJsonData = convert.jsonDecode(userResponse.body);

    if(userResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      _user = userJsonData;

      sharedPreferences.setInt('logged_in_user_id', _user['userId']);

      print(sharedPreferences.getInt('logged_in_user_id'));

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(userJsonData);
                                        
    }
  }

  fetchSubjectList() async 
  {
    setState(() 
    {
      _isLoading = true;
    });

    String token = await sharedPreferences.get('token');

    Map<String,String> authorizationHeaders=
    {
      'Content-Type'  : 'application/json',
      'Accept'        : 'application/json',
      'Authorization' : 'Bearer $token',
    };

    subjectResponse = await http.get("http://megabrain-enem.com.br/API/api/auth/subjects",headers:authorizationHeaders);

    jsonSubjectData = convert.jsonDecode(subjectResponse.body);

    if(subjectResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      print(jsonSubjectData);

      subjectList = subjectFromJson(subjectResponse.body);

      print(subjectList.first.ssName);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(subjectResponse);
                                        
    }
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
          // FlatButton(
          //   onPressed: ()
          //   {
          //       sharedPreferences.clear();
          //       sharedPreferences.commit();
          //       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
          //   },
          //   child: Text(
          //     "Log Out",
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),              
          //   ),
          // ),
          // FlatButton(
          //   onPressed: ()
          //   {
          //       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
          //   },
          //   child: Text(
          //     "Personal Information",
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),              
          //   ),
          // ),
          
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
                        _logout();
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
                          Navigator.pushNamed(context, 'personal_information');
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
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>
                  [ 
                    Icon(
                      Icons.image,
                      color:Colors.black
                    ),
                    FlatButton(
                      onPressed: ()
                      {
                          Navigator.push(context, MaterialPageRoute(builder: (context) 
                          {
                            return SavedImageScreen();
                          }));
                      },
                      child: Text(
                        "Saved Images",
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
              _isLoading ? 
               Center(child: CircularProgressIndicator(
                  backgroundColor: Colors.orange[500],
                )): 
                Container(
                  height: double.maxFinite,
                  child: ListView.builder(
                    // shrinkWrap: ,
                      itemCount: (subjectList == null || subjectList.length == 0) ? 0 : subjectList.length,
                      itemBuilder: (context, index) 
                      {
                        return GestureDetector(
                          onTap: () 
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return AreaScreen(subjectCode: subjectList[index].ssCode.toString(), subjectName: subjectList[index].ssName,);
                            }));
                          },
                          child: Card(
                            color: Colors.grey[100],
                              child: ListTile(
                                leading: Image.asset(
                            subjectList[index].ssName == 'BIOLOGIA' ? 'images/biol.jpg' : 
                            subjectList[index].ssName == 'FÍSICA' ? 'images/physics.jpg': 
                            subjectList[index].ssName == 'MATEMÁTICA' ? 'images/math.jpg' : 
                            subjectList[index].ssName == 'QUÍMICA' ? 'images/chem.jpg' : 'images/course_generic.png' 
                                ),
                              title: Text(
                                subjectList[index].ssName,
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                              // trailing: Icon(Icons.keyboard_arrow_right,
                              // color:Colors.black
                              // ),
                            ),
                          ),
                        );
                      }, 
                      // separatorBuilder: (BuildContext context, int index) 
                      // {
                      //     return Divider();
                      // }, 
                      
                    // Container(
                    // height: double.maxFinite,
                    // child:GridView.builder(
                    // shrinkWrap: true,
                    // gridDelegate:
                    // SliverGridDelegateWithFixedCrossAxisCount(
                    //                    crossAxisCount: 1
                    // ),
                    // itemCount: (subjectList == null || subjectList.length == 0) ? 0 : subjectList.length,
                    // itemBuilder: (context, index) 
                    // {
                    //   return GestureDetector(
                    //     onTap: () 
                    //     {
                    //       print("tapped");
                    //       Navigator.push(context, MaterialPageRoute(builder: (context) 
                    //       {
                    //         return AreaScreen(subjectCode: subjectList[index].ssCode.toString(), subjectName: subjectList[index].ssName,);
                    //       }));
                    //     },
                    //     child: 
                    //         MenuCard(imageTitle: 
                            // subjectList[index].ssName == 'BIOLOGIA' ? 'biol' : 
                            // subjectList[index].ssName == 'FÍSICA' ? 'physics': 
                            // subjectList[index].ssName == 'MATEMÁTICA' ? 'math' : 
                            // subjectList[index].ssName == 'QUÍMICA' ? 'chem' : 'course_generic' , 
                    //         menuText: subjectList[index].ssName 
                    //         ),
                    //   );
                    // }, ),
              ),
                ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/biol.jpg'),
              //   title: Text('Biology',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/chem.jpg'),
              //   title: Text('Chemistry',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/math.jpg'),
              //   title: Text('Maths',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/physics.jpg'),
              //   title: Text('Physics',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/library_add_check.png'),
              //   title: Text('Remember',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/config.png'),
              //   title: Text('Configuration',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Image.asset('images/news.png',
              //   width: 55.0,),
              //   title: Text('News',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20.0,
              //   ),
              //   ),
              //   onTap: () {

              //     Navigator.pop(context);
              //   },
              // ),
              // Divider(
              //   height: 1.0,
              //   color: Colors.grey,
              // ),
            ],
        ),
          ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height / 1,
        color: Colors.grey[300],
        child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Wrap(
              children:<Widget>[ 
              Card(
              child: ListTile(
                leading: Image.asset('images/applogo2.png',
                width: 60.0,
                height: 60.0,
                ),
                title: Text('MegaBrain ENEM',
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                ),
                onTap: (){

                },
              ),
              color: Colors.orange[500],
              ),
              Container(
                color: Colors.grey[350],
                child: _isLoading ? Center(child: CircularProgressIndicator(
                  backgroundColor: Colors.orange[500],
                )): GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: 2
                ),
                itemCount: (subjectList == null || subjectList.length == 0) ? 0 : subjectList.length,
                itemBuilder: (context, index) 
                {
                  return GestureDetector(
                    onTap: () 
                    {
                      print("tapped");
                      Navigator.push(context, MaterialPageRoute(builder: (context) 
                      {
                        return AreaScreen(subjectCode: subjectList[index].ssCode.toString(), subjectName: subjectList[index].ssName,);
                      }));
                    },
                    child: 
                        MenuCard(imageTitle: 
                        subjectList[index].ssName == 'BIOLOGIA' ? 'biol' : 
                        subjectList[index].ssName == 'FÍSICA' ? 'physics': 
                        subjectList[index].ssName == 'MATEMÁTICA' ? 'math' : 
                        subjectList[index].ssName == 'QUÍMICA' ? 'chem' : 'course_generic' , 
                        menuText: subjectList[index].ssName 
                        ),
                  );
                }, ),
                
              // GridView.count(
              //   shrinkWrap: true,
              //   childAspectRatio: 1.3,
              //   padding: EdgeInsets.symmetric(vertical:16.0),
              //   crossAxisCount: 2,
              //   children: <Widget>
              //   [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/biol.jpg',
              //         // width: 500.0,
              //         // height: 300.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Biology',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //   ],
              // ),
              //     // Container(
              //     //   child: IconButton(
              //     //       icon:Image.asset('images/biol.jpg',
              //     //       width: 300.0,
              //     //       height: 200.0,
              //     //       ) ,
              //     //       iconSize: 25.0,
              //     //       onPressed: (){

              //     //       },
              //     //     ),
              //     // ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/chem.jpg',
              //         // width: 300.0,
              //         // height: 200.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Chemistry',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //     // Container(
              //     //   child: IconButton(
              //     //     icon:Image.asset('images/chem.jpg',
              //     //     width: 300.0,
              //     //     height: 200.0,
              //     //     ) ,
              //     //     iconSize: 25.0,
              //     //     onPressed: (){

              //     //     },
              //     //   ),
              //     // ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/math.jpg',
              //         // width: 300.0,
              //         // height: 200.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Math',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //     // Container(
              //     //   child: IconButton(
              //     //     icon:Image.asset('images/math.jpg',
              //     //      width: 300.0,
              //     //     height: 200.0,
              //     //     ) ,
              //     //     onPressed: (){

              //     //     },
              //     //   ),
              //     // ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/physics.jpg',
              //         // width: 300.0,
              //         // height: 200.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Physics',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //     // Container(
              //     //   child: IconButton(
              //     //     icon:Image.asset('images/physics.jpg',
              //     //      width: 300.0,
              //     //     height: 200.0,
              //     //     ) ,
              //     //     iconSize: 25.0,
              //     //     onPressed: (){

              //     //     },
              //     //   ),
              //     // ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/library_add_check.png',
              //         // width: 300.0,
              //         // height: 200.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Library',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //     // Container(
              //     //   child: Container(
              //     //     child: IconButton(
              //     //       icon:Image.asset('images/library_add_check.png',
              //     //       width: 300.0,
              //     //       height: 200.0,
              //     //       ),
              //     //       iconSize: 25.0,

              //     //       onPressed: (){

              //     //       },
              //     //     ),
              //     //   ),
              //     // ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisSize: MainAxisSize.min,
              //       verticalDirection: VerticalDirection.down,
              //       children: <Widget>[
              //         IconButton(
              //         icon:Image.asset('images/config.png',
              //         // width: 300.0,
              //         // height: 200.0,
              //         ) ,
              //         iconSize: 100.0,
              //         onPressed: (){

              //         },
              //       ),
              //         Center(
              //           child: Text('Configuration',
              //           style: TextStyle(
              //             color:Colors.black,
              //             fontSize: 15.0,
              //           ),),
              //         )
              //       ],
              //     ),
              //     // Container(
              //       // child: IconButton(
              //       //   icon:Image.asset('images/config.png',
              //       //   width: 300.0,
              //       //   height: 200.0,
              //       //   ) ,
              //       //   iconSize: 25.0,
              //       //   onPressed: (){

              //       //   },
              //       // ),
              //     // ),
              //   ],  
              //   ),
              ),
              SizedBox(height: 5.0),
              Card(
              child: Padding(
                
                padding: const EdgeInsets.all(15.0),
                child: FlatButton(
                  onPressed: (){
                    
                  },
                  padding: EdgeInsets.zero,
                    child: ListTile(
                    leading: Image.asset('images/news.png',
                    width: 200.0,
                    height: 60.0,
                    ),
                    title: Text('NEWS',
                    style:TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    onTap: (){

                    },
                  ),
                ),
              ),
              color: color,
              ),
              ],
            ),
          ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget 
{
  const MenuCard({@required this.imageTitle, @required this.menuText});

  final String imageTitle;

  final String menuText;

  @override
  Widget build(BuildContext context) 
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
                  child: Image.asset(
          imageTitle != 'course_generic' ? 'images/$imageTitle.jpg' : 'images/$imageTitle.png',
          width: 180.0,
          height: 180.0,
      ),
        ),
        Center(
          child: Text(menuText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:Colors.black,
            fontSize: 15.0,
          ),
          ),
        )
      ],
    );
  }
}
