import "package:geolocator/geolocator.dart";

class ImageLocation{

  Position position;
  Placemark address;

  ImageLocation(this.position, this.address);
}

class LocationUtils{

  final Geolocator _geolocator = Geolocator()..forceAndroidLocationManager;

  Future<ImageLocation> getGeoLocation() async {
   
      Position currentPosition = await _getCurrentPosition();
      Placemark currentAddress =   await _getAddressFromLatLng(currentPosition);
      final ImageLocation imageLocation = ImageLocation(currentPosition, currentAddress);
      return imageLocation;
  }
  

  Future<Position> _getCurrentPosition() async {
    Position position = await this._geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }

  Future<Placemark> _getAddressFromLatLng(position) async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = p[0];

      return place;

    } catch (e) {
      print(e);
      return null;
    }
  }

}