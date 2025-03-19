

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class Personalinformationscreen extends StatefulWidget {
  const Personalinformationscreen({super.key});

  @override
  State<Personalinformationscreen> createState() => _PersonalinformationscreenState();
}

class _PersonalinformationscreenState extends State<Personalinformationscreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  int? dob;

  String _selectedValue = "Male";

  DateTime selectedDate = DateTime.now();

  //controllers
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _dobTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();
  bool isInitialized = false;

  final List<String> _gender = [
    "Male",
    "Female",
    "Not to specify",
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder(
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

            if(!isInitialized) {
              _fNameController.text = userData['first_name'] ?? '';
              _lNameController.text = userData['last_name'] ?? '';
              _phoneTextController.text = userData['phone'] ?? '';
              _selectedValue =  _gender.contains(userData['gender']) ? userData['gender'] : _gender.first;
              dob = dob ?? userData['dob'];
              isInitialized = true;
              selectedDate = DateTime.fromMillisecondsSinceEpoch(dob!);
            }

            return Padding(
                padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                  child: ListView(
                    children: [
                      SizedBox(height: 20.0,),
                      TextFormField(
                        controller: _fNameController,
                        decoration: InputDecoration(
                          label: Text("First Name"),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        controller: _lNameController,
                        decoration: InputDecoration(
                          label: Text("Last Name"),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0,),
                      DropdownButtonFormField<String>(
                          value: _selectedValue.isNotEmpty ? _selectedValue : null,
                          items: _gender.map((model){
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                              label: Text("Gender")
                            ),
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value!;
                            });
                        },
                      ),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        initialValue: "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                        onTap: () async {
                          final DateTime? dateTime = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            initialDate: selectedDate
                          );
                          if (dateTime != null) {
                            setState(() {
                              selectedDate = dateTime;
                              dob = selectedDate.millisecondsSinceEpoch;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          label: Text("Date of birth")
                        ),
                      ),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        controller: _phoneTextController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          label: Text("Phone number"),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number cannot be empty';
                          }
                          return null;
                        },
                      ),

                    ],
                  )
              )
            );
          }
      ),
      appBar: AppBar(
        title: Text("Manage Personal Info"),
        actions: [
          IconButton(
              onPressed: _updateProfile,
              icon: Icon(Icons.check)
          )
        ],
      ),
    );
  }

  void _updateProfile() async{
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'first_name': _fNameController.text,
          'last_name': _lNameController.text,
          'gender': _selectedValue,
          'dob': dob,
          'phone': _phoneTextController.text,
          'updt_dt_tm': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Personal information updated successfully!')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
        print("Failed to update profile: $error");
      }
    }

  }
}
