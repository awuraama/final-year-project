import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';  // Import the new calendar package

class group_page extends StatelessWidget {
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

  // Show calendar pop-up method using TableCalendar
  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            onDaySelected: (selectedDay, focusedDay) {
              // Handle day press (optional)
              print(selectedDay);
              Navigator.of(context).pop(); // Close the dialog after selecting a date
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Planner'),
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
                      onTap: () {} // Option to implement schedule
                    ),
                    ListTile(
                      leading: Icon(Icons.task, color: Colors.white),
                      title: Text('Tasks', style: TextStyle(color: Colors.white)),
                      onTap: () {} // Option to implement tasks
                    ),
                    ListTile(
                      leading: Icon(Icons.share, color: Colors.white),
                      title: Text('Share', style: TextStyle(color: Colors.white)),
                      onTap: () {} // Option to implement share
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
                      onTap: () {} // Option to implement settings
                    ),
                    ListTile(
                      leading: Icon(Icons.dark_mode, color: Colors.white),
                      title: Text('Dark Mode', style: TextStyle(color: Colors.white)),
                      onTap: () {} // Option to implement dark mode
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionCard(context, 'Create Group',Colors.orange),
                _buildOptionCard(context, 'Manage Groups', Colors.blue),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionCard(context, 'Set Group Reminders', Colors.green ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigate to respective pages for group management
        },
        child: Container(
          height: 240,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}