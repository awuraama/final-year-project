import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchAllUpcomingEvents() async {
    final groupSnapshots = await FirebaseFirestore.instance.collection('groups').get();

    List<Map<String, dynamic>> allEvents = [];

    for (var group in groupSnapshots.docs) {
      final groupId = group.id;
      final groupName = group['name'];

      final eventSnapshots = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .get();

      for (var event in eventSnapshots.docs) {
        final eventData = event.data();
        allEvents.add({
          'title': eventData['title'],
          'date': (eventData['date'] as Timestamp).toDate(),
          'groupName': groupName,
        });
      }
    }

    // Sort all events by date
    allEvents.sort((a, b) => a['date'].compareTo(b['date']));

    return allEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Upcoming Events'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllUpcomingEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text(
                "No upcoming events.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final title = event['title'];
              final date = event['date'];
              final groupName = event['groupName'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(title),
                  subtitle: Text(
                    'Group: $groupName\n${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
