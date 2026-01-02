import 'package:cleanconnect/app/app.dart';
import 'package:cleanconnect/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';


void main()async{
  runApp(App());
  await HiveService().init();

}