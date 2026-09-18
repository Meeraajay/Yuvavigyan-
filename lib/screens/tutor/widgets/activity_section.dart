import 'package:flutter/material.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Rahul submitted Module 2 Test"),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Anu completed Assignment"),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Meera viewed Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}