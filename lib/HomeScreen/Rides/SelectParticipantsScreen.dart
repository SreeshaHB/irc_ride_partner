import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Selectparticipantsscreen extends StatefulWidget {
  final List<String> initiallySelectedParticipants;

  const Selectparticipantsscreen({Key? key, required this.initiallySelectedParticipants}): super(key: key);

  @override
  State<Selectparticipantsscreen> createState() => _SelectparticipantsscreenState();
}

class _SelectparticipantsscreenState extends State<Selectparticipantsscreen> {

  List<String> _selectedParticipants = [];
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // TODO: implement initState
    _selectedParticipants = List.from(widget.initiallySelectedParticipants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Riders"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context, _selectedParticipants);
              },
              icon: Icon(Icons.check)
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No users found'));
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userId = user.id;
                  final userName = user['user_name'];
                  final userFullName = user['first_name'] + " " + user['last_name'];
                  return CheckboxListTile(
                    title: Text(userName),
                    subtitle: Text(userFullName),
                    value: _selectedParticipants.contains(userId),
                    onChanged: (isSelected) {
                      setState(() {
                        if(isSelected == true) {
                          _selectedParticipants.add(userId);
                        } else {
                          _selectedParticipants.remove(userId);
                        }
                      });
                    },
                  );
                },
              itemCount: users.length,
            );
          }
      ),
    );
  }
}
