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
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stats/stats.dart';
import 'package:geolocator/geolocator.dart';
import 'package:click_to_share/utils/location.dart';


class PreviewImageScreen extends StatefulWidget {
  final String imagePath;
  final NativeDeviceOrientation orientation;
  final ImageLocation imageLocation;

  PreviewImageScreen({this.imagePath, this.orientation, this.imageLocation});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {

  
  num _pixelAvg = 0.0;

  @override
  Widget build(BuildContext context) {   

    Position _currentPosition = widget.imageLocation.position;
    Placemark _currentAddress = widget.imageLocation.address; 

    getBytesFromImage().then((bytes){
      _processImage(bytes);
    });

    String time = DateTime.now().toString();

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
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
              child: Text('Time: $time}'),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: Text('Average Pixel value: $_pixelAvg'),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: 
              _currentPosition != null?
                Text('Latitude: ${_currentPosition.latitude}, Longtitude: ${_currentPosition.longitude}') : 
                Text("No position detected"),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: _currentPosition != null? 
                Text('Current address: ${_currentAddress.locality}, ${_currentAddress.postalCode}, ${_currentAddress.country}') : 
                Text("No address detected"),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
              child: Text("Orientation: ${widget.orientation}"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> getBytesFromImage() async {
    Uint8List bytes = File(widget.imagePath).readAsBytesSync();
    return bytes;
  }
  
  void _processImage(bytes) async {

    try{

      img.Image image = img.decodeImage(bytes);
      
      final stats = Stats.fromData(image.data);
      setState(() {
        _pixelAvg = stats.average;
      });
    } catch (e){
      print(e);
      exit(0);
    }
  }
}
