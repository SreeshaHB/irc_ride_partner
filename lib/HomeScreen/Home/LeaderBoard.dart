import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchRidersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final soloRides = data['solo_rides'] ?? 0;
        final groupRides = data['group_rides'] ?? 0;

        return{
          'id': doc.id,
          ...data,
          'totalRides': soloRides + groupRides,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: fetchRidersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No riders found.'));
          }

          final riders = snapshot.data!;
          // Find the top rider by total rides
          final topRider = riders.reduce((current, next) =>
          current['totalRides'] > next['totalRides'] ? current : next);

          return Padding(
              padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Leaderboard", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 20)),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            isThreeLine: true,
                            title: Text('${topRider['first_name'] ?? 'No Name'}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            subtitle: Text('TOP RIDER'),
                            leading: Icon(Icons.person_pin, size: 50.0,),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('${topRider['totalRides'] ?? 0}',
                              style: TextStyle(fontWeight: FontWeight.w800,),),
                            subtitle: Text('TOTAL RIDES'),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('${topRider['solo_rides'] ?? 0}',
                                style: TextStyle(fontWeight: FontWeight.w800,)
                            ),
                            subtitle: Text('SOLO RIDES'),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('${topRider['group_rides'] ?? 0}',
                                style: TextStyle(fontWeight: FontWeight.w800,)),
                            subtitle: Text('GROUP RIDES'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
  }
}
