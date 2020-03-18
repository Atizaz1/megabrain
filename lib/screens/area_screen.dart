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
        title: Text('$ss_name  Areas',
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
      body: Container(
        height: MediaQuery.of(context).size.height / 1,
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
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
            Expanded(
                          child: Container(
                  child: _isLoading ? Center(child: CircularProgressIndicator(
                    backgroundColor: Colors.orange[500],
                  )):ListView.separated(
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
                      child: Card(
                        color: Colors.grey[300],
                          child: ListTile(
                          title: Text(
                            areaList[index].areaName,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right,
                          color:Colors.black
                          ),
                        ),
                      ),
                    );
                  }, separatorBuilder: (BuildContext context, int index) 
                  {
                      return Divider();
                  }, 
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
