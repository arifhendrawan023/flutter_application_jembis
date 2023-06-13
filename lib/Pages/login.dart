import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/Pages/bottom.dart';
import 'package:flutter_application_jembis/services/google_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  void handleLogin() {
    GoogleAuth().signInWithGoogle().then((value) {
      if (value.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyBottomNavBar(
              displayName: value.user?.displayName ?? "Null",
              photoURL: value.user?.photoURL ?? "Null",
              email: value.user?.email ?? "Null",
            ),
          ),
        );
      }
    });
  }

  void handleCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Dibatalkan'),
          content: const Text('Anda telah membatalkan proses login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: handleCancel,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/image/jembis_logo.png",
                  height: 75,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Di sini, Anda dapat menemukan destinasi wisata menarik, ulasan dari pengunjung sebelumnya, dan petunjuk arah yang berguna.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: handleLogin,
                  icon: Image.asset(
                    'assets/image/google_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text(
                    "Login dengan Google",
                    style: TextStyle(color: Color.fromARGB(255, 34, 34, 34)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
