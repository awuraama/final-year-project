import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'; // Import the calendar package
import 'sign_in_page.dart';
import 'personal_page.dart';
import 'group_page.dart';

class home_page extends StatefulWidget {
  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _personalAnimation;
  late Animation<double> _groupAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _personalAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _groupAnimation = Tween<double>(begin: 15, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Enter Old Password'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Enter New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Exit'),
            ),
            TextButton(
              onPressed: () {
                // Save new password logic
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Show pop-up calendar
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: CalendarCarousel(
            onDayPressed: (DateTime date, List events) {
              // Handle day press (optional)
              print(date);
              Navigator.of(context).pop(); // Close the dialog after selecting a date
            },
            locale: 'en',
            selectedDateTime: DateTime.now(),
            height: 400.0,
            selectedDayTextStyle: TextStyle(color: Colors.white),
            todayTextStyle: TextStyle(color: Colors.red),
            daysHaveCircularBorder: false,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              child: Icon(Icons.person, color: Colors.black),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => sign_in_page()),
                );
              } else if (value == 'change_password') {
                _showChangePasswordDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'change_password', child: Text('Change Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
          height: MediaQuery.of(context).size.height * 2.7 / 3,
          color: Colors.black,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child: Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.schedule, color: Colors.white),
                      title: Text('Schedule', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.task, color: Colors.white),
                      title: Text('Tasks', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.share, color: Colors.white),
                      title: Text('Share', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.white),
                      title: Text('Calendar', style: TextStyle(color: Colors.white)),
                      onTap: _showCalendarDialog, // Show the calendar pop-up
                    ),
                    Divider(color: Colors.white),
                    ListTile(
                      leading: Icon(Icons.settings, color: Colors.white),
                      title: Text('Settings', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.dark_mode, color: Colors.white),
                      title: Text('Dark Mode', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/projectback.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _personalAnimation.value),
                      child: _buildOptionCard(context, 'Personal Planner', Colors.blue, personal_page()),
                    );
                  },
                ),
                SizedBox(height: 30),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _groupAnimation.value),
                      child: _buildOptionCard(context, 'Group Planner', Colors.green, group_page()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
