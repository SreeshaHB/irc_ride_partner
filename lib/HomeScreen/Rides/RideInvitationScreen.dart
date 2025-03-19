import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Rideinvitationscreen extends StatefulWidget {
  const Rideinvitationscreen({super.key});

  @override
  State<Rideinvitationscreen> createState() => _RideinvitationscreenState();
}

class _RideinvitationscreenState extends State<Rideinvitationscreen> {

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride Invitations"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Center(child: Text('No invitations found'));
            }

            final user = snapshot.data!.data() as Map<String, dynamic>;
            final invitedRides = user['invited_rides'] as List<dynamic>? ?? [];

            if (invitedRides.isEmpty) {
              return Center(child: Text('No invitations found'));
            }

            return ListView.builder(
              itemCount: invitedRides.length,
                itemBuilder: (context, index) {
                  final rideId = invitedRides[index];

                  return FutureBuilder(
                      future: FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(title: Text('Loading...'));
                        }

                        if (!snapshot.hasData || snapshot.data!.data() == null) {
                          return ListTile(title: Text('Ride not found'));
                        }

                        final ride = snapshot.data!.data() as Map<String, dynamic>;
                        final creatorId = ride['creatorId'];

                        return FutureBuilder(
                          future: FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
                          builder: (context, creatorSnapshot) {
                            if (creatorSnapshot.connectionState == ConnectionState.waiting) {
                              return ListTile(title: Text('Loading...'));
                            }

                            if (!creatorSnapshot.hasData || creatorSnapshot.data!.data() == null) {
                              return ListTile(title: Text('Creator not found'));
                            }
                            final creator = creatorSnapshot.data!.data() as Map<String, dynamic>;
                            final creatorName = creator['first_name'] + " " + creator['last_name'];
                            return ListTile(
                              title: Text("Ride invitation to ${ride['place']} by ${creatorName}"),
                              subtitle: Text("Ride on ${DateTime.fromMillisecondsSinceEpoch(ride['start_dt_tm']).toString()}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _respondToInvitation(userId, rideId, true),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _respondToInvitation(userId, rideId, false),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                  );
                },
            );
          }
      ),
    );
  }

  Future<bool> _checkForConflicts(String userId, String rideId) async {
    //Fetch the ride details
    final rideDoc = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
    if(!rideDoc.exists) return false;
    final rideData = rideDoc.data()!;
    final rideStart = DateTime.fromMillisecondsSinceEpoch(rideData['start_dt_tm']);
    final rideEnd = DateTime.fromMillisecondsSinceEpoch(rideData['end_dt_tm']);

    //fetch the users rides
    final userRidesSnapshot = await FirebaseFirestore.instance.collection('rides')
        .where(Filter.and(Filter('participants', arrayContains: userId), Filter(FieldPath.documentId, isNotEqualTo: rideId))).get();

    for (var doc in userRidesSnapshot.docs) {
      // Skip the current ride
      final ride = doc.data();
      final existingStart = DateTime.fromMillisecondsSinceEpoch(ride['start_dt_tm']);
      final existingEnd = DateTime.fromMillisecondsSinceEpoch(ride['end_dt_tm']);

      // Check for time overlap
      if (rideStart.isBefore(existingEnd) && rideEnd.isAfter(existingStart)) {
        return true; // Conflict detected
      }
    }

    return false; // No conflict
  }

  Future<void> _respondToInvitation(String userId, String rideId, bool accept) async {
    if(accept) {
      // Check for conflicting rides
      final hasConflict = await _checkForConflicts(userId, rideId);
      //auto reject upon conflict
      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already have a planned ride during this time.')),
        );

        // Automatically reject this invitation
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'invited_rides': FieldValue.arrayRemove([rideId]),
        });
        await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
          'participants': FieldValue.arrayRemove([userId]),
        });

        return;
      }

      await FirebaseFirestore.instance.collection('rides').doc(rideId).update(
          {
            'participants': FieldValue.arrayUnion([userId]),
          });
    } else if (accept == false) {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    }
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'invited_rides': FieldValue.arrayRemove([rideId]),
    });
  }

}
