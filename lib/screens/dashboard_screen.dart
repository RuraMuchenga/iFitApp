import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:firebase_signin/screens/equipment_availability_page.dart';
import 'package:firebase_signin/screens/progress.dart';
import 'package:firebase_signin/screens/workout_plan.dart';
import 'package:firebase_signin/screens/membership.dart';
import 'package:firebase_signin/screens/add_workout.dart';
import 'package:firebase_signin/screens/GroupChatRoom.dart';

class DashboardScreen extends StatelessWidget {
  final String email;

  const DashboardScreen({Key? key, required this.email}) : super(key: key);

  Future<String> getGym(String email) async {
    var gymName = '';
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    var doc = await users.doc(email).get();
    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
      if (map.containsKey('membership')) {
        gymName = map['membership']['gym'];
      }
    }
    return gymName;
  }

  void checkString(BuildContext context, Future<String> futureValue) async {
    String value = await futureValue;
    if (value.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Membership(email: email),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EquipmentAvailabilityPage(gym: value),
        ),
      );
    }
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
        child: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: getUserField(email, 'first_name'),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String username = snapshot.data.toString();
                    return Text(
                      "Welcome, $username!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
              buildCard(
                icon: Icons.fitness_center,
                title: "Custom Workout Plan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlanPage(email: email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.timeline,
                title: "Progress Summary",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgressPage(email: email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.list_alt_outlined,
                title: "Gym Equipment Availability",
                onTap: () {
                  var gymName = getGym(email);
                  // Check if the string is empty
                  checkString(context, gymName);
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.chat,
                title: "Chat Room",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatRoom(
                        chatRoomId: 'JjU7eCLofKEZVoODoBUT',
                        chatRoomTitle: 'iFit Studio Chat Room',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.add_circle_outline,
                title: "Add workout Details",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewForm(email: email),
                    ),
                  );
                },
              )
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
