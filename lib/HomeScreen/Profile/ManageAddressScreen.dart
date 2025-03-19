import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class Manageaddressscreen extends StatefulWidget {
  const Manageaddressscreen({super.key});

  @override
  State<Manageaddressscreen> createState() => _ManageaddressscreenState();
}

class _ManageaddressscreenState extends State<Manageaddressscreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  //controllers
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _addressLineOneController =
      TextEditingController();
  final TextEditingController _addressLineTwoController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  int _updtdttmController = 0;
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Address"),
        actions: [
          IconButton(onPressed: _updateAddress, icon: Icon(Icons.check))
        ],
      ),
      body: StreamBuilder(
        stream:
            _firebaseFirestore.collection('address').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching address data."));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No address data found."));
          }

          var userAddressData = snapshot.data!.data() as Map<String, dynamic>;

          if (!isInitialized) {
            _houseNumberController.text = userAddressData['house_number'] ?? '';
            _addressLineOneController.text =
                userAddressData['address_line1'] ?? '';
            _addressLineTwoController.text =
                userAddressData['address_line2'] ?? '';
            _cityController.text = userAddressData['city'] ?? '';
            _stateController.text = userAddressData['state'] ?? '';
            _countryController.text = userAddressData['country'] ?? '';
            _zipcodeController.text = userAddressData['zip_code'].toString();
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
                  TextFormField(
                    controller: _houseNumberController,
                    decoration: InputDecoration(
                      label: Text("House Number"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'House number cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _addressLineOneController,
                    decoration: InputDecoration(
                      label: Text("Address Line 1"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address line 1 cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _addressLineTwoController,
                    decoration: InputDecoration(
                      label: Text("Address Line 2"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address line 2 cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      label: Text("City"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      label: Text("State"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'State cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      label: Text("Country"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _zipcodeController,
                    decoration: InputDecoration(
                      label: Text("Zip Code"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zip code cannot be empty';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('address')
            .doc(userId)
            .update({
          'house_number': _houseNumberController.text,
          'address_line1': _addressLineOneController.text,
          'address_line2': _addressLineTwoController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'country': _countryController.text,
          'zip_code': int.parse(_zipcodeController.text),
          'updt_dt_tm': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address information updated successfully!')),
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
