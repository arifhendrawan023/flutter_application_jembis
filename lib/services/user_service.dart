import 'package:cloud_firestore/cloud_firestore.dart';

class MyCollection {
  MyCollection._();
  static CollectionReference users =
      FirebaseFirestore.instance.collection("users");
}

class UserService {
  static Future<QuerySnapshot<Object?>> getAll() async {
    return await MyCollection.users.get();
  }


}
