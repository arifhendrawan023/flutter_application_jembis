import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/Pages/login.dart';
import 'package:flutter_application_jembis/services/google_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutPage extends StatelessWidget {
  final String photoURL;
  final String displayName;
  final String email;

  const AboutPage({
    Key? key,
    required this.photoURL,
    required this.displayName,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              GoogleAuth().logout().then((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
              SharedPreferences.getInstance().then((pref) {
                pref.remove("id");
              });
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/image/jembis_logo.png",
              height: 100,
            ),
            const SizedBox(height: 16),
            
            const Text(
              "By Kelompok 4 PBM C",
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              "Version: V-1.0.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
