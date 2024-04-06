import 'package:firebase_signin/screens/equipment_availability_page.dart';
import 'package:flutter/material.dart';
//import 'package:your_project_name_here/equipment_availability_page.dart'; // Import your equipment availability page file

class DashboardScreen extends StatelessWidget {
  final String username;

  const DashboardScreen({Key? key, required this.username}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Welcome, $username!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            _buildCard(
              icon: Icons.fitness_center,
              title: "Custom Workout Plan",
              onTap: () {
                // Handle onTap action
              },
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.timeline,
              title: "Progress Summary",
              onTap: () {
                // Handle onTap action
              },
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.sports_bar,
              title: "Gym Equipment Availability",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EquipmentAvailabilityPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.chat,
              title: "Chat Room",
              onTap: () {
                // Handle onTap action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 40,
              color: Colors.blue.shade800,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


