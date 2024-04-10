// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
import 'package:firebase_signin/screens/membership.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _firstTextController = TextEditingController();
  final TextEditingController _lastTextController = TextEditingController();

  DateTime selectedDate = DateTime.parse('1990-06-15');
  Future<void> _selectDate(BuildContext context) async {
    var currDt = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950, 1),
      lastDate: DateTime(currDt.year - 10),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<bool> checkEmail(String name) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    bool recExist = false;
    await db.collection('Users').doc(name).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        recExist = true;
      }
    });
    return recExist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.blue[50],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Email Id",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                ),
                FutureBuilder<bool>(
                  future: checkEmail(_emailTextController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    } else {
                      if (snapshot.data == true) {
                        return Text("Email already registered");
                      } else {
                        return SizedBox();
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter First Name",
                  Icons.person_outlined,
                  false,
                  _firstTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Last Name",
                  Icons.person_outlined,
                  false,
                  _lastTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  cursorColor: Colors.blue[200],
                  style: TextStyle(
                    color: Colors.black87.withOpacity(0.9),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.date_range_outlined,
                      color: Colors.blue[200],
                    ),
                    labelText: "${selectedDate.toLocal()}".split(' ')[0],
                    labelStyle: TextStyle(
                      color: Colors.black87.withOpacity(0.9),
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailTextController.text,
                    password: _passwordTextController.text,
                  )
                      .then((value) {
                    if (kDebugMode) {
                      print("Created New Account");
                    }
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(_emailTextController.text)
                        .set({
                      'dob': formattedDate,
                      'first_name': _firstTextController.text,
                      'last_name': _lastTextController.text,
                      'workout_plan': [],
                      'progress': []
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Membership(email: _emailTextController.text),
                      ),
                    ).onError((error, stackTrace) {
                      if (kDebugMode) {
                        print("Error ${error.toString()}");
                      }
                    });
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
