import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static final tempatWisata = _firestore.collection("tempatWisata");
  static final comments = _firestore.collection("comments");
  static final users = _firestore.collection("users");
  
}
