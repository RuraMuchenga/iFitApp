import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:firebase_signin/screens/equipment_availability_page.dart';

class DashboardScreen extends StatelessWidget {
  final String email;

  const DashboardScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
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
        child: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: getUserField(email, 'first_name'),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String username = snapshot.data.toString();
                    return Text(
                      "Welcome, $username!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 40),
              buildCard(
                icon: Icons.fitness_center,
                title: "Custom Workout Plan",
                onTap: () {
                  // Handle onTap action
                },
              ),
              SizedBox(height: 20),
              buildCard(
                icon: Icons.timeline,
                title: "Progress Summary",
                onTap: () {
                  // Handle onTap action
                },
              ),
              SizedBox(height: 20),
              buildCard(
                icon: Icons.list_alt_outlined,
                title: "Gym Equipment Availability",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EquipmentAvailabilityPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              buildCard(
                icon: Icons.chat,
                title: "Chat Room",
                onTap: () {
                  // Handle onTap action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getUserField(String userId, String fieldName) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');
      DocumentReference userDocRef = usersCollection.doc(userId);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      Map<String, dynamic>? userData =
          userDocSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey(fieldName)) {
        return userData[fieldName];
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user field: $e');
      return null;
    }
  }
}
