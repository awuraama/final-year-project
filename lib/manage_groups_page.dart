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
                                    // We'll implement add later
                                  },
                                  icon: const Icon(Icons.person_add),
                                  tooltip: "Add member",
                                ),
                                IconButton(
                                  onPressed: () {
                                    // We'll implement remove later
                                  },
                                  icon: const Icon(Icons.remove_circle),
                                  tooltip: "Remove member",
                                ),
                                IconButton(
                                  onPressed: () {
                                    // We'll implement delete later
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
}
