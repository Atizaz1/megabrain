import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:megabrain/screens/saved_images_screen.dart';
import 'package:megabrain/services/db_helper.dart';
import 'package:megabrain/services/image_link.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/topic_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class SoloImageScreen extends StatefulWidget 
{
  final imageLink;

  SoloImageScreen({@required this.imageLink});

  @override
  _SoloImageScreenState createState() => _SoloImageScreenState();
}

class _SoloImageScreenState extends State<SoloImageScreen> 
{
  String imgLink;

  setImageLink(dynamic link)
  {
    imgLink = link;
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

  var dbHelper;

  @override
  void initState()
  {
    super.initState();
    checkLoginAndFetchDetails();
    setImageLink(widget.imageLink);
    dbHelper = new DBHelper();
  }

  bool _isLoading = false;

  var areaResponse;
  
  var jsonAreaData;

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
  }

  void showSavePrompt(String imgLink) 
   {
    showDialog(
    context: context,
    builder: (BuildContext context) 
    {
      return AlertDialog(
        title: Text('Save Image'),
        content: Text('Do you want to save this Image?'),
        actions: <Widget>[
          RaisedButton(
            onPressed: () 
            {
              saveImage(imgLink);
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
        ],
      );
      
    });
  }

  void saveImage(String imgLink) async
  {
    var imageLink = new ImageLink(imgLink, sharedPreferences.getInt('logged_in_user_id'));

    ImageLink imglnk = await dbHelper.create(imageLink);

    if(imglnk != null)
    {
      Fluttertoast.showToast(msg: 'Image has been saved Successfully');
    }
    else
    {
      Fluttertoast.showToast(msg: 'We are having trouble with saving image. Please try again after sometime.');
    }
  }
  

  checkImage(String imgLink) async 
  {
    int check = await dbHelper.findIfExistsByUser(imgLink, sharedPreferences.getInt('logged_in_user_id').toString());

    print("check");

    print(check);

    if(check <= 0)
    {
      showSavePrompt(imgLink);
    }
    else if(check > 0)
    {
      // Fluttertoast.showToast(msg: 'Image has already been saved. ');
      showDeletePrompt(imgLink);
    }
  }

  void showDeletePrompt(String imgLink) 
   {
    showDialog(
    context: context,
    builder: (BuildContext context) 
    {
      return AlertDialog(
        title: Text('Delete Image'),
        content: Text('Do you want to remove this Image from Saved Images?'),
        actions: <Widget>[
          RaisedButton(
            onPressed: () 
            {
              deleteImage(imgLink);
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
        ],
      );
      
    });
  }

  deleteImage(String imgLink) async 
  {
    int check = await dbHelper.deleteByLink(imgLink);

    print("check");

    print(check);

    if(check > 0)
    {
      Fluttertoast.showToast(msg: 'Image has been deleted Successfully');
      setState(() {
        _isLoading = true;
      });
      setState(() {
        _isLoading = false;
      });
    }
    else
    {
      Fluttertoast.showToast(msg: 'Image has already been deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // leading: Icon(Icons.menu),
      //   title: Text('Image Display',
      //   style: TextStyle(
      //     color: Colors.white,
      //   ),
      //   ),
      //   backgroundColor: Colors.orange,
      //   actions: <Widget>
      //   [
      //     PopupMenuButton<int>(
      //       color: Colors.white,
      //     itemBuilder: (context) => [
      //           PopupMenuItem(
      //             value: 1,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //             children: <Widget>
      //             [ 
      //               Icon(
      //                 Icons.power,
      //                 color:Colors.black
      //               ),
      //               FlatButton(
      //                 onPressed: ()
      //                 {
      //                     sharedPreferences.clear();
      //                     sharedPreferences.commit();
      //                     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
      //                 },
      //                 child: Text(
      //                   "LogOut",
      //                   style: TextStyle(
      //                     color: Colors.black,
      //                   ),              
      //                 ),
      //               ),
      //             ]
      //             ),
      //           ),
      //           PopupMenuItem(
      //             value: 2,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //             children: <Widget>
      //             [ 
      //               Icon(
      //                 Icons.book,
      //                 color:Colors.black
      //               ),
      //               FlatButton(
      //                 onPressed: ()
      //                 {
      //                     Navigator.pushNamed(context, 'personal_information');
      //                 },
      //                 child: Text(
      //                   "Personal Information",
      //                   style: TextStyle(
      //                     color: Colors.black,
      //                   ),              
      //                 ),
      //               ),
      //             ]
      //             ),
      //           ),
      //           PopupMenuItem(
      //             value: 2,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //             children: <Widget>
      //             [ 
      //               Icon(
      //                 Icons.image,
      //                 color:Colors.black
      //               ),
      //               FlatButton(
      //                 onPressed: ()
      //                 {
      //                     Navigator.push(context, MaterialPageRoute(builder: (context) 
      //                     {
      //                       return SavedImageScreen();
      //                     }));
      //                 },
      //                 child: Text(
      //                   "Saved Images",
      //                   style: TextStyle(
      //                     color: Colors.black,
      //                   ),              
      //                 ),
      //               ),
      //             ]
      //             ),
      //           ),
      //         ],
      //     icon: Icon(Icons.more_vert),
      //     offset: Offset(0, 100),
      //   )
      //   ],
      // ),
      body: Container(
        height: MediaQuery.of(context).size.height / 1,
        color: Colors.grey[300],
        child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Container(
                child: GestureDetector(
                  onLongPress: ()
                  {
                    checkImage(imgLink);
                  },
                  child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imgLink),
                  ),
                ),
              ),
          ),
      ),
    );
  }
}
