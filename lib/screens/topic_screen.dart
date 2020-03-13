import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'image_screen.dart';

class TopicScreen extends StatefulWidget 
{
  final subjectCode;

  final subjectName;

  final area_code;

  final area_name;

  TopicScreen({this.subjectCode, this.subjectName, this.area_code, this.area_name});

  @override
  _TopicScreenState createState() => _TopicScreenState();
}

class Topic 
{
    int topicCode;
    int ssCode;
    int areaCode;
    String topicName;
    dynamic observation;

    Topic({
        this.topicCode,
        this.ssCode,
        this.areaCode,
        this.topicName,
        this.observation,
    });

    factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        topicCode: json["topic_code"],
        ssCode: json["ss_code"],
        areaCode: json["area_code"],
        topicName: json["topic_name"],
        observation: json["observation"],
    );

    Map<String, dynamic> toJson() => {
        "topic_code": topicCode,
        "ss_code": ssCode,
        "area_code": areaCode,
        "topic_name": topicName,
        "observation": observation,
    };
}

class _TopicScreenState extends State<TopicScreen> 
{
  String ss_code;

  String ss_name;

  String area_code;

  String area_name;

  setSubjectAndAreaData(dynamic s_code, dynamic s_name, dynamic a_code, dynamic a_name)
  {
    ss_code   = s_code;

    ss_name   = s_name;
    
    area_code = a_code;

    area_name = a_name;
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
    setSubjectAndAreaData(widget.subjectCode, widget.subjectName, widget.area_code, widget.area_name);
  }
  
  List<Topic> topicList;

  bool _isLoading = false;

  var topicResponse;
  
  var jsonTopicData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchTopicList();
  }

  List<Topic> topicFromJson(String str) 
  {
    return List<Topic>.from(convert.jsonDecode(str).map((x) => Topic.fromJson(x)));
  }

  String topicToJson(List<Topic> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

  fetchTopicList() async 
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

    topicResponse = await http.get("http://megabrain-enem.com.br/API/api/auth/getTopicBySubjectAndAreaCodes/$ss_code/$area_code",headers:authorizationHeaders);

    jsonTopicData = convert.jsonDecode(topicResponse.body);

    if(topicResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      print(jsonTopicData);

      topicList = topicFromJson(topicResponse.body);

      print(topicList.first.topicName);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonTopicData);
                                        
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text(ss_name+'-'+area_name,
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
                itemCount: (topicList == null || topicList.length == 0) ? 0 : topicList.length,
                itemBuilder: (context, index) 
                {
                  return GestureDetector(
                    onTap: () 
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) 
                      {
                        return ImageScreen(subjectCode: ss_code,subjectName: ss_name,area_code: area_code,area_name: area_name, topic_code: topicList[index].topicCode.toString(),topic_name: topicList[index].topicName);
                      }));
                    },
                    child:MenuCard(imageTitle: 'topic_generic' , menuText: topicList[index].topicName 
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
          icon:Image.asset('images/$imageTitle.png',
          // width: 500.0,
          // height: 300.0,
          ) ,
          iconSize: 100.0,
          onPressed: (){

          },
        ),
          Center(
            child: Text(menuText,
            style: TextStyle(
              color:Colors.black,
              fontSize: 15.0,
            ),
            ),
          )
        ],
      ),
    );
  }
}
