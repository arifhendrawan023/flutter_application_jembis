import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_jembis/Pages/lihatMap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DetailTempat extends StatefulWidget {
  final DocumentSnapshot<Object?> place;

  const DetailTempat({Key? key, required this.place}) : super(key: key);

  @override
  _DetailTempatState createState() => _DetailTempatState();
}

class _DetailTempatState extends State<DetailTempat> {
  int jumlahSuka = 0;
  List<String> likedPlaceIds = [];
  bool isLiked = false; // Track if the place is liked

  String comment = '';
  File? imageFile;
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    fetchLikedPlaceIds(); // Fetch liked place IDs when the widget initializes
    jumlahSuka = widget.place['jumlahSuka'] ??
        0; // Initialize like count from the place data
  }

  @override
  Widget build(BuildContext context) {
    final namaTempat = widget.place["namaTempat"];
    final alamatTempat = widget.place["alamatTempat"];
    final deskripsiTempat = widget.place["deskripsiTempat"];
    final gambar1 = widget.place["gambar1"];

    return Scaffold(
      appBar: AppBar(
        title: Text(namaTempat),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(gambar1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$namaTempat',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Alamat",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          final coordinates =
                              widget.place['koordinatTempat'].split(',');
                          final latitude = double.parse(coordinates[0].trim());
                          final longitude = double.parse(coordinates[1].trim());
                          final koordinatTempat = LatLng(latitude, longitude);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LihatMapPage(
                                koordinatTempat: koordinatTempat, namaTempat: namaTempat
                              ),
                            ),
                          );
                        },
                        child: const Text('Lihat Map'),
                      ),
                    ],
                  ),
                  Text(
                    '$alamatTempat',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Deskripsi Tempat: $deskripsiTempat',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isLiked) {
                          // Decrease like count and remove the place ID
                          jumlahSuka--;
                          likedPlaceIds.remove(widget.place.id);
                          updateLikedPlaces();
                        } else {
                          // Increase like count and add the place ID
                          jumlahSuka++;
                          likedPlaceIds.add(widget.place.id);
                          updateLikedPlaces();
                        }
                        isLiked = !isLiked; // Toggle the like status
                      });
                      FirebaseService.tempatWisata.doc(widget.place.id).update({
                        "jumlahSuka": jumlahSuka,
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Jumlah Suka: $jumlahSuka',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tambah Komentar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        comment = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Komentar',
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                                0), // Ubah nilai padding sesuai kebutuhan
                            child: IconButton(
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              },
                              icon: const Icon(Icons.photo_library),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                                0), // Ubah nilai padding sesuai kebutuhan
                            child: IconButton(
                              onPressed: () {
                                getImage(ImageSource.camera);
                              },
                              icon: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          submitComment();
                        },
                        child: const Text('Kirim Komentar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  const Text(
                    'Komentar:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.tempatWisata
                        .doc(widget.place.id)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final comments = snapshot.data!.docs;
                        return Column(
                          children: comments.map((comment) {
                            final commentData =
                                comment.data() as Map<String, dynamic>;
                            final commentText = commentData['text'];
                            final commentImage = commentData['image'];
                            final commentDisplayName =
                                commentData['displayName'];
                            var timestamp = commentData['timestamp'];
                            Timestamp commentTimestamp;
                            if (timestamp != null) {
                              commentTimestamp = timestamp as Timestamp;
                            } else {
                              commentTimestamp = Timestamp.now();
                            }

                            final displayName = commentDisplayName ??
                                'Unknown User'; // Provide a fallback value

                            final formattedTimestamp =
                                DateFormat('EEEE, d MMMM y, HH:mm', 'id_ID')
                                    .format(commentTimestamp.toDate());

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (commentImage != null)
                                          Image.network(
                                            commentImage,
                                            height: 100,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(commentText),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedTimestamp,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (isLiked) {
              likedPlaceIds.remove(widget.place.id);
              jumlahSuka--;
            } else {
              likedPlaceIds.add(widget.place.id);
              jumlahSuka++;
            }
            isLiked = !isLiked; // Toggle the like status
          });
          updateLikedPlaces();
          FirebaseService.tempatWisata.doc(widget.place.id).update({
            "jumlahSuka": jumlahSuka,
          });
        },
        child: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }

  Future<void> fetchLikedPlaceIds() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data();
    if (data != null) {
      final List<dynamic> likedPlaces = data['likedPlaces'];
      setState(() {
        likedPlaceIds.addAll(likedPlaces.cast<String>());
        isLiked = likedPlaceIds
            .contains(widget.place.id); // Check if the place is liked
      });
    }
  }

  Future<void> updateLikedPlaces() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";

    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Check if the user document exists
    final userDoc = await usersCollection.doc(userId).get();
    if (userDoc.exists) {
      // User document exists, update the likedPlaces field
      await usersCollection.doc(userId).update({'likedPlaces': likedPlaceIds});
    } else {
      // User document doesn't exist, create a new document and set the likedPlaces field
      await usersCollection.doc(userId).set({'likedPlaces': likedPlaceIds});
    }
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void submitComment() async {
    if (comment.isEmpty) {
      // Show an error message or perform appropriate validation
      return;
    }

    String? imageUrl;

    // Get the user ID and display name
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? '';

    // Upload the image file to Firebase Cloud Storage and get the download URL
    if (imageFile != null) {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('comments')
          .child(widget.place.id)
          .child(DateTime.now().toString());
      final uploadTask = storageRef.putFile(imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    // Save the comment, image URL, user ID, display name, and timestamp to the Firestore database
    final commentData = {
      'text': comment,
      'image': imageUrl,
      'userId': userId,
      'displayName': displayName, // Add the display name to the comment data
      'timestamp':
          FieldValue.serverTimestamp(), // Add the current server timestamp
    };
    await FirebaseService.tempatWisata
        .doc(widget.place.id)
        .collection('comments')
        .add(commentData);

    // Clear the comment and image selection
    setState(() {
      comment = '';
      imageFile = null;
    });
  }
}
