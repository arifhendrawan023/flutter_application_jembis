import 'package:flutter/material.dart';
import 'package:flutter_application_jembis/Pages/aboutPage.dart';
import 'package:flutter_application_jembis/Pages/homePage.dart';
import 'package:flutter_application_jembis/Pages/listTempat.dart';
import 'package:flutter_application_jembis/Pages/weatherPage.dart';

class MyBottomNavBar extends StatefulWidget {
  final String displayName;
  final String photoURL;
  final String email;

  const MyBottomNavBar({
    Key? key,
    required this.displayName,
    required this.photoURL,
    required this.email,
  }) : super(key: key);

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;
  
  var place;
  
  var namaTempat;
  
  var koordinatTempat;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      homePage(photoURL: widget.photoURL, displayName: widget.displayName, email: widget.email),
      const WeatherPage(),
      const ListTempat(),
      AboutPage(photoURL: widget.photoURL, displayName: widget.photoURL, email: widget.email,),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List Place',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            backgroundColor: Colors.orange,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        onTap: _onItemTapped,
      ),
    );
  }
}
