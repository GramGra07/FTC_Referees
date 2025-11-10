enum Zone{
  launch,
  secret_tunnel_red;

  @override
  String toString(){
    // split by underscore, replace with a space and capitalize each word
    return name.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
  String getJsonName(){
    return name;
  }
}