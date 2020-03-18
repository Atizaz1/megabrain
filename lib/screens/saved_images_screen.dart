import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:megabrain/screens/solo_image_display_screen.dart';
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
    sharedPreferences = await SharedPreferences.getInstance();

    print(sharedPreferences.get('token'));

    if(sharedPreferences.get('token') == null)
    {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => LoginScreen()), (Route<dynamic> route) => false);
    }
  }

  List<String>  savedImagesList;


  @override
  void initState()
  {
    super.initState();
    setState(() 
    {
      _isLoading = true;
    });
    checkLoginAndFetchDetails();
  }

  void checkLoginAndFetchDetails() async
  {
    await checkLoginStatus();
    fetchSavedImages();
  }

  void fetchSavedImages() 
  {
    print(sharedPreferences.get('IMG_LINK_LIST'));

    if(sharedPreferences.get('IMG_LINK_LIST') != null)
    {
      savedImagesList = new List<String>();
      savedImagesList = sharedPreferences.get('IMG_LINK_LIST');
      print(savedImagesList);
      setState(() {
        _isLoading = false;
      });
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
      body: (savedImagesList == null || savedImagesList.length == 0) ? Center(child: Text('No Saved Images Found'),) : Container(
            height: MediaQuery.of(context).size.height / 1,
            color: Colors.grey[350],
            child: 
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
                    onLongPress: ()
                    {

                    },
                    onTap: () 
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) 
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