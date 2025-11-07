import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      backgroundColor: Colors.black,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xff202020),
                child: Text(
                  user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Tombol Menu (Hamburger) untuk membuka Drawer
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xff202020),
                ),
                child: IconButton(
                  // Mengganti ikon menu menjadi ikon logout
                  icon: const Icon(
                    Icons.logout,
                    size: 28,
                    color: Colors.white,
                  ), // Ukuran disesuaikan sedikit
                  tooltip: 'Logout', // Tambahan tooltip
                  onPressed: () {
                    // Langsung panggil dialog konfirmasi logout
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
                                  Navigator.pop(context); // Tutup dialog
                                  // Pindah ke halaman login (diasumsikan StreamBuilder di main.dart akan menangani ini)
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
          const SizedBox(height: 24),
          Text(
            'What are you doing today?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- REDESIGN: Widget untuk Search Bar ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search tasks...", // Ganti hint text
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 24, right: 10),
            child: Icon(Icons.search),
          ),
          filled: true,
          fillColor: Color(0xff202020), // Warna abu-abu muda
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // --- REDESIGN: Widget untuk Kategori ---
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
                ),
                _buildCategoryCard(
                  "Sport",
                  "+3 Task",
                  const Color(0xFFf0fcf0),
                  Icons.sports_basketball_outlined,
                ),
                _buildCategoryCard(
                  "Meet",
                  "+1 Task",
                  const Color(0xFFfff6e5),
                  Icons.group_outlined,
                ),
                _buildCategoryCard(
                  "Work",
                  "+10 Task",
                  const Color(0xFFD6EAF8),
                  Icons.work_outline,
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
          Icon(icon, size: 30),
          SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --- REDESIGN: Widget untuk Daftar Tugas (StreamBuilder) ---
  Widget _buildTodayTasks(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: Color(0xff1f1f1f),
          borderRadius: BorderRadius.only(
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
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('todo')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // ... (Kode StreamBuilder Anda yang lain tetap sama) ...
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

                        // Format waktu menggunakan intl
                        String formattedTime = 'No time';
                        if (time != null) {
                          formattedTime = DateFormat(
                            'd MMM, h:mm a',
                          ).format(time.toDate());
                        }

                        // --- REDESIGN: Tampilan Item Todo ---
                        return Card(
                          elevation: 0,
                          color: Colors.black, // Warna card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical:
                                  10.0, // <-- Atur padding vertikal di sini
                              horizontal:
                                  16.0, // <-- Ini adalah padding horizontal default
                            ),
                            onTap: () => _showEditTodoDialog(todo),
                            onLongPress: () => _showDeleteTodoDialog(todo),

                            leading: CircleAvatar(
                              backgroundColor: isChecked
                                  ? Colors.grey[300] // Warna latar hijau
                                  : Colors.green[100], // Warna latar abu-abu
                              child: Icon(
                                Icons.task_outlined,
                                color: isChecked
                                    ? Colors.grey[800]
                                    : Colors.green[800],
                              ),
                            ),

                            // Judul (sudah benar)
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isChecked
                                    ? Colors.grey[400]
                                    : Colors.white,
                              ),
                            ),

                            // --- PERUBAHAN 2: Subtitle ---
                            subtitle: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: isChecked
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                // Tambahkan strikethrough jika dicentang
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

  // --- REDESIGN: Widget untuk Drawer (Menu Samping) ---
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
              // Tutup drawer
              Navigator.pop(context);
              // Tampilkan dialog konfirmasi logout
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
