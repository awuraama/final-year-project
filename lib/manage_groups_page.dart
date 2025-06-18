import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageGroupsPage extends StatefulWidget {
  const ManageGroupsPage({super.key});

  @override
  State<ManageGroupsPage> createState() => _ManageGroupsPageState();
}

class _ManageGroupsPageState extends State<ManageGroupsPage> {
  String? selectedGroupId;

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedGroupId = isExpanded ? null : groupId;
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
                            const Text("Members:"),
                            const SizedBox(height: 4),
                            ...memberEmails.map((email) => ListTile(
                                  dense: true,
                                  title: Text(email),
                                )),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _addMemberEmail(context, groupId);
                                  },
                                  icon: const Icon(Icons.person_add),
                                  tooltip: "Add member",
                                ),
                                IconButton(
                                  onPressed: () {
                                    // We'll implement remove member next
                                  },
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: "Remove member",
                                ),
                                IconButton(
                                  onPressed: () {
                                    _deleteGroup(groupId);
                                  },
                                  icon: const Icon(Icons.delete),
                                  tooltip: "Delete group",
                                  color: Colors.red,
                                ),
                              ],
                            )
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

  void _addMemberEmail(BuildContext context, String groupId) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Member Email"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: "Enter member email",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
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
                    const SnackBar(content: Text("Member added successfully")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this group? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Group deleted successfully")),
                );
                setState(() {
                  selectedGroupId = null;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete group: $e")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
