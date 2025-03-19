import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:irc_ride_partner/HomeScreen/Profile/BasicMedicalInfoScreen.dart';
import 'package:irc_ride_partner/HomeScreen/Profile/ManageAddressScreen.dart';
import 'package:irc_ride_partner/HomeScreen/Profile/PersonalInformationScreen.dart';
import 'package:irc_ride_partner/HomeScreen/Profile/VehicleGarage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _firestore.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching profile data."));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No profile data found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //main profile
                    Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(userData['first_name'] + " " + userData['last_name']),
                          subtitle: Text(userData['email']),
                          leading: CircleAvatar(
                            child: Text(userData['first_name'].toString().substring(0,1) + userData['last_name'].toString().substring(0,1)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Text("Personal information"),
                    SizedBox(height: 10.0,),
                    //personal information card
                    Card(
                      elevation: 0.0,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text("Personal Information"),
                              subtitle: Text("Manage your personal information like Name, Date of birth, Contact number etc."),
                              trailing: Icon(Icons.navigate_next),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Personalinformationscreen()
                                    )
                                );
                              },
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Address"),
                              subtitle: Text("Manage your address."),
                              trailing: Icon(Icons.navigate_next),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Manageaddressscreen())
                                );
                              },
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Basic Medical Information"),
                              subtitle: Text("Manage your BMI like Blood Group, Known Allergies and Known Diseases."),
                              trailing: Icon(Icons.navigate_next),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Basicmedicalinfoscreen())
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0,),
                    Text("Vehicle"),
                    SizedBox(height: 10.0,),
                    //vehicle card
                    Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text("Vehicle Garage"),
                              subtitle: Text("Add or manage your vehicles."),
                              trailing: Icon(Icons.navigate_next),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Vehiclegarage())
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0,),
                    Text("Settings"),
                    SizedBox(height: 10.0,),
                    //settings card
                    Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text("Account Settings"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Notifications"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Privacy Policy"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("About"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    //sign out card
                    ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushReplacementNamed(context, '/auth');
                        },
                        child: Text("Sign out"),
                        style: TextButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        elevation: 0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }


}
