import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPage extends StatelessWidget {
  final String email;

  const ProgressPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  userData.containsKey('progress')) {
                var progress = userData['progress'] as List<dynamic>;
                if (progress.isEmpty) {
                  return const Center(
                    child: Text('No progress data available'),
                  );
                }
                return ListView.builder(
                  itemCount: progress.length,
                  itemBuilder: (context, index) {
                    var progressData = progress[index];
                    var date = progressData.keys.first;
                    var exercises = progressData[date] as List<dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            var exercise =
                                exercises[index] as Map<String, dynamic>;
                            var name = exercise['exercise'];
                            var time = exercise['time'] ?? 0;
                            var reps = exercise['reps'] ?? 0;

                            return ProgressTile(
                              email: email,
                              name: name,
                              time: time,
                              reps: reps,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No progress data available'),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseDialog(context),
        label: const Text('Add New Exercise'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController exerciseNameController =
        TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseNameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
              ),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Time (minutes)'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String exerciseName = exerciseNameController.text.trim();
                final String timeText = timeController.text;
                final String repsText = repsController.text;

                final int time = int.tryParse(timeText) ?? 0;
                final int reps = int.tryParse(repsText) ?? 0;

                if (exerciseName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Exercise name cannot be empty")),
                  );
                  return;
                }

                // Add the new exercise to the progress document
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .update({
                  'progress': FieldValue.arrayUnion([
                    {
                      'exercise': exerciseName,
                      'time': time,
                      'reps': reps,
                    }
                  ]),
                });

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class ProgressTile extends StatelessWidget {
  final String email;
  final String name;
  final int time;
  final int reps;

  const ProgressTile({
    required this.email,
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
          Text('Time: $time mins'),
          Text('Reps: $reps'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _updateReps(context, reps - 1),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _updateReps(context, reps + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateReps(BuildContext context, int newReps) {
    if (newReps < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reps cannot be negative')),
      );
      return;
    }

    int deltaReps = newReps - reps;
    int newTime = time + (2 * deltaReps);

    FirebaseFirestore.instance.collection('Users').doc(email).update({
      'progress': FieldValue.arrayUnion([
        {
          'exercise': name,
          'time': newTime,
          'reps': newReps,
        }
      ]),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reps updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reps: $error')),
      );
    });
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ProgressPage extends StatelessWidget {
//   final String email;

//   const ProgressPage({Key? key, required this.email}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Progress'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('Users')
//               .doc(email)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               var userData = snapshot.data!.data();
//               if (userData != null &&
//                   userData is Map<String, dynamic> &&
//                   userData.containsKey('progress')) {
//                 var progress = userData['progress'];
//                 if (progress.isEmpty) {
//                   return const Center(
//                     child: Text('No progress data available'),
//                   );
//                 }
//                 var firstProgress = progress;
//                 print(firstProgress);
//                 return ListView.builder(
//                   itemCount: progress.length,
//                   itemBuilder: (context, index) {
//                     var date = progress.keys.toList()[index];
//                     var exercises = progress[date];
//                     print(exercises);
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date: $date',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const ClampingScrollPhysics(),
//                           itemCount: exercises.length,
//                           itemBuilder: (context, index) {
//                             var exercise = exercises[index];
//                             print("Printing ex");
//                             print(exercise);
//                             var name = exercise['name'];
//                             var time = exercise['time'].toString();
//                             var reps = exercise['reps'] == 0
//                                 ? 'Not Applicable'
//                                 : exercise['reps'].toString();
//                             return ProgressTile(
//                               name: name,
//                               time: time,
//                               reps: reps,
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                     );
//                   },
//                 );
//               } else {
//                 return const Center(
//                   child: Text('No progress data available'),
//                 );
//               }
//             }
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class ProgressTile extends StatelessWidget {
//   final String name;
//   final String time;
//   final String reps;

//   const ProgressTile({
//     required this.name,
//     required this.time,
//     required this.reps,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         name,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Time: $time'),
//           Text('Reps: ${reps == '0' ? '' : reps}'),
//         ],
//       ),
//     );
//   }
// }
