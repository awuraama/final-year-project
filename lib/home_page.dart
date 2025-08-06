import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<String, Color> _groupColors = {};
  final List<Color> _availableColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.black,
    Colors.blue,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore();
  }

  Future<void> _loadEventsFromFirestore() async {
    final groupsSnapshot = await FirebaseFirestore.instance.collection('groups').get();

    Map<String, Color> colorMap = {};
    int colorIndex = 0;

    Map<DateTime, List<Map<String, dynamic>>> eventMap = {};

    for (var group in groupsSnapshot.docs) {
      final groupId = group.id;
      final groupName = group['name'];

      colorMap[groupName] = _availableColors[colorIndex % _availableColors.length];
      colorIndex++;

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .get();

      for (var eventDoc in eventsSnapshot.docs) {
        final data = eventDoc.data();
        DateTime eventDate = (data['date'] as Timestamp).toDate();
        DateTime key = DateTime(eventDate.year, eventDate.month, eventDate.day);

        eventMap.putIfAbsent(key, () => []);
        eventMap[key]!.add({
          'title': data['title'],
          'group': groupName,
        });
      }
    }

    setState(() {
      _events = eventMap;
      _groupColors = colorMap;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoPrompt Calendar"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                onFormatChanged: (_) {}, // Prevents user from changing format
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final dayEvents = _getEventsForDay(day);
                    if (dayEvents.isEmpty) return null;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayEvents
                          .map((event) {
                            final color = _groupColors[event['group']] ?? Colors.grey;
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            );
                          })
                          .take(3)
                          .toList(),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/action');
        },
        backgroundColor: const Color.fromARGB(255, 232, 110, 23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.task_alt,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
