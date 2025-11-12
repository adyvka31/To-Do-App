import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo_firebase/theme_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var c = Get.put(ThemeController());
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController todoController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String search = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        search = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    todoController.dispose();
    editController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _showAddTodoSheet() {
    todoController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Todo Baru',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: todoController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul Todo',
                  hintText: 'Apa yang ingin Anda lakukan?',
                ),
                onSubmitted: (_) => _submitAddTodo(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAddTodo,
                child: const Text('Simpan'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitAddTodo() async {
    if (todoController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection("todo").add({
        "title": todoController.text,
        "time": FieldValue.serverTimestamp(),
        "check": false,
        "userId": user.uid,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil menambahkan data"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditTodoDialog(DocumentSnapshot todo) {
    editController.text = todo['title'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Todo"),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Title",
              hintText: "Input your edit",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('todo')
                      .doc(todo.id)
                      .update({"title": editController.text});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil mengedit data")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteTodoDialog(DocumentSnapshot todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Todo"),
          content: Text("Anda yakin ingin menghapus \"${todo['title']}\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('todo')
                    .doc(todo.id)
                    .delete();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // --- REDESIGN: Layout Utama ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomAppBar(context),
            _buildSearchBar(),
            _buildCategories(),
            _buildTodayTasks(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoSheet,
        tooltip: 'Tambah Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- REDESIGN: Widget untuk AppBar Kustom ---
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFf0f5ff),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24,
          right: 24,
          left: 24,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFFF8F9FB),
                  ),
                  child: Obx(
                    () => IconButton(
                      onPressed: () {
                        c.changeTheme();
                      },
                      icon: c.isTheme.value
                          ? Icon(Icons.dark_mode_outlined)
                          : Icon(Icons.light_mode_outlined),
                    ),
                  ),
                ),
                Text(
                  "Adyvka Pratama",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFFF8F9FB),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      size: 25,
                      color: Colors.black87,
                    ),
                    tooltip: 'Logout',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Anda yakin ingin keluar?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Ya, Keluar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              "Good Morning, Adyvka!",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('todo')
                  .where('userId', isEqualTo: user.uid)
                  .where('check', isEqualTo: false) // Hanya hitung yg belum
                  .snapshots(),
              builder: (context, snapshot) {
                int taskCount = 0;
                if (snapshot.hasData) {
                  taskCount = snapshot.data!.docs.length;
                }

                return RichText(
                  text: TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.black87),
                    children: [
                      const TextSpan(text: 'You have '),
                      TextSpan(
                        text: '$taskCount tasks',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Warna aksen seperti di gambar
                        ),
                      ),
                      const TextSpan(text: ' today.'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 24, bottom: 4),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Search tasks...",
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 24, right: 10),
            child: Icon(Icons.search, color: Colors.grey[600]),
          ),
          filled: true,
          fillColor: Color(0xFFF8F9FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryCard(
                  "Design",
                  "+6 Task",
                  const Color(0xFFf0f5ff),
                  Icons.palette_outlined,
                  Colors.blue.shade800,
                ),
                _buildCategoryCard(
                  "Sport",
                  "+3 Task",
                  const Color(0xFFf0fcf0),
                  Icons.sports_basketball_outlined,
                  Colors.green.shade800,
                ),
                _buildCategoryCard(
                  "Meet",
                  "+1 Task",
                  const Color(0xFFfff6e5),
                  Icons.group_outlined,
                  Colors.orange.shade800,
                ),
                _buildCategoryCard(
                  "Work",
                  "+10 Task",
                  const Color(0xFFD6EAF8),
                  Icons.work_outline,
                  Colors.indigo.shade800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Card Kategori
  Widget _buildCategoryCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12.0, bottom: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasks(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FB),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              child: Text(
                "Today's Task",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('todo')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada data todo.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final data = snapshot.data!.docs;
                    final searchData = data.where((element) {
                      final keyword = element['title'].toString().toLowerCase();
                      return keyword.contains(search);
                    }).toList();

                    if (searchData.isEmpty) {
                      return Center(
                        child: Text(
                          "Tidak ada data untuk \"$search\"",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: searchData.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        final todo = searchData[index];
                        final data = todo.data() as Map<String, dynamic>;

                        final title = data['title'] ?? 'No Title';
                        final isChecked = data['check'] ?? false;
                        final time = data['time'] as Timestamp?;

                        String formattedTime = 'No time';
                        if (time != null) {
                          formattedTime = DateFormat(
                            'd MMM, h:mm a',
                          ).format(time.toDate());
                        }

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 0.5,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 16.0,
                            ),
                            onTap: () => _showEditTodoDialog(todo),
                            onLongPress: () => _showDeleteTodoDialog(todo),

                            leading: CircleAvatar(
                              backgroundColor: isChecked
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              child: Icon(
                                Icons.task_outlined,
                                color: isChecked
                                    ? Colors.blue[800]
                                    : Colors.grey[700],
                              ),
                            ),

                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isChecked ? Colors.grey : Colors.black87,
                              ),
                            ),

                            subtitle: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: isChecked
                                    ? Colors.grey
                                    : Colors.grey[600],
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),

                            // Checkbox di kanan
                            trailing: Checkbox(
                              value: isChecked,
                              onChanged: (value) async {
                                await FirebaseFirestore.instance
                                    .collection('todo')
                                    .doc(todo.id)
                                    .update({'check': value});
                              },
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Drawer tidak perlu diubah, sudah OK ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.displayName ?? "Pengguna",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user.email ?? "Tidak ada email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Anda yakin ingin keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Ya, Keluar"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
