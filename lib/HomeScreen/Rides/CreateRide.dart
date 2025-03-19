import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'SelectParticipantsScreen.dart';

class Createride extends StatefulWidget {
  const Createride({super.key});

  @override
  State<Createride> createState() => _CreaterideState();
}

class _CreaterideState extends State<Createride> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _rideNameController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<String> _selectedParticipants = [];
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ride Planner"),),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _rideNameController,
                  decoration: InputDecoration(labelText: 'Ride Name', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a name';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _placeController,
                  decoration: InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a destination';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 0.0,
                  child: ListTile(
                    title: Text('Trip Start'),
                    subtitle: Text(_startDateTime == null ? 'Select start date & time': '${_startDateTime.toString()}'),
                    trailing: Icon(Icons.calendar_month_rounded),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                      );
                      if(date!=null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _startDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 16,),
                Card(
                  elevation: 0.0,
                  child: ListTile(
                    title: Text('Trip End'),
                    subtitle: Text(_endDateTime == null ? 'Select end date & time': '${_endDateTime.toString()}'),
                    trailing: Icon(Icons.calendar_month_rounded),
                    onTap: () async {
                      if (_startDateTime != null || _startDateTime == "Select start date & time") {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _startDateTime ?? DateTime.now(),
                          firstDate: _startDateTime ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if(date!=null) {
                          TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now()
                          );
                          if(time!=null) {
                            setState(() {
                              _endDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                          if (_endDateTime!.millisecondsSinceEpoch < _startDateTime!.millisecondsSinceEpoch) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Trip end date & time cannot be earlier than trip start date & time. Defaulting to current time.')),
                            );
                            setState(() {
                              _endDateTime = DateTime(date.year, date.month, date.day, TimeOfDay.now().hour, TimeOfDay.now().minute);
                            });
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select the trip start date & time first!')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 0.0,
                  child: ListTile(
                    title: Text('Select Riders'),
                    trailing: Icon(Icons.groups_rounded),
                    subtitle: Text(_selectedParticipants.length.toString() + " participants selected"),
                    onTap: () async {
                      final selected  = await Navigator.push<List<String>>(context, MaterialPageRoute(builder: (context) => Selectparticipantsscreen(
                        initiallySelectedParticipants: _selectedParticipants,
                      )));
                      if (selected != null) {
                        setState(() {
                          _selectedParticipants = selected;
                        });
                      }
                    }
                  ),
                ),
                SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _createRide,
                  child: Text('Create Ride'),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
  
  Widget _selectedRidersWidget(List<String> _selectedRidersList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _selectedRidersList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Chip(label: Text("text"));
        }
    );
  }

  Future<bool> _checkForConflicts(String userId, DateTime startDtTm, DateTime endDtTm) async {

    //print("Checking for conflicts");

    //fetch start and end date and time
    final newRideStart = startDtTm;
    final newRideEnd = endDtTm;

    //fetch the users rides
    final userRidesSnapshot = await FirebaseFirestore.instance.collection('rides')
        .where(Filter.or(Filter('participants', arrayContains: userId), Filter('creatorId', isEqualTo: userId)))
        .get();

    for (var doc in userRidesSnapshot.docs) {
      final ride = doc.data();
      final existingStart = DateTime.fromMillisecondsSinceEpoch(ride['start_dt_tm']);
      final existingEnd = DateTime.fromMillisecondsSinceEpoch(ride['end_dt_tm']);
      final existingRideName = ride['ride_name'];
      //print("Checking with ride: ${existingRideName}");
      // Check for time overlap

      if (newRideStart.isBefore(existingEnd) && newRideEnd.isAfter(existingStart)) {
        //print("Conflicting ride name: ${existingRideName}");
        return true;
      }
    }

    return false; // No conflict
  }


  void _createRide() async {
    if(_formKey.currentState!.validate()) {
      final hasConflict = await _checkForConflicts(userId, _startDateTime!, _endDateTime!);
      if(_startDateTime == null || _startDateTime == "Select start date & time") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Trip start date cannot be empty!')));
      } else if (_endDateTime == null || _endDateTime == "Select end date & time") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Trip end date cannot be empty!')));
      } else if (hasConflict) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('This ride potentially conflicts with one of your planned rides!')));
      } else if (_endDateTime!.isBefore(_startDateTime!) || _startDateTime!.isAfter(_endDateTime!)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please review trip start/end date time!')));
      } else {
        try {
          DocumentReference rideRef = await FirebaseFirestore.instance.collection('rides').add({
            'creatorId': FirebaseAuth.instance.currentUser!.uid,
            'start_dt_tm': _startDateTime?.millisecondsSinceEpoch,
            'end_dt_tm': _endDateTime?.millisecondsSinceEpoch,
            'participants': _selectedParticipants,
            'place': _placeController.text,
            'ride_name': _rideNameController.text,
            'status': 'Planned',
            'create_dt_tm': DateTime.now().millisecondsSinceEpoch,
            'updt_dt_tm': DateTime.now().millisecondsSinceEpoch,
          });

          //Send invitations
          for (String participantId in _selectedParticipants) {
            await FirebaseFirestore.instance.collection('users').doc(participantId).update(
                {
                  'invited_rides': FieldValue.arrayUnion([rideRef.id]),
                });
          }
          if(_selectedParticipants.length > 1) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Ride created! But you can start the ride only upon successful reply from the selected participants.')));
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ride created successfully.')));
        } on Exception catch (e) {
          // TODO
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e}")));
        }
        Navigator.pop(context);
      }
    }
  }
}
