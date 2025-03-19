import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/RideDetail.dart';
import 'package:irc_ride_partner/HomeScreen/Rides/RideInvitationScreen.dart';

class Ridedetail extends StatefulWidget {
  final String rideId;
  final String currentUserId;
  const Ridedetail({super.key, required this.currentUserId, required this.rideId});

  @override
  State<Ridedetail> createState() => _RidedetailState();
}

class _RidedetailState extends State<Ridedetail> {

  Map<String, dynamic>? rideData;
  List<Map<String, dynamic>> participantsData = [];
  String? creatorUserName;
  String? creatorName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchRideDetails();
    //_fetchCreator(widget.currentUserId);
  }

  Future<void> _fetchRideDetails() async {
    //print("Fetching ride details...");
    //Fetch ride details to display
    final rideDoc = await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).get();
    if (rideDoc.exists) {
      setState(() {
        rideData = rideDoc.data();
      });
      _fetchParticipants(rideData!['participants']);
      _fetchCreator(rideData!['creatorId']);
    }
  }

  _fetchCreator(String creatorId) async {
    //print("Fetching creator...");
    final creatorDoc = await FirebaseFirestore.instance.collection('users').doc(creatorId).get();
    if (creatorDoc.exists) {
      setState(() {
        creatorUserName = creatorDoc.data()?['user_name'] ?? "Noob rider";
        creatorName = creatorDoc.data()?['first_name'] + creatorDoc.data()?['last_name'] ?? "Noname rider";
      });
    }
  }

  Future<void> _fetchParticipants(List<dynamic> participantIds) async {
    //print("Fetching participants...");
    List<Map<String, dynamic>> fetchedParticipants = [];

    for (String userId in participantIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists){
        fetchedParticipants.add({
          'userId': userId,
          'userName': userDoc.data()?['user_name'] ?? "Noob rider",
          'name': userDoc.data()?['first_name'] +
              userDoc.data()?['last_name'] ?? "Noname rider"
        });
      }
    }

    setState(() {
      participantsData = fetchedParticipants;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (rideData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }

    //_fetchParticipants(rideData!['participants']);

    bool isCreator = rideData!['creatorId'] == widget.currentUserId;
    bool isParticipant = rideData!['participants'].contains(widget.currentUserId);
    final DateTime rideStartDateTime = DateTime.fromMillisecondsSinceEpoch(rideData!['start_dt_tm']);
    final DateTime rideEndDateTime = DateTime.fromMillisecondsSinceEpoch(rideData!['end_dt_tm']);

    return Scaffold(
      appBar: AppBar(title: Text("Ride details"),),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0,),
                Text("Ride name"),
                SizedBox(height: 10.0,),
                //ride name
                Card(
                  elevation: 0.0,
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("${rideData!['ride_name']}", style: TextStyle(fontSize: 16,),),
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),
                Text("Destination"),
                SizedBox(height: 10.0,),
                //ride name
                Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("${rideData!['place']}",),
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),
                Text("Date and time"),
                SizedBox(height: 10.0,),
                //ride name
                Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Starts at"),
                          subtitle: Text(
                            "${rideStartDateTime.day}-${rideStartDateTime.month}-${rideStartDateTime.year} at ${rideStartDateTime.hour}:${rideStartDateTime.minute}",),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("Ends at"),
                          subtitle: Text(
                            "${rideEndDateTime.day}-${rideEndDateTime.month}-${rideEndDateTime.year} at ${rideEndDateTime.hour}:${rideEndDateTime.minute}",),
                        ),
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 10.0,),
                Text("Created by"),
                SizedBox(height: 10.0,),
                //ride name
                Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("${creatorName}",),
                      subtitle: Text("${creatorUserName}"),
                    ),
                  ),
                ),


                SizedBox(height: 10.0,),
                Text("Participants info"),
                SizedBox(height: 10.0,),
                //ride name
                Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("Total number of participants",),
                      subtitle: Text("${participantsData.length}"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
