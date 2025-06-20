import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _loadEventsAndNavigate();
  }

  Future<void> _loadEventsAndNavigate() async {
    try {
      // Simulate data fetch from Firestore
      await FirebaseFirestore.instance.collection('events').get();

      // Optional delay to ensure UI catches up with animation
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint("Error loading events: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Replaced background image with solid color and overlay
          Container(
            color: const Color.fromARGB(255, 202, 114, 42), // Base color
          ),
          Container(
            color: const Color.fromARGB(255, 230, 224, 224).withOpacity(0.4), // Dark overlay
          ),

          // Bouncing logo
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/autoprompt.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
