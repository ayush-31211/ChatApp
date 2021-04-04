import 'package:ChatApp/Screens/Auth.dart';


import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme().apply(fontFamily: "Roboto")),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  
  MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.pink[400], Colors.pink[300]],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            width: MediaQuery.of(context).size.width * 1,
            height: double.infinity,
            child: Center(child: AuthScreen())));
  }
}
