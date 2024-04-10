import 'package:firebase_signin/screens/dashboard_screen.dart';
import 'package:firebase_signin/screens/membership_options_screen.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Membership extends StatelessWidget {
  final String email;
  const Membership({Key? key, required this.email}) : super(key: key);

  Future<List<String>> getDocumentIds() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('Gyms');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get document IDs
    List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
    return documentIds;
  }

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
              child: FutureBuilder<List<String>>(
                future:
                    getDocumentIds(), // Call the function to get document IDs
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final documentIds = snapshot.data!;
                  return ListView.builder(
                    itemCount: documentIds.length,
                    itemBuilder: (context, index) {
                      final documentId = documentIds[index];
                      return buildCard(
                        icon: Icons.fitness_center_outlined,
                        title: documentId, // Use document ID as title
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembershipOptionsScreen(
                                  gymName:
                                      documentId, // Pass document ID as gymName
                                  email: email),
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
              icon: Icons.arrow_forward_ios_outlined,
              title: "Skip",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DashboardScreen(email: email)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
