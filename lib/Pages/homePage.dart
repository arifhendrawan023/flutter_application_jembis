import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_jembis/Pages/detailTempat.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List _tempat = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/daftarTempat.json');
    final data = await json.decode(response);
    setState(() {
      _tempat = data["tempat"];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: <Widget>[
              Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Welcome to ",
                    style: TextStyle(fontSize: 28),
                  ),
                  Image(
                    image: AssetImage('assets/image/logo.png'),
                    width: 275,
                  ),
                  Text(
                      "Aplikasi kami membantu Anda menemukan informasi lengkap tentang berbagai destinasi wisata menarik di Jember."),
                  Container(
                    margin: EdgeInsets.only(top: 7, bottom: 7),
                    child: searchTempat(),
                  ),
                  Text(
                    "Rekomendasi Tempat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  rekomendasiTempat(tempat: _tempat),
                  Text(
                    "Semua Tempat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  cardTempat(tempat: _tempat),
                ],
              ),
            ),
            ],
          )
          // child: ListView(
          //   shrinkWrap: true,  physics: ClampingScrollPhysics(),
          //   scrollDirection: Axis.vertical,
          //   children: <Widget>[

          //   ],
          ),
    );
  }
}

Container menuButtonWisata(String text) {
  return Container(
    width: 90,
    margin: EdgeInsets.only(right: 7),
    child: ElevatedButton(
      child: Text(text),
      onPressed: () {}, // <-- Text
    ),
  );
}

class searchTempat extends StatelessWidget {
  const searchTempat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {},
      decoration: InputDecoration(
          labelText: "Destinasi Yang Ingin Dicari",
          hintText: "Tempat Mana Yang Ingin Anda Kunjungi",
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 7),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(11.0)))),
      style: TextStyle(fontSize: 15),
    );
  }
}

class cardTempat extends StatelessWidget {
  const cardTempat({
    super.key,
    required List tempat,
  }) : _tempat = tempat;

  final List _tempat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          _tempat.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _tempat.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      key: ValueKey(_tempat[index]["id"]),
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Card(
                          child: Image.asset(
                            _tempat[index]["gambar"],
                            height: 200,
                          ),
                        ),
                        title: Text(_tempat[index]["nama"]),
                        subtitle: Text(_tempat[index]["alamat"]),
                      ),
                    );
                  },
                ))
              : Container()
        ],
      ),
    );
  }
}

class rekomendasiTempat extends StatelessWidget {
  const rekomendasiTempat({
    super.key,
    required List tempat,
  }) : _tempat = tempat;

  final List _tempat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tempat.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.fromLTRB(0, 2, 2, 0),
            width: 175,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    _tempat[index]["gambar"],
                    height: 125,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return DetailTempat();
                            }));
                          },
                          child: Text(
                            _tempat[index]["nama"],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(height: 10,),
                        Text(
                          _tempat[index]["alamat"],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add a small space between the card and the next widget
                  Container(height: 5),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
