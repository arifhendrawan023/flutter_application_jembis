import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_jembis/Pages/lihatMap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool isLiked = false;
  bool isSaved = false;
  dynamic namaTempat;
  dynamic alamatTempat;
  dynamic deskripsiTempat;
  dynamic gambar1;

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
    fetchLikedPlaceIds();
    fetchSavedPlaceIds();
    jumlahSuka = widget.place['jumlahSuka'] ?? 0;
    // try{
    //   print("TRY ${widget.place['disimpan']}");
    //   isSaved = widget.place['disimpan'] ?? false;
    // } catch (e) {
    //   print("FAILED BECAUSE ${e}");
    //   isSaved = false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    namaTempat = widget.place["namaTempat"];
     alamatTempat = widget.place["alamatTempat"];
     deskripsiTempat = widget.place["deskripsiTempat"];
     gambar1 = widget.place["gambar1"];

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$namaTempat',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: addToSaved,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Colors.grey,
                          ),
                        ),
                      )
                    ],
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
                                  koordinatTempat: koordinatTempat,
                                  namaTempat: namaTempat),
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
                          jumlahSuka--;
                          likedPlaceIds.remove(widget.place.id);
                          updateLikedPlaces();
                        } else {
                          jumlahSuka++;
                          likedPlaceIds.add(widget.place.id);
                          updateLikedPlaces();
                        }
                        isLiked = !isLiked;
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
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                              onPressed: () async {
                                var status = await Permission.storage.request();
                                if (status.isGranted) {
                                  getImage(ImageSource.gallery);
                                } else if (status.isDenied ||
                                    status.isPermanentlyDenied) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Izin Dibutuhkan"),
                                      content: const Text(
                                        "Aplikasi memerlukan izin akses penyimpanan untuk mengunggah foto dari perangkat Anda.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Tutup"),
                                        ),
                                        TextButton(
                                          onPressed: () => openAppSettings(),
                                          child: const Text("Buka Pengaturan"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.photo_library),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                              onPressed: () async {
                                var status = await Permission.camera.request();
                                if (status.isGranted) {
                                  getImage(ImageSource.camera);
                                } else if (status.isDenied ||
                                    status.isPermanentlyDenied) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Izin Dibutuhkan"),
                                      content: const Text(
                                        "Aplikasi memerlukan izin akses ke kamera untuk melanjutkan.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Tutup"),
                                        ),
                                        TextButton(
                                          onPressed: () => openAppSettings(),
                                          child: const Text("Buka Pengaturan"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
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

                            final displayName =
                                commentDisplayName ?? 'Unknown User';

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
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (comment['userId'] ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid)
                                          IconButton(
                                            onPressed: () {
                                              editComment(comment);
                                            },
                                            icon: const Icon(Icons.edit),
                                          ),
                                        if (comment['userId'] ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid)
                                          IconButton(
                                            onPressed: () {
                                              deleteComment(comment);
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                      ],
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
        isLiked = likedPlaceIds.contains(widget.place.id);
      });
    }
  }

  Future<void> fetchSavedPlaceIds() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";
    print("PLACE ID: ${widget.place.id}");
    final doc = await FirebaseFirestore.instance.collection('tempatWisataTersimpan').get();
    final List<DocumentSnapshot> documents = doc.docs;
    for (var document in documents) {
      print("HERE");
      final String idUser = document['user_id'];
      if (idUser.contains(userId) && document['place_id'] == widget.place.id){
        setState(() {
          isSaved = true;
        });
        return;
      }
      try {
        if (idUser.contains(userId) && document['place_id'] == widget.place['place_id']){
          setState(() {
            isSaved = true;
          });
          return;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> updateLikedPlaces() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";

    final usersCollection = FirebaseFirestore.instance.collection('users');

    final userDoc = await usersCollection.doc(userId).get();
    if (userDoc.exists) {
      await usersCollection.doc(userId).update({'likedPlaces': likedPlaceIds});
    } else {
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

  void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Ditolak'),
          content: const Text('Izin ini diperlukan untuk mengakses galeri.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Ditolak Secara Permanen'),
          content: const Text(
              'Anda telah secara permanen menolak izin ini. Silakan aktifkan izin di pengaturan aplikasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showCameraPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Kamera Ditolak'),
          content: const Text('Izin ini diperlukan untuk menggunakan kamera.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showCameraPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Kamera Ditolak Secara Permanen'),
          content: const Text(
              'Anda telah secara permanen menolak izin kamera. Silakan aktifkan izin kamera di pengaturan aplikasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void submitComment() async {
    if (comment.isEmpty) {
      return;
    }

    String? imageUrl;

    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? '';

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

    final commentData = {
      'text': comment,
      'image': imageUrl,
      'userId': userId,
      'displayName': displayName,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await FirebaseService.tempatWisata
        .doc(widget.place.id)
        .collection('comments')
        .add(commentData);

    setState(() {
      comment = '';
      imageFile = null;
    });
  }

  void addToSaved() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("id") ?? "";

    final saveData = {
      'namaTempat': namaTempat,
      'alamatTempat': alamatTempat,
      'deskripsiTempat': deskripsiTempat,
      'gambar1': gambar1,
      'place_id': widget.place.id,
      'jumlahSuka': jumlahSuka,
      'user_id': userId
    };

    if (isSaved){
      String placeId = "";
      try {
        placeId = widget.place['place_id'];
      } catch (e) {
        placeId = widget.place.id;
      }

      FirebaseService.savedTempatWisata
          .where('place_id', isEqualTo: placeId)
          .get()
          .then((querySnapshot) {
        for (var document in querySnapshot.docs) {
          document.reference.delete().then((value) {
            setState(() {
              isSaved = false;
            });
          });
        }
      }).catchError((error) {
        print('Failed to delete documents: $error');
      });
    } else {
      FirebaseService.savedTempatWisata.add(saveData).then((value) {
        setState(() {
          isSaved = true;
        });
      });
    }
  }

  void editComment(DocumentSnapshot comment) async {
    final currentText = comment['text'] ?? '';
    final commentUserId = comment['userId'] ?? '';

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    if (commentUserId != currentUserId) {
      return;
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        String newText = currentText;
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            onChanged: (value) {
              newText = value;
            },
            controller: TextEditingController(text: currentText),
            decoration: const InputDecoration(hintText: 'Enter comment'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(newText);

                final commentRef = FirebaseService.tempatWisata
                    .doc(widget.place.id)
                    .collection('comments')
                    .doc(comment.id);

                final updatedData = {
                  'text': newText,
                };

                await commentRef.update(updatedData);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteComment(DocumentSnapshot comment) {
    final commentUserId = comment['userId'] ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    if (commentUserId != currentUserId) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () {
              // Delete the comment from Firestore
              FirebaseService.tempatWisata
                  .doc(widget.place.id)
                  .collection('comments')
                  .doc(comment.id)
                  .delete();

              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
