import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/GetIt/dependency_injection.dart';
import 'package:flutter_application_1/user_page.dart';
import 'package:worker_manager/worker_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setup();
  await workerManager.init();
  runApp(MaterialApp(home: MainPage()));
}
