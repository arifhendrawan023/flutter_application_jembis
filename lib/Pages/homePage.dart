import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/Pages/detailTempat.dart';
import 'package:flutter_application_jembis/Pages/aboutPage.dart';
import 'package:flutter_application_jembis/services/firebase_service.dart';

class homePage extends StatefulWidget {
  final String displayName;
  final String photoURL;
  final String email;

  const homePage({
    Key? key,
    required this.displayName,
    required this.photoURL,
    required this.email,
  }) : super(key: key);

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  String filterType = '';
  bool showAll = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 75, 0, 0),
                        child: const Text(""),
                      ),
                      const Text(
                        "Hai,",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AboutPage(photoURL: widget.photoURL, displayName: widget.displayName, email: widget.email,);
                      }));
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.photoURL),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 0),
                child: const Text(
                  "Welcome to ",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              const Image(
                image: AssetImage('assets/image/logo.png'),
                width: 275,
              ),
              const SizedBox(height: 10),
              const Text(
                "Rekomendasi Tempat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseService.tempatWisata.get(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final places = snapshot.data?.docs ?? [];
                  final sortedPlaces = sortPlacesByLikes(places);
                  final limitedPlaces = sortedPlaces.take(4).toList();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final place in limitedPlaces)
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tempat Wisata",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAll = true;
                      });
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterType = '';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              filterType == '' ? Colors.blue : Colors.grey,
                        ),
                        child: const Text('Semua'),
                      ),
                    ),
                    Container(
                      width: 120,
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterType = 'Budaya';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filterType == 'Budaya'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: const Text('Budaya'),
                      ),
                    ),
                    Container(
                      width: 120,
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterType = 'Alam';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              filterType == 'Alam' ? Colors.blue : Colors.grey,
                        ),
                        child: const Text('Alam'),
                      ),
                    ),
                    Container(
                      width: 120,
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterType = 'Pemandian';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filterType == 'Pemandian'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: const Text('Pemandian'),
                      ),
                    ),
                    Container(
                      width: 120,
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterType = 'Edukasi';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filterType == 'Edukasi'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: const Text('Edukasi'),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseService.tempatWisata.get(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final places = snapshot.data?.docs ?? [];
                  final sortedPlaces = sortPlacesByLikes(places);
                  final filteredPlaces =
                      filterPlacesByType(sortedPlaces, filterType);
                  final limitedPlaces = showAll
                      ? filteredPlaces
                      : filteredPlaces.take(4).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final place in limitedPlaces)
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
            ],
          ),
        ),
      ),
    );
  }

  List<DocumentSnapshot> sortPlacesByLikes(List<DocumentSnapshot> places) {
    places
        .sort((a, b) => (b["jumlahSuka"] ?? 0).compareTo(a["jumlahSuka"] ?? 0));
    return places;
  }

  List<DocumentSnapshot> filterPlacesByType(
      List<DocumentSnapshot> places, String filterType) {
    if (filterType.isEmpty) {
      return places;
    }
    return places
        .where((place) =>
            (place.data() as Map<String, dynamic>)["jenisTempat"] == filterType)
        .toList();
  }

  Future<Widget> buildTempatTile(DocumentSnapshot place) async {
    final namaTempat = place["namaTempat"];
    final alamatTempat = place["alamatTempat"];
    final gambar1 = place["gambar1"];

    return SizedBox(
      width: 200,
      height: 225,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTempat(place: place),
            ),
          );
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
