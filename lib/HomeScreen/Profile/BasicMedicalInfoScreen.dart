import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Basicmedicalinfoscreen extends StatefulWidget {
  const Basicmedicalinfoscreen({super.key});

  @override
  State<Basicmedicalinfoscreen> createState() => _BasicmedicalinfoscreenState();
}

class _BasicmedicalinfoscreenState extends State<Basicmedicalinfoscreen> {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  //controllers
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _knownAllergiesController = TextEditingController();
  final TextEditingController _knownDiseasesController = TextEditingController();

  String _selectedBloodGroup = "";

  final List<String> _bloodGroups = [
    "",
    "A+",
    "A-",
    "AB+",
    "AB-",
    "B+",
    "B-",
    "O+",
    "O-",
  ];

  int _updtdttmController = 0;
  bool isInitialized = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Basic Health Info"),
        actions: [
          IconButton(
              onPressed: _updateBHI,
              icon: Icon(Icons.check)
          )
        ],
      ),
      body: StreamBuilder(
          stream: _firebaseFirestore.collection('basic_medical_info')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error fetching address data."));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("No BMI data found."));
            }

            var userBHIData = snapshot.data!.data() as Map<String, dynamic>;

            if (!isInitialized) {
              _bloodGroupController.text = userBHIData['blood_group'] ?? '';
              _knownAllergiesController.text =
                  userBHIData['known_allergies'] ?? '';
              _knownDiseasesController.text =
                  userBHIData['known_diseases'] ?? '';
              _selectedBloodGroup =
              _bloodGroups.contains(userBHIData['blood_group'])
                  ? userBHIData['blood_group']
                  : _bloodGroups.first;
              isInitialized = true;
            }

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),

                    //blood group drop down
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup.isNotEmpty
                          ? _selectedBloodGroup
                          : null,
                      items: _bloodGroups.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                          label: Text("Blood Group")
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value!;
                        });
                      },
                    ),

                    //known allergies
                    SizedBox(height: 20.0,),
                    TextFormField(
                      controller: _knownAllergiesController,
                      decoration: InputDecoration(
                        label: Text("Known Allergies"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Known allergies cannot be empty. Use "None" if not applicable.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.0,),
                    TextFormField(
                      controller: _knownDiseasesController,
                      decoration: InputDecoration(
                        label: Text("Known Allergies"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Known diseases cannot be empty. Use "None" if not applicable.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  void _updateBHI() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('basic_medical_info').doc(userId).update(
            {
              'blood_group': _selectedBloodGroup,
              'known_allergies': _knownAllergiesController.text,
              'known_diseases': _knownDiseasesController.text,
              'updt_dt_tm': DateTime
                  .now()
                  .millisecondsSinceEpoch,
            });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('BMI updated successfully!')),
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
