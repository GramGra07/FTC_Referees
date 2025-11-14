enum Zone{
  auto_red_side,
  auto_blue_side,
  gate_red,
  gate_blue,
  secret_tunnel_red,
  secret_tunnel_blue,
  loading_zone_red,
  loading_zone_blue,
  base_zone_red,
  base_zone_blue,;

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