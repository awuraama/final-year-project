import 'package:flutter/material.dart';
import 'events_page.dart'; // ✅ Import this
import 'create_group_page.dart';


class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> with TickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Automatically open the menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isOpen = true;
        _controller.forward();
      });
    });
  }

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildOption(String label, IconData icon, VoidCallback onTap) {
    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: label,
              onPressed: onTap,
              backgroundColor: Colors.white,
              mini: true,
              elevation: 4,
              child: Icon(
                icon,
                color: const Color.fromARGB(255, 232, 110, 23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions'),
        centerTitle: true,
      ),
      body: const SizedBox.shrink(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOpen)
            _buildOption("Events", Icons.event, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EventsPage(groupId: 'test-group-id'), // Replace later
                ),
              );
            }),
          if (isOpen)
            _buildOption("Create Group", Icons.group_add, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateGroupPage()),
                );            
            }),
          if (isOpen)
            _buildOption("Manage Groups", Icons.group, () {
              // To be implemented next
            }),
          // if (isOpen)
          //   _buildOption("Exit Group", Icons.logout, () {
          //     // To be implemented next
          //   }),
          FloatingActionButton(
            onPressed: toggleMenu,
            backgroundColor: const Color.fromARGB(255, 232, 110, 23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
