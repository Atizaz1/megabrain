import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/topic_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class AreaScreen extends StatefulWidget 
{
  final subjectCode;

  final subjectName;

  AreaScreen({this.subjectCode, this.subjectName});

  @override
  _AreaScreenState createState() => _AreaScreenState();
}

class Area 
{
    int areaCode;
    int ssCode;
    String areaName;

    Area({
        this.areaCode,
        this.ssCode,
        this.areaName,
    });

    factory Area.fromJson(Map<String, dynamic> json) => Area(
        areaCode: json["area_code"],
        ssCode: json["ss_code"],
        areaName: json["area_name"],
    );

    Map<String, dynamic> toJson() => {
        "area_code": areaCode,
        "ss_code": ssCode,
        "area_name": areaName,
    };
}

class _AreaScreenState extends State<AreaScreen> 
{
  String ss_code;

  String ss_name;

  setSubjectData(dynamic code, dynamic name)
  {
    ss_code = code;
    ss_name = name;
  }

  SharedPreferences sharedPreferences;

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
    setSubjectData(widget.subjectCode, widget.subjectName);
  }
  
  List<Area> areaList;

  bool _isLoading = false;

  var areaResponse;
  
  var jsonAreaData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchAreaList();
  }

  List<Area> areaFromJson(String str) 
  {
    return List<Area>.from(convert.jsonDecode(str).map((x) => Area.fromJson(x)));
  }

  String areaToJson(List<Area> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

  fetchAreaList() async 
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

    print(ss_code);

    areaResponse = await http.get("http://megabrain-enem.com.br/API/api/auth/getAreasListBySubjectCode/$ss_code",headers:authorizationHeaders);

    jsonAreaData = convert.jsonDecode(areaResponse.body);

    if(areaResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      print(jsonAreaData);

      areaList = areaFromJson(areaResponse.body);

      print(areaList.first.areaName);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonAreaData);
                                        
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text(ss_name,
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
              ],
          icon: Icon(Icons.more_vert),
          offset: Offset(0, 100),
        )

        ],
      ),
      // drawer: Drawer(
      //     child: Container(
      //       color: Colors.white,
      //       child: ListView(
      //       padding: EdgeInsets.zero,
      //       children: <Widget>[
      //         DrawerHeader(
      //           child: Text('Drawer Header'),
      //           decoration: BoxDecoration(
      //             image:DecorationImage(
      //               image: AssetImage('images/applogo2.png'),
      //               fit:BoxFit.contain
      //               ),
      //             color: Colors.white,
      //           ),
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/biol.jpg'),
      //           title: Text('Biology',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/chem.jpg'),
      //           title: Text('Chemistry',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/math.jpg'),
      //           title: Text('Maths',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/physics.jpg'),
      //           title: Text('Physics',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/library_add_check.png'),
      //           title: Text('Remember',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/config.png'),
      //           title: Text('Configuration',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //         ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Image.asset('images/news.png',
      //           width: 55.0,),
      //           title: Text('News',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 20.0,
      //           ),
      //           ),
      //           onTap: () {

      //             Navigator.pop(context);
      //           },
      //         ),
      //         Divider(
      //           height: 1.0,
      //           color: Colors.grey,
      //         ),
      //       ],
      //   ),
      //     ),
      // ),
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
                )):GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: 2
                ),
                itemCount: (areaList == null || areaList.length == 0) ? 0 : areaList.length,
                itemBuilder: (context, index) 
                {
                  return GestureDetector(
                    onTap: () 
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return TopicScreen(subjectCode: ss_code,subjectName: ss_name,area_code: areaList[index].areaCode.toString(),area_name: areaList[index].areaName);
                      }));
                    },
                    child:  MenuCard(imageTitle: 'topic_generic' , menuText: areaList[index].areaName 
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
              // SizedBox(height: 5.0),
              // Card(
              // child: Padding(
                
              //   padding: const EdgeInsets.all(15.0),
              //   child: FlatButton(
              //     onPressed: (){
                    
              //     },
              //     padding: EdgeInsets.zero,
              //       child: ListTile(
              //       leading: Image.asset('images/news.png',
              //       width: 200.0,
              //       height: 60.0,
              //       ),
              //       title: Text('NEWS',
              //       style:TextStyle(
              //         fontSize: 15.0,
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //       ),
              //       ),
              //       onTap: (){

              //       },
              //     ),
              //   ),
              // ),
              // color: color,
              // ),
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
        Image.asset('images/$imageTitle.png',
        width: 100.0,
        height: 100.0,
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
