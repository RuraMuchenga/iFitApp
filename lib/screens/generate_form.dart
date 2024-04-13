import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';

class GenerateForm extends StatelessWidget {
  final String email;

  const GenerateForm({Key? key, required this.email}) : super(key: key);

  Future<List> getTargets(String email) async {
    var gymName = '';
    var exercises = [];
    var target_areas = [];
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    var doc = await users.doc(email).get();
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    if (map.containsKey('membership')) {
      gymName = map['membership']['gym'];
    }
    CollectionReference exs =
        FirebaseFirestore.instance.collection('equipment');
    QuerySnapshot exsSnapshot = await exs.get();
    List<String> documentIds = exsSnapshot.docs.map((doc) => doc.id).toList();

    DocumentSnapshot eqSnapshot =
        await FirebaseFirestore.instance.collection('Gyms').doc(gymName).get();
    Map<String, dynamic> eqData = eqSnapshot.data() as Map<String, dynamic>;

    if (eqSnapshot.exists) {
      Map<String, dynamic>? gymData = eqSnapshot.data() as Map<String, dynamic>;
      var index = 0;
      for (var exsDoc in exsSnapshot.docs) {
        Map<String, dynamic> exsData = exsDoc.data() as Map<String, dynamic>;
        if (exsData.containsKey('needs_eq')) {
          if (exsData['needs_eq']) {
            if (eqData.containsKey('equipments')) {
              var docName = documentIds[index];
              for (var key in eqData.keys) {
                if (eqData[key]['name'].contains(docName)) {
                  exercises.add(exsData);
                  for (var target in eqData[key]['target_areas']) {
                    if (!target_areas.contains(target)) {
                      exercises.add(exsData);
                      break;
                    }
                  }
                }
              }
            } else {
              if (eqData.containsKey('')) {
                for (var target in eqData[key]['target_areas']) {
                  if (!target_areas.contains(target)) {
                    exercises.add(exsData);
                    break;
                  }
                }
              }
            }
          }
          index += 1;
        }
      }

      return [exercises, target_areas];
    }

    return [
      exercises,
      target_areas
    ]; // Return empty lists if eqSnapshot does not exist
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Preference Form",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40),
              buildCard(
                icon: Icons.fitness_center,
                title: "Custom Workout Plan",
                onTap: () {},
              ),
              // Add your other buildCard widgets here
            ],
          ),
        ),
      ),
    );
  }
}
