import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Quickstats extends StatefulWidget {
  const Quickstats({super.key});

  @override
  State<Quickstats> createState() => _QuickstatsState();
}

class _QuickstatsState extends State<Quickstats> {

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }
          // Check if data exists
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found!'));
          }
          // Extract user data
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          var first_name = userData['first_name'].toString();
          var solo_rides = userData['solo_rides'].toString();
          var group_rides = userData['group_rides'].toString();
          int km_travelled = userData['km_travelled'];
          var km_travelled_string = '0';

          if (km_travelled < 1000) {
            km_travelled_string = km_travelled.toString();
          } else {
            km_travelled_string =
            '${(km_travelled / 1000).toStringAsFixed(2)}K';
          }

          final List<Widget> quickStatItems = [
            _buildStatCard("SOLO RIDES", "${solo_rides}", Colors.orange, 0.5,
                Icons.motorcycle_rounded),
            _buildStatCard("GROUP RIDES", "${group_rides}", Colors.green, 0.7,
                Icons.groups_rounded),
            _buildStatCard("KILOMETERS", "${km_travelled_string}", Colors.blue,
                0.3, Icons.speed_rounded)
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Welcome message
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Welcome, " + first_name,
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ),
              //Quick Stats
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Stats", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 20)),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 150.0,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200.0,
                              child: quickStatItems[index],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildStatCard(
      String title, String value, Color color, double progress, IconData icon) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900)),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(icon),
                SizedBox(
                  width: 8.0,
                ),
                Text(title,
                    style:
                    TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300)),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            LinearProgressIndicator(
              value: progress,
              valueColor: AlwaysStoppedAnimation(color),
              borderRadius: BorderRadius.circular(10.0),
            )
          ],
        ),
      ),
    );
  }

}
