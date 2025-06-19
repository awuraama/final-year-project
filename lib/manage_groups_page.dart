import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageGroupsPage extends StatefulWidget {
  const ManageGroupsPage({super.key});

  @override
  State<ManageGroupsPage> createState() => _ManageGroupsPageState();
}

class _ManageGroupsPageState extends State<ManageGroupsPage> {
  String? selectedGroupId;
  String selectedView = 'members';

  void _addMemberEmail(BuildContext context, String groupId) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .update({
                  'memberEmails': FieldValue.arrayUnion([email])
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Member added")),
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select emails to remove", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...memberEmails.map((email) => CheckboxListTile(
                      title: Text(email),
                      value: selectedEmails.contains(email),
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selectedEmails.add(email);
                          } else {
                            selectedEmails.remove(email);
                          }
                        });
                      },
                    )),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEmails.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(groupId)
                          .update({
                        'memberEmails': FieldValue.arrayRemove(selectedEmails)
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Members removed")),
                      );
                    }
                  },
                  child: const Text("Remove Selected"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _deleteEventConfirmation(BuildContext context, String groupId, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .collection('events')
                  .doc(eventId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Event deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _addEventDialog(BuildContext context, String groupId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<int> selectedReminderDays = [];

    final reminderOptions = {
      7: '7 days before',
      6: '6 days before',
      5: '5 days before',
      4: '4 days before',
      3: '3 days before',
      2: '2 days before',
      1: '1 day before',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Event"),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text("PickEventDate: ${selectedDate.toLocal()}".split(' ')[0]),
                ),
                const SizedBox(height: 10),
                const Text("Reminder Days"),
                ...reminderOptions.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedReminderDays.contains(entry.key),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true && selectedReminderDays.length < 3) {
                            selectedReminderDays.add(entry.key);
                          } else if (val == false) {
                            selectedReminderDays.remove(entry.key);
                          }
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .collection('events')
                    .add({
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'date': selectedDate,
                  'reminderDaysBefore': selectedReminderDays,
                  'createdAt': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event added")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsRef = FirebaseFirestore.instance.collection('groups');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Groups"),
        centerTitle: true,
      ),
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
                  children: [
                    ListTile(
                      title: Text(groupName),
                      trailing: IconButton(
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            selectedGroupId = isExpanded ? null : groupId;
                            selectedView = 'members';
                          });
                        },
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text("View Members"),
                                  selected: selectedView == 'members',
                                  onSelected: (_) {
                                    setState(() {
                                      selectedView = 'members';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text("View Events"),
                                  selected: selectedView == 'events',
                                  onSelected: (_) {
                                    setState(() {
                                      selectedView = 'events';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (selectedView == 'members')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Members:"),
                                  ...memberEmails.map((email) => ListTile(title: Text(email))),
                                ],
                              ),
                            if (selectedView == 'events')
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('groups')
                                    .doc(groupId)
                                    .collection('events')
                                    .orderBy('date')
                                    .snapshots(),
                                builder: (context, eventSnap) {
                                  if (eventSnap.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  final events = eventSnap.data?.docs ?? [];

                                  if (events.isEmpty) return const Text("No events yet.");

                                  return Column(
                                    children: events.map((event) {
                                      final title = event['title'];
                                      final description = event['description'] ?? '';
                                      final date = (event['date'] as Timestamp).toDate();

                                      return GestureDetector(
                                        onLongPress: () =>
                                            _deleteEventConfirmation(context, groupId, event.id),
                                        child: ListTile(
                                          leading: const Icon(Icons.event),
                                          title: Text(title),
                                          subtitle: Text(
                                            "${description.isNotEmpty ? '$description\n' : ''}${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _addMemberEmail(context, groupId),
                                  icon: const Icon(Icons.person_add),
                                  tooltip: "Add member",
                                ),
                                IconButton(
                                  onPressed: () => _removeMemberEmail(context, groupId, memberEmails),
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: "Remove member",
                                ),
                                IconButton(
                                  onPressed: () => _addEventDialog(context, groupId),
                                  icon: const Icon(Icons.calendar_today),
                                  tooltip: "Add event",
                                ),
                                IconButton(
                                  onPressed: () => _confirmDeleteGroup(context, groupId),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  tooltip: "Delete group",
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
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
