import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/Pages/detailTempat.dart';
import 'package:flutter_application_jembis/services/firebase_service.dart';

class ListTempat extends StatefulWidget {
  const ListTempat({Key? key}) : super(key: key);

  @override
  State<ListTempat> createState() => _ListTempatState();
}

class _ListTempatState extends State<ListTempat> {
  String filterType = '';
  bool showAll = false; // Track whether to show all cards or limit to 4

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempat Wisata'),backgroundColor: Colors.orange,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                        backgroundColor:
                            filterType == 'Budaya' ? Colors.blue : Colors.grey,
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
                        backgroundColor:
                            filterType == 'Pemandian' ? Colors.blue : Colors.grey,
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
                        backgroundColor:
                            filterType == 'Edukasi' ? Colors.blue : Colors.grey,
                      ),
                      child: const Text('Edukasi'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseService.tempatWisata.get(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final places = snapshot.data?.docs ?? [];
                  final sortedPlaces = sortPlacesByLikes(places);
                  final filteredPlaces =
                      filterPlacesByType(sortedPlaces, filterType);
      
                  return GridView.count(
                    crossAxisCount: 2, // Display 2 cards in each row
                    padding: const EdgeInsets.only(top: 0),
                    children: [
                      for (final place in filteredPlaces)
                        FutureBuilder<Widget>(
                          future: buildTempatTile(place),
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return snapshot.data!;
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
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
      return places; // Return all places if filter is empty
    }
    return places
        .where((place) =>
            (place.data() as Map<String, dynamic>)["jenisTempat"] == filterType)
        .toList();
  }

  Future<Widget> buildTempatTile(DocumentSnapshot place) async {
  final namaTempat = place["namaTempat"];
  final gambar1 = await _getImageUrl(place["gambar1"]);

  return SizedBox(
    child: GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTempat(place: place),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(4, 5, 4, 5),
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
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

Future<String> _getImageUrl(String imageUrl) async {
  // Simulating an asynchronous delay
  await Future.delayed(const Duration(seconds: 2));
  
  return imageUrl;
}

}
