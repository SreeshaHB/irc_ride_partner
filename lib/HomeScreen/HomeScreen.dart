import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:irc_ride_partner/HomeScreen/Community/Community.dart';
import 'package:irc_ride_partner/HomeScreen/Home/Home.dart';
import 'package:irc_ride_partner/HomeScreen/Profile/Profile.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/CreateRide.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/Rides.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  int _currentIndex = 0;

  //List of screens for each tab
  final List<Widget> _screens = [
    Home(),
    Rides(),
    Community(),
    Profile(),
  ];

  // List of navigation bar items
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.motorcycle),
      label: 'Rides',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.groups_outlined),
      label: 'Community',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IRC Ride Partner"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.person_2_outlined))
        ],
      ),
      body: _screens[_currentIndex], //Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,//Track the current index
          onTap: (index) {
          setState(() {
            _currentIndex=index; // Update the index when a tab is tapped
          });
          },
          items: _navItems,
        type: BottomNavigationBarType.fixed, // Ensures all items are displayed
        backgroundColor: Colors.white, // Bar background color
        selectedItemColor: Colors.orange, // Active item color
        unselectedItemColor: Colors.grey, // Inactive item color
        selectedFontSize: 14, // Font size for active items
        unselectedFontSize: 12, // Font size for inactive items
        elevation: 10, // Shadow elevation
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Createride()),
            );
          },
        child: Icon(Icons.add),
      ),
    );
  }


}
