import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Vehiclegarage extends StatefulWidget {
  const Vehiclegarage({super.key});

  @override
  State<Vehiclegarage> createState() => _VehiclegarageState();
}

class _VehiclegarageState extends State<Vehiclegarage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  //controllers
  final TextEditingController _vehicleMake = TextEditingController();
  final TextEditingController _vehicleModel = TextEditingController();
  final TextEditingController _vehicleRegistrationNumber =
      TextEditingController();

  int _updtdttmController = 0;
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Garage"),
        actions: [
          IconButton(onPressed: _updateVehicleDetails, icon: Icon(Icons.check))
        ],
      ),
      body: StreamBuilder(
          stream: _firebaseFirestore
              .collection('vehicle_garage')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error fetching vehicle data."));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("No vehicle data found."));
            }

            var userVehicleData = snapshot.data!.data() as Map<String, dynamic>;

            if (!isInitialized) {
              _vehicleMake.text = userVehicleData['vehicle_make'] ?? '';
              _vehicleModel.text = userVehicleData['vehicle_model'] ?? '';
              _vehicleRegistrationNumber.text =
                  userVehicleData['vehicle_reg_number'] ?? '';
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
                      controller: _vehicleMake,
                      decoration: InputDecoration(
                        label: Text("Vehicle Make"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle make cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: _vehicleModel,
                      decoration: InputDecoration(
                        label: Text("Vehicle Model"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle model cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: _vehicleRegistrationNumber,
                      decoration: InputDecoration(
                        label: Text("Vehicle Registration Number"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle registration number cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _updateVehicleDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('vehicle_garage')
            .doc(userId)
            .update({
          'vehicle_make': _vehicleMake.text,
          'vehicle_model': _vehicleModel.text,
          'vehicle_reg_number': _vehicleRegistrationNumber.text,
          'updt_dt_tm': DateTime.now().millisecondsSinceEpoch
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle information updated successfully!')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vehicle: $error')),
        );
        print("Failed to update vehicle: $error");
      }
    }
  }
}
