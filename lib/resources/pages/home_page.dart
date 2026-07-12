import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/task_controller.dart';
import '/app/models/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends NyStatefulWidget<TaskController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  int _selectedTabIndex = 0; // 0 = KEGIATAN AKTIF, 1 = RIWAYAT
  int _currentBottomNavIndex = 0; // 0 = TASKS, 1 = HISTORY, 2 = PROFILE

  @override
  get init => () async {
    // Register this page's state with the key 'dashboard' so the controller can update it
    stateKey = 'dashboard';
    await widget.controller.loadTasks();
  };

  // Helper to format Indonesian date without external dependency issues
  String _getIndonesianDate() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[now.weekday % 7];
    final monthName = months[now.month - 1];
    return "$dayName, ${now.day} $monthName ${now.year}";
  }

  // Helper to format deadline date cleanly
  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return "";
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    
    String timeStr = "${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}";
    
    if (difference == 0 && deadline.day == now.day) {
      return "Hari ini, $timeStr";
    } else if (difference == 1 || (difference == 0 && deadline.day == now.day + 1)) {
      return "Besok, $timeStr";
    } else {
      return "${deadline.day}/${deadline.month}/${deadline.year}, $timeStr";
    }
  }

  // Get color for category chip based on category name
  Color _getCategoryBgColor(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains('kampus') || catLower.contains('school') || catLower.contains('study')) {
      return const Color(0xFFCEE0F4); // Desaturated soft blue
    } else if (catLower.contains('organisasi') || catLower.contains('org') || catLower.contains('work')) {
      return const Color(0xFFF9D6D0); // Desaturated soft pink/orange
    } else if (catLower.contains('pribadi') || catLower.contains('personal') || catLower.contains('private')) {
      return const Color(0xFFD3EAD8); // Desaturated soft green
    }
    return const Color(0xFFE5E5E5); // Desaturated grey
  }

  // Get category text color
  Color _getCategoryTextColor(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains('kampus') || catLower.contains('school') || catLower.contains('study')) {
      return const Color(0xFF2C5E8A);
    } else if (catLower.contains('organisasi') || catLower.contains('org') || catLower.contains('work')) {
      return const Color(0xFF8A3024);
    } else if (catLower.contains('pribadi') || catLower.contains('personal') || catLower.contains('private')) {
      return const Color(0xFF2C6339);
    }
    return Colors.black87;
  }

  @override
  Widget view(BuildContext context) {
    final controller = widget.controller;
    final currentUser = Supabase.instance.client.auth.currentUser;
    // Extract user display name from email or fall back to "ABI"
    final userName = currentUser?.email != null 
        ? currentUser!.email!.split('@')[0].toUpperCase() 
        : "ABI";

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4), // Warm cream background
      
      // Custom App Bar (Neo-brutalist style)
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }
        ),
        title: Text(
          "TASK.BLOK",
          style: GoogleFonts.bebasNeue(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
        actions: [
          // Circular Avatar with black border
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9E3A25),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0] : "A",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 2.0,
          ),
        ),
      ),

      // Left Navigation Drawer
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFFFBF4),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFFCF9F2),
                  border: Border(bottom: BorderSide(color: Colors.black, width: 2.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.bebasNeue(fontSize: 32, letterSpacing: 1.2),
                    ),
                    Text(
                      currentUser?.email ?? "anonymous@taskify.com",
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Keluar Akun",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    routeTo('/login', navigationType: NavigationType.pushAndForgetAll);
                  }
                },
              ),
            ],
          ),
        ),
      ),

      // Dashboard Body
      body: _currentBottomNavIndex == 2 
          ? _buildProfileView(userName, currentUser?.email)
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadTasks();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    // Greeting text (Bebas Neue)
                    Text(
                      "HALO, $userName!",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Today's Date (Montserrat)
                    Text(
                      _getIndonesianDate(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filter Tab Container (Neo-brutalist styled)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTabButton("KEGIATAN AKTIF", index: 0)),
                          Container(width: 2.5, height: 48, color: Colors.black),
                          Expanded(child: _buildTabButton("RIWAYAT", index: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Task Listing
                    controller.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: CircularProgressIndicator(color: Colors.black),
                            ),
                          )
                        : _buildTasksList(controller),
                  ],
                ),
              ),
            ),

      // Floating Action Button (Neo-brutalist square)
      floatingActionButton: FloatingActionButton(
        onPressed: () => routeTo('/add-edit-task'),
        backgroundColor: const Color(0xFF9E3A25), // Terracotta
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.zero,
        ),
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 0,
              )
            ]
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),

      // Custom Bottom Navigation Bar (Neo-brutalist layout)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 2.5),
          ),
          color: Color(0xFFFCF9F2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavButton(
              index: 0,
              icon: Icons.list_alt,
              label: "TASKS",
            ),
            _buildBottomNavButton(
              index: 1,
              icon: Icons.history,
              label: "HISTORY",
            ),
            _buildBottomNavButton(
              index: 2,
              icon: Icons.person_outline,
              label: "PROFILE",
            ),
          ],
        ),
      ),
    );
  }

  // Top Filter Tab Button
  Widget _buildTabButton(String label, {required int index}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        height: 48,
        color: isSelected ? const Color(0xFFD95B43) : Colors.white, // Coral select / white
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Bar Button
  Widget _buildBottomNavButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentBottomNavIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentBottomNavIndex = index;
          if (index == 0) {
            _selectedTabIndex = 0; // Show active tasks
          } else if (index == 1) {
            _selectedTabIndex = 1; // Show history tab
            _currentBottomNavIndex = 0; // Keep the active page on tasks view with riwayat filter
          }
        });
      },
      child: isSelected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD95B43),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black54, size: 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
    );
  }

  // Render list of task cards
  Widget _buildTasksList(TaskController controller) {
    final tasks = _selectedTabIndex == 0 ? controller.activeTasks : controller.completedTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  color: const Color(0xFFD3EAD8),
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                "Terus semangat! Tambah kegiatan baru.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  // Neo-brutalist Task Card Widget
  Widget _buildTaskCard(Task task) {
    final controller = widget.controller;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF6), // Cream background card
        border: Border.all(color: Colors.black, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () {
              // Option to edit on long press
              routeTo('/add-edit-task', data: task);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Neo-brutalist Styled Checkbox
                  GestureDetector(
                    onTap: () {
                      controller.toggleStatus(task);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted ? const Color(0xFFD95B43) : Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Task Title and Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Category Tag with desaturated background and black border
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getCategoryBgColor(task.category),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                task.category.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: _getCategoryTextColor(task.category),
                                ),
                              ),
                            ),
                            
                            // Deadline formatted string
                            if (task.deadline != null) ...[
                              const SizedBox(width: 10),
                              const Icon(Icons.calendar_today, size: 13, color: Colors.black87),
                              const SizedBox(width: 4),
                              Text(
                                _formatDeadline(task.deadline),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Flag indicator if task is marked as important
                  if (task.isImportant)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Profile view fallback
  Widget _buildProfileView(String userName, String? email) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCF9F2),
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9E3A25),
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0] : "A",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: GoogleFonts.bebasNeue(fontSize: 36, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? "anonymous@taskify.com",
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) {
                      routeTo('/login', navigationType: NavigationType.pushAndForgetAll);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E3A25),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      "KELUAR AKUN",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
