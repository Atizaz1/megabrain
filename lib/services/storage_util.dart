import 'package:shared_preferences/shared_preferences.dart';
class StorageUtil 
{
  static StorageUtil _storageUtil;

  static List<String> imglist = new List<String>();

  static SharedPreferences _preferences;

  static Future getInstance() async 
  {
    if (_storageUtil == null) 
    {
      var secureStorage = StorageUtil._();

      await secureStorage._init();

      _storageUtil = secureStorage;
    }

    return _storageUtil;
  }

  StorageUtil._();
  
  Future _init() async 
  {
    _preferences = await SharedPreferences.getInstance();
  }

  static String getString(String key, {String defValue = ''}) 
  {
    if (_preferences == null) return defValue;

    return _preferences.getString(key) ?? defValue;
  }
  static Future putString(String key, String value) 
  {
    if (_preferences == null) return null;

    return _preferences.setString(key, value);
  }


  static List<String> getStringList(String key) 
  {
    if (_preferences != null)
    {
      print('object');
      return _preferences.getStringList(key);
    }
    else
    {
      return null;
    }
  }
  
  static Future putStringList(String key, String value) 
  {
    if (_preferences == null)
    {
      return null;
    } 
    else
    {
      imglist.add(value);
      return _preferences.setStringList(key, imglist);
    }
  }
}