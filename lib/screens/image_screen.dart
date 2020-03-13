import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/topic_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget 
{
  final subjectCode;

  final subjectName;

  final area_code;

  final area_name;

  final topic_code;

  final topic_name;

  ImageScreen({this.subjectCode, this.subjectName, this.area_code, this.area_name, this.topic_code, this.topic_name});

  @override
  _ImageScreenState createState() => _ImageScreenState();
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

class _ImageScreenState extends State<ImageScreen> 
{
  String ss_code;

  String ss_name;

  String area_code;

  String area_name;

  String topic_c;

  String topic_n;

  setImagePreReq(dynamic s_code, dynamic s_name, dynamic a_code, dynamic a_name, dynamic t_code, dynamic t_name)
  {
    ss_code   = s_code;

    ss_name   = s_name;
    
    area_code = a_code;

    area_name = a_name;

    topic_c   = t_code;

    topic_n   = t_name;
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
    setImagePreReq(widget.subjectCode, widget.subjectName, widget.area_code, widget.area_name, widget.topic_code, widget.topic_name);
  }
  
  List<String> imagesLinkList;

  bool _isLoading = false;

  var imageResponse;
  
  var jsonImageData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    await fetchImageLinkList();
  }

  List<String> imageLinkFromJson(String str) 
  {
    return List<String>.from(convert.jsonDecode(str).map((x) => x));
  }

  String imageLinkToJson(List<String> data) 
  {
    return convert.jsonEncode(List<dynamic>.from(data.map((x) => x)));
  }

  fetchImageLinkList() async 
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
    print(area_code);
    print(topic_c);

    imageResponse = await http.get("http://megabrain-enem.com.br/API/api/auth/getImagePathSubjectWise/$ss_code/$area_code/$topic_c",headers:authorizationHeaders);

    jsonImageData = convert.jsonDecode(imageResponse.body);

    if(imageResponse.statusCode == 200)
    {

      setState(() 
      {
        _isLoading = false;
      });

      print(jsonImageData);

      imagesLinkList = imageLinkFromJson(imageResponse.body);

      print(imagesLinkList.first);

    }
    else
    {
      setState(()
      {
        _isLoading = false;
      });
      
      print(jsonImageData);

      Fluttertoast.showToast(msg: 'No Images were Found Related to Selected Topic');
                                        
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text(topic_n,
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
      body: _isLoading ? Center(child: CircularProgressIndicator(
        backgroundColor: Colors.orange[500],
      )):
      PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(imagesLinkList[index]),
          initialScale: PhotoViewComputedScale.contained * 0.8,
        );
      },
      itemCount: (imagesLinkList == null || imagesLinkList.length == 0) ? 0 : imagesLinkList.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      // backgroundDecoration: widget.backgroundDecoration,
      // pageController: widget.pageController,
      // onPageChanged: onPageChanged,
    )
      
    );
  }
}