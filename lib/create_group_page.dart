import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<TextEditingController> _emailControllers = [
    TextEditingController(),
    TextEditingController()
  ];

  final _formKey = GlobalKey<FormState>();

  void _addEmailField() {
    if (_emailControllers.length < 10) {
      setState(() {
        _emailControllers.add(TextEditingController());
      });
    }
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 2) {
      setState(() {
        _emailControllers.removeAt(index);
      });
    }
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text.trim();
      final emails = _emailControllers
          .map((controller) => controller.text.trim())
          .where((email) => email.isNotEmpty)
          .toList();

      if (emails.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least 2 member emails.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('groups').add({
          'name': groupName,
          'createdAt': Timestamp.now(),
          'memberEmails': emails,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
        Navigator.pop(context); // Go back to action page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter group name' : null,
              ),
              const SizedBox(height: 16),
              const Text('Member Emails (Min: 2, Max: 10)', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._emailControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Email ${index + 1}',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Enter email' : null,
                      ),
                    ),
                    if (_emailControllers.length > 2)
                      IconButton(
                        onPressed: () => _removeEmailField(index),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addEmailField,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Email'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGroup,
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
