class ImageLink 
{
  int id;

  String link;
  
  int user_id;

  
  ImageLink(this.link, this.user_id);
 
  Map<String, dynamic> toMap() 
  {
    var map = <String, dynamic>
    {
      'link'    : this.link,
      'user_id' : this.user_id,
    };

    return map;
  }
 
  ImageLink.fromMap(Map<String, dynamic> map) 
  {
    id      = map['id'];
    link    = map['link'];
    user_id = map['user_id'];
  }
}