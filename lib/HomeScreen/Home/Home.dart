import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irc_ride_partner/HomeScreen/Home/CommunityEvents.dart';
import 'package:irc_ride_partner/HomeScreen/Home/LeaderBoard.dart';
import 'dart:async';

import 'package:irc_ride_partner/HomeScreen/Home/QuickStats.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            Quickstats(),
            Communityevents(),
            Leaderboard()
          ],
        )
    );
  }
}
