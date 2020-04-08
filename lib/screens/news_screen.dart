import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:megabrain/screens/saved_images_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/area_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class News 
{
    int id;
    DateTime newsDate;
    String news;
    int newsPriority;

    News(
    {
        this.id,
        this.newsDate,
        this.news,
        this.newsPriority,
    });

    factory News.fromJson(Map<String, dynamic> json) => News(
        id: json["id"],
        newsDate: DateTime.parse(json["news_date"]),
        news: json["news"],
        newsPriority: json["news_priority"],
    );

    Map<String, dynamic> toJson() => 
    {
        "id": id,
        "news_date": "${newsDate.year.toString().padLeft(4, '0')}-${newsDate.month.toString().padLeft(2, '0')}-${newsDate.day.toString().padLeft(2, '0')}",
        "news": news,
        "news_priority": newsPriority,
    };
}

class NewsScreen extends StatefulWidget 
{
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> 
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
  
  List<News> newsList;

  bool _isLoading = false;

  var subjectResponse;
  
  var jsonSubjectData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchNewsList();
  }

  List<News> newsFromJson(String str) 
  {
    return List<News>.from(convert.jsonDecode(str).map((x) => News.fromJson(x)));
  }

  String newsToJson(List<News> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));
  }

  var newsResponse;

  var jsonNewsData;

  fetchNewsList() async 
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

    newsResponse = await http.get("http://megabrain-enem.com.br/API/api/auth/getNOrderedNews",headers:authorizationHeaders);

    jsonNewsData = convert.jsonDecode(newsResponse.body);

    if(newsResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      print(jsonNewsData);

      newsList = newsFromJson(newsResponse.body);

      print(newsList);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(newsResponse);
                                        
    }
  }

  var dateFormatter = new DateFormat('dd-MM-yyyy');

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
                color: Colors.orange[500],
                child: _isLoading ? 
                Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.orange[500],
                  )
                )
                :
                Center(
                  child: DataTable(columns: [
                    DataColumn(label: Text('Date',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            )),
                    DataColumn(label:Text('News',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ))
                  ], rows: newsList.map(
                      (news) => DataRow(
                        cells: [
                          DataCell(                            
                            Text(dateFormatter.format(news.newsDate),
                                  style: TextStyle(fontSize: 15, color: Colors.white),),
                            onTap: () {
                            },
                          ),
                          DataCell(
                            Text(news.news,
                                  style: TextStyle(fontSize: 15,color: Colors.white),),
                          ),
                        ]),
                      ).toList(),
                  ),
                )
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
  const MenuCard({@required this.newsDate, @required this.newsContent});

  final String newsDate;

  final String newsContent;

  @override
  Widget build(BuildContext context) 
  {
    return DataTable(
      columns: [
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('News'))
    ], 
    rows: [
      DataRow(cells: [
        DataCell(Text(newsDate)),
        DataCell(Text(newsContent)),
      ]
    )
    ]
    );
  }
}
