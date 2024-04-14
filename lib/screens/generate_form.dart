import 'package:flutter/material.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_signin/screens/workout_plan.dart';

class GenerateForm extends StatefulWidget {
  final String email;

  const GenerateForm({Key? key, required this.email}) : super(key: key);

  @override
  _GenerateFormState createState() => _GenerateFormState();
}

class _GenerateFormState extends State<GenerateForm> {
  var selectedTime = '10';
  var selectedDifficulty = 'easy';
  List<dynamic> selectedAreas = [];
  List<dynamic> areas = [];
  List<dynamic> exs = [];

  @override
  void initState() {
    super.initState();
    // Call getTargets function to fetch target areas
    getTargets(widget.email).then((value) {
      setState(() {
        areas = value[1];
        exs = value[0];
      });
    });
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
              Text(
                "How long do you want your daily plan to be?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // RadioListTile widgets for time selection
              SizedBox(height: 10),
              RadioListTile(
                title: Text('10 minutes'),
                value: '10 minutes',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('30 minutes'),
                value: '13 minutes',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('1 hour'),
                value: '1 hour',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('2 hours'),
                value: '2 hours',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),

              const SizedBox(height: 20),

              Text(
                "Do you want the exercises to be easy, intense, or somewhere in between?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              RadioListTile(
                title: Text('Easy'),
                value: 'easy',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('Medium'),
                value: 'medium',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('Hard'),
                value: 'hard',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                "What areas do you want to target?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Display CheckboxListTile widgets for target area
              ...areas.map((area) {
                return CheckboxListTile(
                  title: Text(area),
                  value: selectedAreas.contains(area),
                  onChanged: (value) {
                    setState(() {
                      if (value != null && value) {
                        selectedAreas.add(area);
                      } else {
                        selectedAreas.remove(area);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Submit button action
                  submitForm();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to submit the form
  void submitForm() async {
    // Create the dictionary with form data
    Map<String, dynamic> formData = {
      'time': selectedTime, //Format this later
      'difficulty': selectedDifficulty,
      'target_areas': selectedAreas,
    };

    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.email)
        .update({'form_response': formData});

    var url = 'http://127.0.0.1:5000/plan';
    var params = '?email=${widget.email}';
    var response =
        await http.get(Uri.parse(url + params)); // Make HTTP GET request

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutPlanPage(email: widget.email),
      ),
    );

    // Print or use formData as needed
    print(formData);
  }

  // Function to fetch target areas
  Future<List> getTargets(String email) async {
    // var gymName = '';
    var exercises = [];
    var target_areas = [];

    CollectionReference exs =
        FirebaseFirestore.instance.collection('equipment');
    QuerySnapshot exsSnapshot = await exs.get();
    List<String> documentIds = exsSnapshot.docs.map((doc) => doc.id).toList();

    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    var doc = await users.doc(email).get();

    var index = 0;
    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
      if (map.containsKey('membership')) {
        var gymName = map['membership']['gym'];
        DocumentSnapshot eqSnapshot = await FirebaseFirestore.instance
            .collection('Gyms')
            .doc(gymName)
            .get();
        Map<String, dynamic> eqData = eqSnapshot.data() as Map<String, dynamic>;
        for (var exsDoc in exsSnapshot.docs) {
          Map<String, dynamic> exsData = exsDoc.data() as Map<String, dynamic>;
          //Check needed equipment from user's gym
          // print('checking $exsData}');
          if (exsData.containsKey('needs_eq')) {
            if (exsData['needs_eq']) {
              if (eqData.containsKey('equipments')) {
                var docName = documentIds[index];
                for (var eq in eqData['equipments']) {
                  // print('comparing $exsData and $eq');
                  if (eq['name'].contains(docName)) {
                    //Add
                    var eq_chosen = {...exsData};
                    eq_chosen['difficulty'] = eq['difficulty'];
                    eq_chosen['name'] = docName;
                    print('Adding:');
                    print(eq_chosen);
                    print('Current list:');
                    exercises.add(eq_chosen);
                    print(exercises);
                    for (var target in exsData['target_areas']) {
                      if (!target_areas.contains(target)) {
                        target_areas.add(target);
                        break;
                      } else {
                        //empty is fine
                      }
                    }
                  } else {
                    //empty is fine
                  }
                }
              }
            } else {
              //Add
              exercises.add(exsData);
              for (var target in exsData['target_areas']) {
                if (!target_areas.contains(target)) {
                  target_areas.add(target);
                  break;
                } else {
                  //empty is fine
                }
              }
            }
          } else {
            //empty is fine
          }
          index += 1;
        }
      } else {
        for (var exsDoc in exsSnapshot.docs) {
          Map<String, dynamic> exsData = exsDoc.data() as Map<String, dynamic>;
          //Add only those exercises without equipment
          if (exsData.containsKey('needs_eq')) {
            if (!exsData['needs_eq']) {
              exercises.add(exsData);
              for (var target in exsData['target_areas']) {
                if (!target_areas.contains(target)) {
                  target_areas.add(target);
                  break;
                } else {
                  //empty is fine
                }
              }
            } else {
              //empty is fine
            }
          } else {
            //empty is fine
          }
        }
      }
    } else {
      //empty is fine
    }
    print('Finally returning:');
    print([exercises, target_areas]);

    FirebaseFirestore.instance
        .collection('Users')
        .doc(email)
        .update({'form_exercises': exercises});

    return [exercises, target_areas];
  }
}
