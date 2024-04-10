import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EquipmentAvailabilityPage extends StatelessWidget {
  final String gym;

  const EquipmentAvailabilityPage({Key? key, required this.gym})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipment Availability - $gym'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Gyms')
              .doc(gym)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var gymData = snapshot.data!.data();
              print(gymData);
              if (gymData != null &&
                  gymData is Map<String, dynamic> &&
                  gymData.containsKey('equipments')) {
                var equipments = gymData['equipments'];
                return ListView.builder(
                  itemCount: equipments.length,
                  itemBuilder: (context, index) {
                    var equipment = equipments[index];
                    var equipmentName = equipment['name'];
                    var status = equipment['status'] ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EquipmentStatusTile(
                          equipment: equipmentName,
                          status: status,
                        ),
                        // Add a Text widget with dashes below each item
                        const Text('-----'),
                      ],
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('No equipment data available for $gym'),
                );
              }
            }
            // Add a default return statement
            return const CircularProgressIndicator(); // or any other placeholder widget
          },
        ),
      ),
    );
  }
}

class EquipmentStatusTile extends StatelessWidget {
  final String equipment;
  final String status;

  const EquipmentStatusTile({
    required this.equipment,
    required this.status,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        equipment,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(status),
    );
  }
}
