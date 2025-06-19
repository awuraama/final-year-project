import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageGroupsPage extends StatefulWidget {
  const ManageGroupsPage({super.key});

  @override
  State<ManageGroupsPage> createState() => _ManageGroupsPageState();
}

class _ManageGroupsPageState extends State<ManageGroupsPage> {
  String? selectedGroupId;
  String? selectedView;

  void _addMemberEmail(BuildContext context, String groupId) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Member Email"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter member email"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                  'memberEmails': FieldValue.arrayUnion([email])
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Member added successfully")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _removeMemberEmail(BuildContext context, String groupId, List<String> memberEmails) {
    List<String> selectedEmails = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Select emails to remove", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...memberEmails.map((email) {
                return CheckboxListTile(
                  title: Text(email),
                  value: selectedEmails.contains(email),
                  onChanged: (checked) {
                    setModalState(() {
                      if (checked == true) {
                        selectedEmails.add(email);
                      } else {
                        selectedEmails.remove(email);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (selectedEmails.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                      'memberEmails': FieldValue.arrayRemove(selectedEmails)
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selected members removed")),
                    );
                  }
                },
                child: const Text("Remove Selected"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this group?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Group deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _addEventToGroup(BuildContext context, String groupId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    final reminderOptions = {
      7: '7 days before',
      6: '6 days before',
      5: '5 days before',
      4: '4 days before',
      3: '3 days before',
      2: '2 days before',
      1: '1 day before',
    };
    List<int> selectedReminderDays = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(selectedDate == null
                      ? "Select Date"
                      : "Selected: ${selectedDate!.toLocal()}".split(' ')[0]),
                ),
                const SizedBox(height: 10),
                const Text("Reminder Days:"),
                ...reminderOptions.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value),
                    value: selectedReminderDays.contains(entry.key),
                    onChanged: (checked) {
                      setModalState(() {
                        if (checked == true && selectedReminderDays.length < 3) {
                          selectedReminderDays.add(entry.key);
                        } else if (checked == false) {
                          selectedReminderDays.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please complete all fields")),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groupId)
                        .collection('events')
                        .add({
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'date': Timestamp.fromDate(selectedDate!),
                      'reminderDaysBefore': selectedReminderDays,
                      'createdAt': Timestamp.now(),
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Event added")),
                    );
                  },
                  child: const Text("Save Event"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsRef = FirebaseFirestore.instance.collection('groups');

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Groups"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: groupsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final groups = snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupId = group.id;
              final groupName = group['name'];
              final memberEmails = List<String>.from(group['memberEmails'] ?? []);
              final isExpanded = selectedGroupId == groupId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(groupName),
                      trailing: IconButton(
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            selectedGroupId = isExpanded ? null : groupId;
                            selectedView = null;
                          });
                        },
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => setState(() => selectedView = 'members'),
                                  child: const Text("View Members"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => setState(() => selectedView = 'events'),
                                  child: const Text("View Events"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (selectedView == 'members')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: memberEmails.map((email) {
                                  return ListTile(dense: true, title: Text(email));
                                }).toList(),
                              ),
                            if (selectedView == 'events')
                              const Text("No event list UI here. Use the 📅 button below to add."),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add),
                                  tooltip: "Add",
                                  onPressed: () => _addMemberEmail(context, groupId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: "Remove",
                                  onPressed: () => _removeMemberEmail(context, groupId, memberEmails),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  tooltip: "Add Event",
                                  onPressed: () => _addEventToGroup(context, groupId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: "Delete",
                                  onPressed: () => _confirmDeleteGroup(context, groupId),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
