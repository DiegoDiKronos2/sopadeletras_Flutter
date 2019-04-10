import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_flame/game.dart';


main()=>runApp(MyApp());

class MyApp extends StatelessWidget{
  List<String> words = ["PLACE","HOLDER","YEI","Funciona"];
  @override
  Widget build(BuildContext context){
    // TODO: implement build
    return MainGame(words,8).widget;
  }
}