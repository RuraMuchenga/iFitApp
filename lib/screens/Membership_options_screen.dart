import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:intl/intl.dart';
import 'package:firebase_signin/screens/dashboard_screen.dart';

class MembershipOptionsScreen extends StatefulWidget {
  final String gymName;
  final String email;

  const MembershipOptionsScreen({
    Key? key,
    required this.gymName,
    required this.email,
  }) : super(key: key);

  @override
  _MembershipOptionsScreenState createState() =>
      _MembershipOptionsScreenState();
}

class _MembershipOptionsScreenState extends State<MembershipOptionsScreen> {
  late List<dynamic> _subOptions;

  @override
  void initState() {
    super.initState();
    _fetchMembershipOptions();
  }

  Future<void> _fetchMembershipOptions() async {
    try {
      // Get a reference to the document
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Gyms')
          .doc(widget.gymName)
          .get();

      setState(() {
        // Retrieve membership options from the document snapshot
        _subOptions = snapshot['sub_options'];
      });
    } catch (e) {
      // Handle any errors
      print('Error retrieving document snapshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gymName} Membership Options'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _subOptions != null && _subOptions.isNotEmpty
                ? ListView.builder(
                    itemCount: _subOptions.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildCard(
                            icon: Icons.fitness_center_outlined,
                            title: _subOptions[index]['name'],
                            subtitle:
                                'Duration: ${_subOptions[index]['duration']}\t\t\tPrice: ${_subOptions[index]['price']}',
                            onTap: () {
                              // Handle onTap action if needed
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _updateMembership(_subOptions[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                    email: widget.email,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Choose'),
                          ),
                        ],
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          )
        ],
      ),
    );
  }

  Future<void> _updateMembership(Map<String, dynamic> subOption) async {
    try {
      DateTime currentDate = DateTime.now();
      int durationInMonths = int.parse(subOption['duration']);
      DateTime validUntil =
          currentDate.add(Duration(days: durationInMonths * 30));
      String formattedDate = DateFormat('yyyy-MM-dd').format(validUntil);

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(widget.email);

      await userDocRef.update({
        'membership': {
          'gym': widget.gymName,
          'last_date': formattedDate,
        },
      });

      print('Membership updated successfully!');
    } catch (e) {
      print('Error updating membership: $e');
    }
  }
}
