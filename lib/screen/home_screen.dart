import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mengambil Data User Yang Sedang Digunakan
  final user = FirebaseAuth.instance.currentUser!;
  // Text Editing Untuk Form Input
  TextEditingController todoController = TextEditingController();
  TextEditingController editController = TextEditingController();

  String message = '';
  String search = '';

  Future<void> addTodo() async {
    try {
      // Membuat Collection Untuk Membuat Data "To Do List"
      await FirebaseFirestore.instance.collection("todo").add({
        "title": todoController.text,
        "time": FieldValue.serverTimestamp(),
        "check": false,
      });
      setState(() {
        message = "Berhasil menambahkan data ${todoController.text}";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      todoController.clear();
    } catch (e) {
      setState(() {
        message = "eror $e";
      });
    }
  }

  Future<void> editTodo(id) async {
    try {
      await FirebaseFirestore.instance.collection('todo').doc(id).update({
        "title": editController.text,
      });
      setState(() {
        message = "Berhasil mengedit data ${editController.text}";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      setState(() {
        message = "error $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are You Sure?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                        child: Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Masukan kata kunci pencarian",
                labelText: "search",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Selamat Datang ${user.displayName}",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('todo')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final data = snapshot.data!.docs;
                  final searchData = data.where((element) {
                    final keyword = element['title'].toString().toLowerCase();
                    return keyword.contains(search);
                  }).toList();

                  if (searchData.isEmpty) {
                    return Center(child: Text("Tidak ada data $search"));
                  }
                  return ListView.builder(
                    itemCount: searchData.length,
                    itemBuilder: (context, index) {
                      final todo = searchData[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo['check'],
                            onChanged: (value) async {
                              await FirebaseFirestore.instance
                                  .collection('todo')
                                  .doc(todo.id)
                                  .update({'check': value});
                            },
                          ),
                          title: Text(
                            todo['title'],
                            style: TextStyle(
                              decoration: todo['check']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  editController.text = todo['title'];
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit"),
                                        content: Text("Input your new title"),
                                        actions: [
                                          TextField(
                                            controller: editController,
                                            decoration: InputDecoration(
                                              labelText: "Title",
                                              hintText: "Input your edit",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                editTodo(todo.id);
                                                Navigator.pop(context);
                                              },
                                              child: Text("Submit"),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Delete"),
                                        content: Text("Are You Sure?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('todo')
                                                  .doc(todo.id)
                                                  .delete();
                                              Navigator.pop(context);
                                            },
                                            child: Text("No"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: TextField(
          controller: todoController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                addTodo();
              },
              icon: Icon(Icons.send),
            ),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
