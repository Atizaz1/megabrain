import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:megabrain/screens/solo_image_display_screen.dart';
import 'package:megabrain/services/db_helper.dart';
import 'package:megabrain/services/image_link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:megabrain/screens/login_screen.dart';


class SavedImageScreen extends StatefulWidget 
{
  @override
  _SavedImageScreenState createState() => _SavedImageScreenState();
}

class _SavedImageScreenState extends State<SavedImageScreen> 
{
  SharedPreferences sharedPreferences;

  bool _isLoading = false;

  checkLoginStatus() async
  {
    
    setState(() 
    {
      _isLoading = true;
    });

    sharedPreferences = await SharedPreferences.getInstance();

    print(sharedPreferences.get('token'));

    if(sharedPreferences.get('token') == null)
    {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
    }
  }

  List<String>  savedImagesList;

  List<ImageLink> savedImagesLink;

  var dbHelper;

  @override
  void initState()
  {
    super.initState();
    checkLoginAndFetchDetails();
  }

  checkLoginAndFetchDetails() async
  {

    await checkLoginStatus();

    dbHelper = new DBHelper();

    await fetchSavedImages();
  }

  fetchSavedImages() async
  {
    savedImagesLink  = await dbHelper.getAllRecordsByUser(sharedPreferences.getInt('logged_in_user_id').toString());

    savedImagesList = new List<String>();

    if(savedImagesLink != null && savedImagesLink.length > 0)
    {
      for(var i = 0; i < savedImagesLink.length ; i++)
      {
        savedImagesList.add(savedImagesLink[i].link);
      }

      print(savedImagesList);

      Fluttertoast.showToast(msg: 'Remember: Long Tap to Delete Images', toastLength: Toast.LENGTH_LONG);
    }
    
    setState(() 
    {
      _isLoading = false;
    });
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
      fetchSavedImages();
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
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Images',
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
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : Container(
            height: MediaQuery.of(context).size.height / 1,
            color: Colors.grey[350],
            child: (savedImagesList == null || savedImagesList.length == 0) ? Center(child:Text('No Saved Images are Found', style: TextStyle(color: Colors.black),)) :
            GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.6,
                ),
                itemCount: (savedImagesList == null || savedImagesList.length == 0) ? 0 : savedImagesList.length,
                itemBuilder: (context, index) 
                {
                  return GestureDetector(
                    onLongPress: ()async
                    {                      
                      showDeletePrompt(savedImagesList[index]);
                    },
                    onTap: () 
                    {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) 
                      {
                        return SoloImageScreen(imageLink: savedImagesList[index]);
                      }));
                    },
                    child: _isLoading ? Center(child: CircularProgressIndicator()) : CachedNetworkImage(
                        imageUrl: savedImagesList[index],
                        placeholder: (context, url)        => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
        ),
      )  
    );
  }
}