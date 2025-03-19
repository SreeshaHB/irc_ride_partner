import 'package:flutter/material.dart';
import 'package:irc_ride_partner/RegisterScreen/EmailScreen.dart';
import 'package:irc_ride_partner/Utils/Reusable.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
            child: Container(
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("What's your name", style: Theme.of(context).textTheme.headlineMedium,),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("Please provide your first and last name.", style: Theme.of(context).textTheme.labelLarge,),
                    ),
                    SizedBox(height: 10.0,),
                    reusableTextField("First name", false, _firstNameController, (value){
                      if (value == null || value.isEmpty) {
                        return "First name cannot be empty";
                      }
                      return null;
                    }),
                    SizedBox(height: 10.0,),
                    reusableTextField("Last name", false, _lastNameController, (value) {
                      if (value == null || value.isEmpty) {
                        return "Last name cannot be empty";
                      }
                      return null;
                    }),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Emailscreen(firstName: _firstNameController.text, lastname: _lastNameController.text,)),
                            );
                          }
                        },
                        child: Text('Continue'),
                        style: TextButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          elevation: 0,
                        ),
                      ),
                    )
                  ],
                ),
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
}

