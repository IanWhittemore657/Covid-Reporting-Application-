
import 'package:covid/SpecificInput.dart';
import 'package:covid/ThankYou.dart';
import 'package:flutter/cupertino.dart';
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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID REPORTING',
//home:MapTest(),
      home: MyHomePage(title: 'COVID REPORTING'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                  child: const Text("Please ensure an image has been taken "))),
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

  Future createRecord() async {

    await databaseReference.collection("User Input").document("xnTEUIQWbAUGEldxH8aXvE5UDUq2")
        .collection("Photos").document("${DateTime.now()}").setData({
      "Latitude":latit,
      "Longitude":longit,
      "Locality":local,
      "PostCode":postal,
      "Date":format,
      "Time":formattedDate,
      "Country":countryCode,
      "ImageReference":url,
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
//    N8x3buPEipZ1NC9UoUO4AGUfWsb2 / Images  (This meant to go in the child)
    final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Images");
    final StorageUploadTask uploadTask1 = postImageRef.child("/${DateTime.now()}  { $postal }").putFile(imageFile);
    var imageurl = await (await uploadTask1.onComplete).ref.getDownloadURL();
    setState(() {
      url = imageurl.toString();
    });

    print("Image Url = $url");
  }

  String appbarstatus = "Please Wait";

  Future<bool> _canLeave(BuildContext context)
  {
    return SystemNavigator.pop();
  }


  @override
  Widget build(BuildContext context) {

    return new WillPopScope(onWillPop:() => _canLeave(context),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(174, 201, 218, 1),
        appBar: AppBar(
          title: Text("COVID REPORTING"),
        ),
        bottomNavigationBar: BottomAppBar(

          child: Padding(
            //padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Padding(
                  // padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: FlatButton.icon(
                      icon: Icon(Icons.location_searching,),
                      label: Text('SPECIFIC REPORT',style: TextStyle(fontSize: 12),),
                      onPressed: () =>
                      {
                        Navigator.push(
                            context, new MaterialPageRoute(
                            builder: (context) => SpecificInput())),
                      }
                  ),
                ),



              ],

            ),
          ),
        ),

        body: Container(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 1, 10, 20),
                      child: Center(child: Text("Take a picture of violation of social distancing.",style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold),textAlign: TextAlign.center,)),
                    ),


                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            20, 10, 20, 80),
                        child: Container(
                          child: Column
                            (
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
                                    Icons.camera_alt, size: 200,) : Image
                                      .file(
                                    imageFile, width: 400, height: 400,),

                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 10, 30),
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
                                        if (imageFile == null) {
                                          print(
                                              "Please ensure images are captured");
                                          _ackAlert(context);
                                        }
                                        else {
                                print("NOICE");
                                DateTime now = DateTime.now();

                                formattedDate = DateFormat('kk:mm').format(now);

                                format = DateFormat("yyyy-MM-dd").format(now);
                                print(format);

                                           _getCurrentLocation();
                                           _getAddressFromLatLng();
                                          _ThankyouAlert(context);
                                          await uploadFile1();
                                          await createRecord();
                                              setState(() {
                                                imageFile = null;
                                              });

                                      Navigator.push(context,new MaterialPageRoute(builder: (context)=> MyHomePage()));




                                print(_currentAddress);
                                        }
//

                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

        ),


      ),
    );
  }
//      );
//    }
//  }
  void createData2() async {

    DocumentReference ref = await db.collection('CRUD').add({'name': 'helli 😎',
      'todo':"wwewe" });
    print("DID IT WORK!!!!!");
    print(ref.documentID);

  }
}

