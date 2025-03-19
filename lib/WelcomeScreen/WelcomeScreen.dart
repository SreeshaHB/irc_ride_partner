import 'package:flutter/material.dart';
import 'package:irc_ride_partner/LoginScreen/LoginScreen.dart';

import '../RegisterScreen/Register.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(10.0),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IRC Ride Partner",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1),
                  ),
                  Text(
                    "Connect, Ride & Explore",
                    style: TextStyle(
                      fontSize: 32.0,
                      wordSpacing: 5,
                      letterSpacing: -2,
                    ),
                  ),
                  //SizedBox(height: 10.0,),
                  //Text("& Explore.", style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),),
                  Spacer(),
                  Row(
                    children: [
                      FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const Register()),
                            );
                          },
                          child: Text("Sign up")),
                      SizedBox(
                        width: 10.0,
                      ),
                      OutlinedButton(onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const Loginscreen())
                        );
                      }, child: Text("Log in")),
                    ],
                  ),
                  Spacer()
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
