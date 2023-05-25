import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const DetailTempat());

class DetailTempat extends StatefulWidget {
  const DetailTempat({super.key});

  @override
  State<DetailTempat> createState() => _DetailTempatState();
}

class _DetailTempatState extends State<DetailTempat> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Tembakau'),
        elevation: 2,
        backgroundColor: Color.fromARGB(255, 230, 92, 0),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Image(
                image: AssetImage("assets/image/tempatWisata/tembakau.png")),
          ),
          ListView(
            children: <Widget>[
                SizedBox(height: 213.0, width: double.infinity),
                Container(
                  padding: EdgeInsets.all(7),
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        width: 450,
                        height: 200,
                        child: Card(
                          elevation: 2,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target:
                                  LatLng(-8.158898070405021, 113.71454769293695),
                              zoom: 18.0,
                            ),
                            
                          ),
                        ),
                      ),
                      Text(
                        'Museum tembakau adalah salah satu wujud identitas Jember sebagai kota tembakau. Pengunjung bisa melihat berbagai literatur tembakau, miniatur gardu atak (tempat pengeringan tembakau), serta display daun tembakau dari berbagai jenis dan kualitas. Di museum tembakau ini juga bisa melihat tayangan diversifikasi produk tembakau yang belum banyak diketahui masyarakat luas.',
                        style: TextStyle(
                          fontSize: 15.0, 
                        ),textAlign: TextAlign.justify
                      ),
                    ],
                  ),
                ),
              ],
          ),
        ],
      ),
    );
  }
}
