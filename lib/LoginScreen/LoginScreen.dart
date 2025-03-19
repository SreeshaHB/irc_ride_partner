import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Utils/Reusable.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
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
                    child: Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Please login with your email id and password",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  reusableTextField("Email id", false, _emailIdController,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return "Email cannot be empty";
                    } else if (!RegExp(r"^[^@]+@[^@]+\.[^@]+")
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  }),
                  SizedBox(
                    height: 10.0,
                  ),
                  reusableTextField("Password", true, _passwordController,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return "Password cannot be empty";
                    }
                    return null;
                  }),
                  Spacer(),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _signInUser,
                      child: Text('Log in'),
                      style: TextButton.styleFrom(
                          minimumSize: Size(double.infinity, 50), elevation: 0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailIdController.text.trim();
        final password = _passwordController.text.trim();

        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
        );

        Navigator.pushReplacementNamed(context, '/auth');
      } on FirebaseAuthException catch(e) {
        print(e.code);
        String message;
        if (e.code == "invalid-credential") {
          message = 'User does not exist or incorrect password.';
        } else {
          message = 'Something went wrong';
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
      }
    }
  }
}
