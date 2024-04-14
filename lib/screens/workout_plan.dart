import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:firebase_signin/screens/generate_form.dart';

class WorkoutPlanPage extends StatelessWidget {
  final String email;

  const WorkoutPlanPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildCard(
              icon: Icons.auto_awesome,
              title: "Generate New Plan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateForm(email: email),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var userData = snapshot.data!.data();
                    if (userData != null &&
                        userData is Map<String, dynamic> &&
                        userData.containsKey('workout_plan')) {
                      var workoutPlan = userData['workout_plan'];
                      return ListView.builder(
                        itemCount: workoutPlan.length,
                        itemBuilder: (context, index) {
                          var exercise = workoutPlan[index];
                          var name = exercise['name'];
                          var time = exercise['time'].toString();
                          var reps = exercise['reps'] == 0
                              ? ''
                              : exercise['reps'].toString();
                          return WorkoutPlanTile(
                            name: name,
                            time: time,
                            reps: reps,
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('No workout plan data available'),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutPlanTile extends StatelessWidget {
  final String name;
  final String time;
  final String reps;

  const WorkoutPlanTile({
    required this.name,
    required this.time,
    required this.reps,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: $time'),
          Text('Reps: ${reps == '0' ? '' : reps}'),
        ],
      ),
    );
  }
}
