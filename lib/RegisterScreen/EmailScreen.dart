import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irc_ride_partner/AuthService/AuthService.dart';
import 'package:irc_ride_partner/HomeScreen/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Utils/Reusable.dart';

class Emailscreen extends StatefulWidget {
  final String firstName;
  final String lastname;
  const Emailscreen({super.key, required this.firstName, required this.lastname});


  @override
  State<Emailscreen> createState() => _EmailscreenState();
}

class _EmailscreenState extends State<Emailscreen> {

  final _authService = AuthService();

  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: SizedBox.expand(
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("Thanks, " + widget.firstName + ".", style: Theme.of(context).textTheme.headlineMedium,),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("Now please provide your email and create a password for your new account.", style: Theme.of(context).textTheme.labelLarge,),
                    ),
                    SizedBox(height: 10.0,),
                    reusableTextField("Email id", false, _emailIdController, (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      } else if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    }),
                    SizedBox(height: 10.0,),
                    reusableTextField("Password", true, _passwordController, (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      } else if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      }
                      return null;
                    }),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: _signUpUser,
                        child: Text('Sign up'),
                        style: TextButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            elevation: 0
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      ),
      appBar: AppBar(
        //title: Text("Register"),
        leading: BackButton(),
      ),
    );
  }

  Future<void> _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailIdController.text.trim();
        final password = _passwordController.text.trim();
        final fName = widget.firstName.trim();
        final lName = widget.lastname.trim();
        final defaultDob = DateTime.now().millisecondsSinceEpoch;
        final dtTmNow = DateTime.now().millisecondsSinceEpoch;

        //Firebase Registration

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password
        );

        //Save additional user details in firebase firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
          {
            'email': email,
            'user_name':'',
            'first_name': fName,
            'last_name': lName,
            'dob': defaultDob,
            'phone': '',
            'has_bike': true,
            'bike': '',
            'solo_rides': 0,
            'group_rides': 0,
            'km_travelled': 0,
            'badges': '',
            'gender': '',
            'created_dt_tm': dtTmNow,
            'update_dt_tm': dtTmNow,
          }
        );

        //Save/create address model

        await FirebaseFirestore.instance.collection('address').doc(userCredential.user!.uid).set(
            {
              'city': '',
              'house_number': '',
              'address_line1': '',
              'address_line2': '',
              'state': '',
              'country': '',
              'zip_code': 0,
              'created_dt_tm': dtTmNow,
              'update_dt_tm': dtTmNow,
            }
        );

        await FirebaseFirestore.instance.collection('basic_medical_info').doc(userCredential.user!.uid).set(
            {
              'blood_group': '',
              'known_allergies': 'None',
              'known_diseases': 'None',
              'created_dt_tm': dtTmNow,
              'update_dt_tm': dtTmNow,
            }
        );

        //Navigate to new screen
        Navigator.pushReplacementNamed(context, '/auth');

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = "The email is already in use by another account.";
        } else if (e.code == 'weak-password') {
          message = "The password is too weak.";
        } else {
          message = "Registration failed. Please try again.";
        }
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Error"),
              content: Text(message),
              actions: [
                TextButton(onPressed:  () => Navigator.pop(context), child: Text("OK"))
              ],
            )
        );
      } finally {
        setState(() {
          _isLoading: false;
        });
      }
    }
  }
}
