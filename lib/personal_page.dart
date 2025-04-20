import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'; // Add this import

class personal_page extends StatelessWidget {
  // Add a method for showing the password change dialog
  void _showChangePasswordDialog(BuildContext context) {
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
                // Add save password logic if needed
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show calendar pop-up method
  void _showCalendarDialog(BuildContext context) {
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
      appBar: AppBar(
        title: Text('Personal Planner'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              child: Icon(Icons.person, color: Colors.black),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                // Handle logout logic here
              } else if (value == 'change_password') {
                _showChangePasswordDialog(context); // Show dialog for change password
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
                      onTap: () {
                        _showCalendarDialog(context); // Call the calendar pop-up here
                      },
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 3 / 4, // Doubled the height of the boxes
        children: [
          _buildCategoryCard(context, 'Assignments', Colors.blue),
          _buildCategoryCard(context, 'Exams', Colors.green),
          _buildCategoryCard(context, 'Projects', Colors.orange),
          _buildCategoryCard(context, 'Special Events', Colors.red),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to the respective page for setting schedules and reminders
      },
      child: Card(
        color: color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
