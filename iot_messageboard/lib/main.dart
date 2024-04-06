import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart LED Board',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.light,
          textTheme: GoogleFonts.aldrichTextTheme(
            Theme.of(context)
                .textTheme, // If this is not set, then ThemeData.light().textTheme is used.
          ),
        ),
        home: const HomePageScreen(title: 'Smart LED Board'));
  }
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key, required String title}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final TextEditingController _idcontroller = TextEditingController();
  final TextEditingController _msjcontroller = TextEditingController();
  final TextEditingController _idpasswordctrl = TextEditingController();

  DatabaseReference firebaseref = FirebaseDatabase.instance.ref();
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String dtime = "";
  bool _isChecked = false;
  late double screenHeight, screenWidth, resWidth;
  bool _isObscure = true;
  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = 600;
      //rowcount = 3;
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                child: Image.asset('assets/led.jpg'),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Smart LED Display",
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.grey),
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: resWidth,
                      child: TextField(
                          controller: _idcontroller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Board ID',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: resWidth,
                      child: TextField(
                          controller: _idpasswordctrl,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ))),
                    ),
                    Row(children: [
                      const Text("Remember Me"),
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          _onRememberMeChanged(value!);
                        },
                      ),
                    ]),
                    const Divider(color: Colors.grey),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: resWidth,
                      child: TextField(
                          controller: _msjcontroller,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          minLines: 2,
                          maxLength: 50,
                          decoration: InputDecoration(
                              labelText: 'Your Message',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(dtime,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          minWidth: 100,
                          height: 50,
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          elevation: 15,
                          onPressed: sendMessage,
                          child: const Text('SEND'),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          minWidth: 100,
                          height: 50,
                          color: Colors.yellow,
                          textColor: Colors.black,
                          elevation: 15,
                          onPressed: loadMessage,
                          child: const Text('LOAD'),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          minWidth: 100,
                          height: 50,
                          color: Colors.red,
                          textColor: Colors.white,
                          elevation: 15,
                          onPressed: clearMessage,
                          child: const Text('CLEAR'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage() {
    if (_idcontroller.text.isEmpty || _msjcontroller.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter required input!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      updateData();
    }
  }

  void _onRememberMeChanged(bool value) {
    _isChecked = value;
    setState(() {
      if (_isChecked) {
        _saveRemovePref(true);
      } else {
        _saveRemovePref(false);
      }
    });
  }

  void loadMessage() {
    if (_idcontroller.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter required input!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      getData();
    }
  }

  void _saveRemovePref(bool value) async {
    if (_idcontroller.text.isEmpty && _idpasswordctrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter device id/password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    String devid = _idcontroller.text;
    String devpass = _idpasswordctrl.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setString('devid', devid);
      await prefs.setString('devpass', devpass);
      await prefs.setBool('remember', true);
      Fluttertoast.showToast(
          msg: "Preference Stored",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    } else {
      await prefs.setString('devid', '');
      await prefs.setString('devpass', '');
      await prefs.setBool('remember', false);

      Fluttertoast.showToast(
          msg: "Preference Removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<void> getData() async {
    String devid = _idcontroller.text;
    
    final snapshot = await firebaseref.child('$devid/message').get();
    final snapshotdt = await firebaseref.child('$devid/date').get();
    final snapshotpwd = await firebaseref.child('$devid/pass').get();
    print(snapshot.value);
    if (_idpasswordctrl.text != snapshotpwd.value.toString()) {
      Fluttertoast.showToast(
        msg: "Wrong Password",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }
    if (snapshot.exists) {
      String msj = snapshot.value.toString();
      setState(() {
        _msjcontroller.text = msj;
        dtime = "Message date: ${snapshotdt.value}";
      });
      Fluttertoast.showToast(
        msg: "Message Loaded",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      _msjcontroller.text = "";
      Fluttertoast.showToast(
        msg: "Failed",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> updateData() async {
    String devid = _idcontroller.text;
    String usermsj = _msjcontroller.text;
    String dt = df.format(DateTime.now());
    if (usermsj.length > 50) {
      Fluttertoast.showToast(
        msg: "Message too long",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }
    final snapshot = await firebaseref.child(devid).get();
    if (snapshot.exists) {
      await firebaseref.child(devid).update({'message': usermsj, 'date': dt});
      Fluttertoast.showToast(
        msg: "Success",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
      loadMessage();
    } else {
      Fluttertoast.showToast(
        msg: "Failed",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String devid = (prefs.getString('devid')) ?? '';
    String devpass = (prefs.getString('devpass')) ?? '';
    _idcontroller.text = devid;
    _idpasswordctrl.text = devpass;

    if (devid.isNotEmpty) {
      getData();
      setState(() {
        _isChecked = true;
      });
    }
  }

  void clearMessage() {
    setState(() {
      _msjcontroller.text = "";
      dtime = "";
    });
  }

  // Future<bool> _onBackPressed() async {
  //   return showDialog(
  //         context: context,
  //         builder: (context) =>  AlertDialog(
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           title:  const Text(
  //             'Exit',
  //             style: TextStyle(
  //               color: Colors.white,
  //             ),
  //           ),
  //           content:  const Text(
  //             'Are you sure?',
  //             style: TextStyle(
  //               color: Colors.white,
  //             ),
  //           ),
  //           actions: <Widget>[
  //             MaterialButton(
  //                 onPressed: () {
  //                   SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //                   //exit(0);
  //                 },
  //                 child: const Text(
  //                   "Ya",
  //                   style: TextStyle(
  //                     color: Color.fromRGBO(101, 255, 218, 50),
  //                   ),
  //                 )),
  //             MaterialButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(false);
  //                   FocusScope.of(context).requestFocus(new FocusNode());
  //                 },
  //                 child: const Text(
  //                   "Tidak",
  //                   style: TextStyle(
  //                     color: Color.fromRGBO(101, 255, 218, 50),
  //                   ),
  //                 )),
  //           ],
  //         ),
  //       )?? false;
  // }
}