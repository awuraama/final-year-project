import 'package:flutter/material.dart';

class starter_page extends StatefulWidget {
  @override
  _starter_pageState createState() => _starter_pageState();
}

class _starter_pageState extends State<starter_page>
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
          // Background image
          Image.asset(
            'assets/projectback.jpg', // Ensure this image exists in the assets folder
            fit: BoxFit.cover,
          ),
          // Bouncing button with "Click Me" text
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button
                      TextButton(
                        onPressed: () {
                          // Navigate to the Sign In page
                          Navigator.pushNamed(context, '/signin');
                        },
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.white.withOpacity(0.9), // Slightly transparent white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Student Planner App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0), // X and Y offset
                          blurRadius: 3.0, // Blurring of the shadow
                          color: Colors.black, // Shadow color
                        ),
                      ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10), // Space between button and text
                      // "Click Me" text
                      const Text(
                        "Click Button! Let's Get You Started",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                          shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0), // X and Y offset
                          blurRadius: 3.0, // Blurring of the shadow
                          color: Colors.blue, // Shadow color
                        ),
                      ],
                        ),
                      ),
                    ],
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
