import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static Color fromHex(String hexString) 
  {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  final Color color = fromHex('#754D8B');

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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/biol.jpg'),
                title: Text('Biology',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/chem.jpg'),
                title: Text('Chemistry',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/math.jpg'),
                title: Text('Maths',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/physics.jpg'),
                title: Text('Physics',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/library_add_check.png'),
                title: Text('Remember',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/config.png'),
                title: Text('Configuration',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset('images/news.png',
                width: 55.0,),
                title: Text('News',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                ),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            ],
        ),
          ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 0.0),
          child: Column(
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
            child: GridView.count(
              shrinkWrap: true,
              childAspectRatio: 1.3,
              padding: EdgeInsets.symmetric(vertical:16.0),
              crossAxisCount: 2,
              children: <Widget>
              [
                Container(
                  child: IconButton(
                    icon:Image.asset('images/biol.jpg',
                    width: 300.0,
                    height: 200.0,
                    ) ,
                    iconSize: 25.0,
                    onPressed: (){

                    },
                  ),
                ),
                Container(
                  child: IconButton(
                    icon:Image.asset('images/chem.jpg',
                    width: 300.0,
                    height: 200.0,
                    ) ,
                    iconSize: 25.0,
                    onPressed: (){

                    },
                  ),
                ),
                Container(
                  child: IconButton(
                    icon:Image.asset('images/math.jpg',
                     width: 300.0,
                    height: 200.0,
                    ) ,
                    onPressed: (){

                    },
                  ),
                ),
                Container(
                  child: IconButton(
                    icon:Image.asset('images/physics.jpg',
                     width: 300.0,
                    height: 200.0,
                    ) ,
                    iconSize: 25.0,
                    onPressed: (){

                    },
                  ),
                ),
                Container(
                  child: Container(
                    child: IconButton(
                      icon:Image.asset('images/library_add_check.png',
                      width: 300.0,
                      height: 200.0,
                      ),
                      iconSize: 25.0,

                      onPressed: (){

                      },
                    ),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon:Image.asset('images/config.png',
                    width: 300.0,
                    height: 200.0,
                    ) ,
                    iconSize: 25.0,
                    onPressed: (){

                    },
                  ),
                ),
              ],  
              ),
            ),
            SizedBox(height: 5.0),
            Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                    fontSize: 35.0,
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
    );
  }
}
