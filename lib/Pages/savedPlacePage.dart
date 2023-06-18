import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_service.dart';
import 'detailTempat.dart';

class SavedPlacePage extends StatefulWidget {
  const SavedPlacePage({Key? key}) : super(key: key);

  @override
  State<SavedPlacePage> createState() => _SavedPlacePageState();
}

class _SavedPlacePageState extends State<SavedPlacePage> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("id") ?? "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempat Wisata Tersimpan'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseService.savedTempatWisata.get(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final places = snapshot.data?.docs ?? [];
            final savedPlaces = filterIsSaved(places);

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (final place in savedPlaces)
                    FutureBuilder<Widget>(
                      future: buildTempatTile(place),
                      builder: (_, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            width: 200,
                            height: 225,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return snapshot.data!;
                      },
                    ),
                ],
              ),
            );
          },
        ),
      )
    );
  }

  Future<Widget> buildTempatTile(DocumentSnapshot? place) async {
    print("RESULT IS ${place?.data()}}");
    final namaTempat = place?["namaTempat"];
    final alamatTempat = place?["alamatTempat"];
    final gambar1 = place?["gambar1"];

    if (namaTempat == null || alamatTempat == null || gambar1 == null) {
      // Handle the case when data is missing
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: await Future.delayed(const Duration(seconds: 1), () {
        return SizedBox(
          height: 225,
          child: GestureDetector(
            onTap: () async {
              var data = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTempat(place: place!),
                ),
              );

              /// Untuk await data, setelah kembali akan refresh page
              data ??= false;
              setState(() {

              });

            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                    child: Image.network(
                      gambar1,
                      height: 125,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(7, 10, 7, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 45,
                          child: Text(
                            namaTempat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey[700],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alamatTempat,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  List<DocumentSnapshot<Object?>> filterIsSaved(
      List<DocumentSnapshot> places) {

    return places
        .where((place) =>
    (place.data() as Map<String, dynamic>)["user_id"] == userId)
        .toList();
  }

}
