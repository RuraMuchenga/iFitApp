import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipOptionsScreen extends StatelessWidget {
  final String gymName;
  final String username;
  const MembershipOptionsScreen(
      {Key? key, required this.gymName, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Function to retrieve membership options for the selected gym from Firestore
    Future<DocumentSnapshot> getDocumentSnapshot(String documentName) async {
      try {
        // Get a reference to the document
        DocumentReference documentReference =
            FirebaseFirestore.instance.collection('Gyms').doc(documentName);

        // Get the snapshot of the document
        DocumentSnapshot snapshot = await documentReference.get();

        // Return the snapshot
        return snapshot;
      } catch (e) {
        // Handle any errors
        print('Error retrieving document snapshot: $e');
        rethrow; // Rethrow the error to let the caller handle it
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$gymName Membership Options'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getDocumentSnapshot(gymName), // Retrieve the document snapshot
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while retrieving data
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Show an error message if an error occurs
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Retrieve membership options from the document snapshot
          List<dynamic>? subOptions = snapshot.data!['sub_options'];
          if (subOptions != null && subOptions.isNotEmpty) {
            // Display membership options as a list
            return ListView.builder(
              itemCount: subOptions.length,
              itemBuilder: (context, index) {
                // Build list item for each membership option
                return ListTile(
                  title: Text('${subOptions[index]['name']}'),
                  subtitle: Text(
                      'Price: \$${subOptions[index]['price']} - Duration: ${subOptions[index]['duration']}'),
                  // You can add more details to display if needed
                );
              },
            );
          } else {
            // Display a message if no membership options are available
            return Center(child: Text('No membership options available.'));
          }
        },
      ),
    );
  }
}
