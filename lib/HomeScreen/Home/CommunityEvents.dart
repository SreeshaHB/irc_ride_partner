import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Communityevents extends StatefulWidget {
  const Communityevents({super.key});

  @override
  State<Communityevents> createState() => _CommunityeventsState();
}

class _CommunityeventsState extends State<Communityevents> {

  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _cardData = []; // Holds data from Firestore

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_startAutoScroll();
    _fetchDataFromFirestore();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      //Fetch data from firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("community_events").get();

      //Map the elements to a list
      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
        return {
          "title": doc['event_name'],
          "subtitle": doc['location_name'],
          "event_dt": doc['event_start_dttm'],
          "event_end_dt": doc['event_end_dttm'],
          "max_riders": doc['max_riders'],
          "bg_image_url": doc['bg_image']
        };
      }).toList();

      if (mounted) {
        setState(() {
          _cardData = fetchedData;
        });

        if (_cardData.isNotEmpty) {
          _startAutoScroll();
        }
      }
    } catch(e) {
      print("Error fetching data: $e");
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _cardData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 1000),
          curve: Curves.fastEaseInToSlowEaseOut);
    });
  }

  String _checkEventStatus(Timestamp startDate, Timestamp endDate) {
    var startDttm = startDate.millisecondsSinceEpoch;
    var endDttm = endDate.millisecondsSinceEpoch;
    var currentDttm = DateTime.now().millisecondsSinceEpoch;

    if (currentDttm >= endDttm) {
      return "Completed";
    } else if (currentDttm <= startDttm) {
      return "Upcoming";
    } else if (currentDttm > startDttm && currentDttm < endDttm) {
      return "Ongoing";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Community Events", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 20)),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            height: 300.0,
            child: PageView.builder(
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(
                            _cardData[index]['bg_image_url'],
                          fit: BoxFit.fill,
                          height: 280.0,
                          width: double.infinity,
                        ),
                        ListTile(
                          subtitle: Text(_cardData[index]['subtitle'],
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)
                          ),
                          title: Text(_cardData[index]['title'],
                            style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
                          ),
                          isThreeLine: true,
                        ),
                        Positioned(
                            top: 0.0,
                          left: 0.0,
                            child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                                  child: Text(
                                      _checkEventStatus(_cardData[index]['event_dt'], _cardData[index]['event_end_dt'])),
                                ),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(10.0))
                              ),
                            ),
                        )
                      ],
                    ),
                  ],
                );
              },
              controller: _pageController,
              itemCount: _cardData.length,
            ),
          ),
        ],
      ),
    );
  }
}
