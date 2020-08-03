
import 'package:covid/ThankYou.dart';
import 'package:covid/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "package:intl/intl.dart";
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import "dart:io";
import "dart:async";
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";


class SpecificInput extends StatefulWidget {

  SpecificInput({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SpecificPageState createState() => _SpecificPageState();
}

class _SpecificPageState extends State<SpecificInput> {
  int _counter = 0;

  final Geolocator geolocator = Geolocator()
    ..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  String latit = "52.0";
  String longit = "-0.75";

  File imageFile;

  //this will take create alert if there is no image taken
  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Container(height: 70,
              child: Center(
                  child: const Text("Please ensure you have entered a description"))),
          actions: <Widget>[
            Center(
              child: FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ThankyouAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('THANK YOU')),
          content: Container(height: 70,
              child: Center(
                  child: const Text("STAY SAFE"))),
          actions: <Widget>[
//            Center(
//              child: FlatButton(
//                child: Text('Ok'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//            ),
          ],
        );
      },
    );
  }

  //the variable to call it into the firebase storage
  StorageUploadTask uploadTask;

  //file path
  String filePath1;

  @override
  void initState() {
     _getCurrentLocation();
     _getAddressFromLatLng();
    super.initState();
  }


  Future _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        latit = _currentPosition.latitude.toString();
        longit = _currentPosition.longitude.toString();
        print(_currentPosition);
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  String local = "";
  String postal= "";
  String countryCode = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  final db = Firestore.instance;



  final FirebaseStorage _storage = FirebaseStorage(storageBucket: "gs://covidtest-4608a.appspot.com");
  StorageUploadTask _upload;
  final databaseReference = Firestore.instance;

  String formattedDate = "";
  String format = "";

  var image2;

  String address = "";

  String description = "";

  Future createRecords() async {

    await databaseReference.collection("User Input").document("xnTEUIQWbAUGEldxH8aXvE5UDUq2")
        .collection("Specific Report").document("${DateTime.now()}").setData({
      "Latitude":latit,
      "Longitude":longit,
      "Locality":local,
      "PostCode":postal,
      "Date":format,
      "Time":formattedDate,
      "Country":countryCode,
      "ImageReference":url,
      "Address":address,
      "Description":description,
      "location":GeoPoint(double.parse(latit),double.parse(longit)),
      "colorVal":"0xff109618",

    });
    print("Successful");
  }

//this will take the location geo coords and convert it to something more natural
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        local = place.locality;
        postal = place.postalCode;
        countryCode = place.country;
        _currentAddress =
        "    ${place.locality} \n\n       ${place.postalCode}\n\n    ${place
            .country}";
        print(_currentAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  Future _getImage1() async {
    var image1 = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = image1;
      print("1: $imageFile");
    });
  }

  String _uploadedFileURL;
  String url;

  Future uploadFile1() async {

    final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Images");
    final StorageUploadTask uploadTask1 = postImageRef.child("/${DateTime.now()}  { $postal }").putFile(imageFile);
    var imageurl = await (await uploadTask1.onComplete).ref.getDownloadURL();
    setState(() {
      url = imageurl.toString();
    });

    print("Image Url = $url");

  }
  final focus = FocusNode();
  String appbarstatus = "Please Wait";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(174, 201, 218, 1),
      appBar: AppBar(
        title: Text("Specific Report"),
      ),


      body: Form(
        key: _formKey,
        autovalidate: true,

        child: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[


                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          20, 50, 20, 0),
                      child: Container(
                        child: Column
                          (
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            GestureDetector(
                              onTap: () {
                                _getImage1();
                                print("add image 1");
                              },
                              child: Container
                                (
                                decoration: BoxDecoration(
                                  // border: Border.all(color: Colors.black),
                                  color: Color.fromRGBO(
                                      174, 201, 218, 1),),

                                child: imageFile == null ? Icon(
                                  Icons.camera_alt, size: 100,) : Image
                                    .file(
                                  imageFile, width: 400, height: 250,),

                              ),
                            ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Text("Image is optional",style: TextStyle(fontSize: 14,color: Colors.grey[600]),),
                              ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 35, 10),

                    child: TextFormField(
//                    validator: (val) =>
//                    val.isEmpty
//                        ? "Please enter a description"
//                        : null,
                      onChanged: (val) =>
                          setState(() =>
                          address = val),

                      onFieldSubmitted: (v){
                        FocusScope.of(context).requestFocus(focus);
                      },

                      decoration: InputDecoration(

                        icon: Icon(Icons.home,
                          color: Colors.black,
                          size: 30,
                        ),

                        hintText: "This is optional",
                        hintStyle: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16,),
                        labelText: "Address",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 20,),
                      ),


                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 35, 10),
                    child: TextFormField(
                          validator: (val) =>
                          val.isEmpty
                              ? "Please enter a description"
                              : null,
                      onChanged: (val) =>
                          setState(() =>
                          description = val),
                      focusNode: focus,
                      decoration: InputDecoration(

                        icon: Icon(Icons.description,
                          color: Colors.black,
                          size: 30,
                        ),

                        hintText: "Please explain the situation",
                        hintStyle: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16,),
                        labelText: "Description",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 20,),
                      ),

                      keyboardType: TextInputType.multiline,
                      maxLines: null,

                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 18, 10, 30),
                    child: Container(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                        child: RaisedButton(
                            color: Colors.red,
                            child: Text("SUBMIT", style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,),
                            ),

                            onPressed: () async {

                              if(_formKey.currentState.validate())
                                {
                                  print("NOICE");
                                  DateTime now = DateTime.now();

                                  formattedDate = DateFormat('kk:mm').format(now);

                                  format = DateFormat("yyyy-MM-dd").format(now);
                                  print(format);

                                   _getCurrentLocation();
                                   _getAddressFromLatLng();

                                  _ThankyouAlert(context);
                                await uploadFile1();
                                await createRecords();
                                  setState(() {
                                    imageFile = null;
                                  });
                                  Navigator.push(
                                      context, new MaterialPageRoute(
                                      builder: (context) => MyHomePage()));
                                }
                                else
                                  {
                                    _ackAlert(context);
                                  }



//

                            }),
                      ),
                    ),
                  ),
                ],
              ),
            )

        ),
      ),


    );
  }

}

