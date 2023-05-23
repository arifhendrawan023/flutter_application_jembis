import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

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
    // Call the readJson method when the app starts
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text("Jember Keren")),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Selamat Datang, Arif!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic)),
              Text(
                  "Aplikasi kami membantu Anda menemukan informasi lengkap tentang berbagai destinasi wisata menarik di Jember."),
              Container(
                margin: EdgeInsets.only(top: 7, bottom: 7),
                child: searchTempat(),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    menuButtonWisata('Semua'),
                    menuButtonWisata('Budaya'),
                    menuButtonWisata('Sejarah'),
                    menuButtonWisata('Alam'),
                    menuButtonWisata('Fesitaval'),
                    menuButtonWisata('Religi'),
                  ],
                ),
              ),
              Text("Rekomendasi Tempat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              cardTempat(tempat: _tempat)
            ],
          ),
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
              borderRadius:
                  BorderRadius.all(Radius.circular(11.0)))),
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
      height: 100.0*_tempat.length,
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
                        leading: Text(_tempat[index]["id"]),
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
