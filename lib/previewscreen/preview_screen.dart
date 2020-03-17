/*
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'dart:io';
import 'dart:typed_data';
// import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:stats/stats.dart';
import 'package:geolocator/geolocator.dart';

class PreviewImageScreen extends StatefulWidget {
  final String imagePath;

  PreviewImageScreen({this.imagePath});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = '';
  num _pixelAvg = 0.0;

  @override
  Widget build(BuildContext context) {   

    // SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover)),
            SizedBox(height: 10.0),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(60.0),
                child: RaisedButton(
                  onPressed: () {
                    // _processImage();
                    // addImageTag();
                    _getCurrentLocation();
                    getBytesFromImage().then((bytes) {
                      _processImage(bytes);
                      // File('testimage.png').openWrite('image/').writeAsBytesSync(bytes.buffer.asUint32List());
                      // Share.file('Share via:', basename(widget.imagePath),
                      //     bytes.buffer.asUint8List(), 'image/png');
                    // });
                    });
                  },
                  child: Text('Info'),
                ),
              ),
            ),
            Text('Average Pixel value: $_pixelAvg'),
            Text('Latitude: ${_currentPosition.latitude}, Longtitude: ${_currentPosition.longitude}'),
            Text('Current address: $_currentAddress'),
          ],
        ),
      ),
    );
  }

  Future<ByteData> getBytesFromFile() async {
    Uint8List bytes = File(widget.imagePath).readAsBytesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }

  Future<Uint8List> getBytesFromImage() async {
    Uint8List bytes = File(widget.imagePath).readAsBytesSync();
    return bytes;
  }
  
  void _processImage(bytes) async {

    try{

      img.Image image = img.decodeImage(bytes);
      
      final stats = Stats.fromData(image.data);
      _pixelAvg = stats.average;
      print(stats.withPrecision(3));

      // Tagging the image with a timestamp
      // img.Image taggedimage = img.drawString(image, img.arial_14, 50, 50, 'Test');
      // String path = join((await getApplicationDocumentsDirectory()).path, '${DateTime.now()}.png');
      // File file = File(path);
      // file.writeAsBytesSync(img.encodePng(taggedimage));
      // print(image.getPixel(50, 50));
      // print(taggedimage.getBytes().length);


      // Saving image to storage
      // Uint8List newbytes = taggedimage.getBytes();
      // print(newbytes.length);
      // final result = await ImageGallerySaver.saveImage(newbytes);
      // print(result);
      // print("Image width: ${image.width}");
        // print(image.data);
      
        
    } catch (e){
      print(e);
      exit(0);
    }
  }

  _getCurrentLocation() {
    geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
        setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}
