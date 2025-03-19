import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/RideDetail.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/RideInvitationScreen.dart';

class Rides extends StatefulWidget {
  const Rides({super.key});

  @override
  State<Rides> createState() => _RidesState();
}

class _RidesState extends State<Rides> {

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('rides').where(Filter.or(Filter('participants', arrayContains: userId), Filter('creatorId', isEqualTo: userId))).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No rides found'));
          }

          final rides = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("My Rides", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 20))),
                    FilledButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Rideinvitationscreen()));
                    }, child: Icon(Icons.notifications))
                  ],
                ),
                SizedBox(height: 20.0,),
                Expanded(
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rides.length,
                      itemBuilder: (context, index) {
                        final ride = rides[index].data();
                        final ride1 = rides[index];
                        return Card(
                          elevation: 0.0,
                          child: ListTile (
                            title: Text(ride['place']),
                            subtitle: Text('Status: ${ride['status']}\nStart: ${DateTime.fromMillisecondsSinceEpoch(ride['start_dt_tm']).toString()}'),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Ridedetail(currentUserId: userId, rideId: ride1.id,)));
                            },
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}
