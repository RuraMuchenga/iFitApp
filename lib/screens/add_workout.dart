import 'package:flutter/material.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart'; // Import your reusable widgets here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NewForm extends StatefulWidget {
  final String email;

  const NewForm({Key? key, required this.email}) : super(key: key);

  @override
  _NewFormState createState() => _NewFormState();
}

class _NewFormState extends State<NewForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedDifficulty;
  List<String> selectedAreas = [];
  List<String> areas = [];
  bool requiresEquipment = false;

  @override
  void initState() {
    super.initState();
    // Call a function to fetch target areas
    fetchAreas().then((value) {
      setState(() {
        areas = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Form'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Difficulty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              RadioListTile<String>(
                title: Text('Easy'),
                value: 'Easy',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Medium'),
                value: 'Medium',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Hard'),
                value: 'Hard',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Target Areas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Display CheckboxListTile widgets for target areas
              ...areas.map((area) {
                return CheckboxListTile(
                  title: Text(area),
                  value: selectedAreas.contains(area),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedAreas.add(area);
                      } else {
                        selectedAreas.remove(area);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              Text(
                'Does this exercise require equipment?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: <Widget>[
                  Radio(
                    value: true,
                    groupValue: requiresEquipment,
                    onChanged: (value) {
                      setState(() {
                        requiresEquipment = value as bool;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio(
                    value: false,
                    groupValue: requiresEquipment,
                    onChanged: (value) {
                      setState(() {
                        requiresEquipment = value as bool;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
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
    var url = 'http://127.0.0.1:5000/params';
    var params =
        '?name=${_nameController.text}&diff=${selectedDifficulty}&needs_eq=${requiresEquipment}&areas=${areas}';
    var response =
        await http.get(Uri.parse(url + params)); // Make HTTP GET request

    // Navigate to the next screen or perform any other action
  }

  // Function to fetch target areas (replace with your actual implementation)
  Future<List<String>> fetchAreas() async {
    List<String> areas = [];
    CollectionReference exs =
        FirebaseFirestore.instance.collection('equipment');
    QuerySnapshot exsSnapshot = await exs.get();
    for (var exsDoc in exsSnapshot.docs) {
      Map<String, dynamic> exsData = exsDoc.data() as Map<String, dynamic>;
      for (var target in exsData['target_areas']) {
        if (!areas.contains(target)) {
          areas.add(target);
        } else {}
      }
    }
    return areas;
  }
}
