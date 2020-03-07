import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class NetworkHelper
{
  String _url;

  NetworkHelper(url)
  {
    this._url = url;
  }
  
  setUrl(url)
  {
    this._url = url;
  }

  getUrl()
  {
    return this._url;
  }

  getDataByHttpPost(url, Map args) async
  {
    var response = await http.post(url, body:args);

    var jsonData;

    jsonData  = convert.jsonDecode(response.body);

    if(response.statusCode == 200)
    {
       jsonData['flag'] = 'valid';
    }
    else
    {
       jsonData['flag'] = 'invalid';
    }
  }
}