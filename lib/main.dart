import 'package:flutter_application_jembis/Pages/bottom.dart';
import 'package:flutter_application_jembis/firebase_options.dart';
import 'package:flutter_application_jembis/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final pref = await SharedPreferences.getInstance();
  final result = pref.getString("id");
  if (result == null) {
    return runApp(
      const MyApp(
        widget: LoginPage(),
      ),
    );
  } else {
    final displayName = pref.getString("displayName");
    final photoURL = pref.getString("photoURL");
    final email = pref.getString("email");
    return runApp(
      MyApp(
        widget: MyBottomNavBar(displayName: displayName ?? "", photoURL: photoURL ?? "", email: email ?? ""),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final Widget widget;
  const MyApp({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget,
      debugShowCheckedModeBanner: false,
    );
  }
}
