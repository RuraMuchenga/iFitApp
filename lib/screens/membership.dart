import 'package:firebase_signin/screens/dashboard_screen.dart';
import 'package:firebase_signin/screens/home_screen.dart';
import 'package:firebase_signin/screens/MembershipOptionsScreen.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Membership extends StatelessWidget {
  final String username;
  const Membership({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Choose a gym & membership if you like:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200, // Adjust the height of the list as needed
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Gyms').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return buildCard(
                        icon: Icons.fitness_center_outlined,
                        title: document['title'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembershipOptionsScreen(
                                  gymName: document['title'],
                                  username: username),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            buildCard(
              icon: Icons.chat,
              title: "Chat Room",
              onTap: () {
                // Handle onTap action
              },
            ),
            buildCard(
              icon: Icons.arrow_forward_ios_outlined,
              title: "Skip",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DashboardScreen(username: username)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
