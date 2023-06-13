import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuth {
  var instance = FirebaseAuth.instance;
  var googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final result = await instance.signInWithCredential(credential);

    final pref = await SharedPreferences.getInstance();
    pref.setString("id", result.user?.uid ?? "");
    pref.setString("email", result.user?.email ?? "");
    pref.setString("displayName", result.user?.displayName ?? "");
    pref.setString("photoURL", result.user?.photoURL ?? "");

    // Once signed in, return the UserCredential
    return result;
  }

  Future<void> logout() async {
    await instance.signOut();
    await googleSignIn.signOut();
    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }
}

