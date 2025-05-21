import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_assigment/screen/signup_screen/signup_screen.dart';

class ChatUserScreen extends StatefulWidget {
  const ChatUserScreen({super.key});

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final users = FirebaseFirestore.instance.collection('users');
  final auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _showUserSheet({DocumentSnapshot? document}) {
    if (document != null) {
      nameController.text = document['name'];
      descriptionController.text = document['description'];
    } else {
      nameController.clear();
      descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                document == null ? 'Add Chat' : 'Update Chat',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLength: 50,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final description = descriptionController.text.trim();
                      final currentUser = auth.currentUser;

                      if (name.isNotEmpty &&
                          description.isNotEmpty &&
                          currentUser != null) {
                        if (document == null) {
                          await users.add({
                            'name': name,
                            'description': description,
                            'uid': currentUser.uid,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        } else {
                          await users.doc(document.id).update({
                            'name': name,
                            'description': description,
                          });
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(document == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  void _deleteUserChat(String docId) async {
    await users.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('My Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color: Colors.red,size: 30,),
            onPressed: ()async{
             await auth.signOut();
             Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(),));
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserSheet();
        },
        child: Center(child: Text('Chat',textAlign: TextAlign.center,style: TextStyle(fontSize: 18),),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.where('uid', isEqualTo: currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) return const Center(child: Text('No chats found'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.indigo.shade100,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text(
                    doc['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      doc['description'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showUserSheet(document: doc);
                      } else if (value == 'delete') {
                        _deleteUserChat(doc.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Edit'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
