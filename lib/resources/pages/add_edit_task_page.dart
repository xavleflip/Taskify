import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/task.dart';
import '/app/networking/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditTaskPage extends NyStatefulWidget {
  static RouteView path = ("/add-edit-task", (_) => AddEditTaskPage());

  AddEditTaskPage({super.key}) : super(child: () => _AddEditTaskPageState());
}

class _AddEditTaskPageState extends NyPage<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  Task? _taskToEdit;
  String _selectedCategory = 'General';
  DateTime? _selectedDeadlineDate;
  TimeOfDay? _selectedDeadlineTime;
  bool _isImportant = false;
  bool _isSaving = false;

  @override
  get init => () async {
    _taskToEdit = widget.data() as Task?;
    if (_taskToEdit != null) {
      _titleController.text = _taskToEdit!.title;
      _descController.text = _taskToEdit!.description ?? '';
      _selectedCategory = _taskToEdit!.category;
      _isImportant = _taskToEdit!.isImportant;
      if (_taskToEdit!.deadline != null) {
        _selectedDeadlineDate = _taskToEdit!.deadline;
        _selectedDeadlineTime = TimeOfDay.fromDateTime(_taskToEdit!.deadline!);
      }
    }
  };

  // Helper to format date display in field
  String _getDateText() {
    if (_selectedDeadlineDate == null) return "mm/dd/yyyy";
    return "${_selectedDeadlineDate!.day.toString().padLeft(2, '0')}/${_selectedDeadlineDate!.month.toString().padLeft(2, '0')}/${_selectedDeadlineDate!.year}";
  }

  // Helper to format time display in field
  String _getTimeText() {
    if (_selectedDeadlineTime == null) return "--:--";
    return "${_selectedDeadlineTime!.hour.toString().padLeft(2, '0')}:${_selectedDeadlineTime!.minute.toString().padLeft(2, '0')}";
  }

  // Get color for category circles
  Color _getCategoryCircleColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'kampus':
        return const Color(0xFF2C5E8A);
      case 'organisasi':
        return const Color(0xFF8A3024);
      case 'pribadi':
        return const Color(0xFF2C6339);
      default:
        return Colors.blueGrey.shade700;
    }
  }

  // Get color for category backgrounds (when selected)
  Color _getCategoryBgColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'kampus':
        return const Color(0xFFCEE0F4);
      case 'organisasi':
        return const Color(0xFFF9D6D0);
      case 'pribadi':
        return const Color(0xFFD3EAD8);
      default:
        return const Color(0xFFE5E5E5);
    }
  }

  @override
  Widget view(BuildContext context) {
    final isEditMode = _taskToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4), // Soft cream canvas background
      
      // Custom Neo-brutalist App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  )
                ]
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: Text(
          isEditMode ? "UBAH KEGIATAN" : "TAMBAH KEGIATAN",
          style: GoogleFonts.bebasNeue(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 2.0,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title Input Section
                Text(
                  "NAMA KEGIATAN",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Misal: Rapat Bem",
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: const Color(0xFFFCF9F2),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.2),
                        borderRadius: BorderRadius.zero,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red, width: 2.2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Nama kegiatan tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Description Input Section
                Text(
                  "DESKRIPSI",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Detail kegiatan...",
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: const Color(0xFFFCF9F2),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Category Chip Selector
                Text(
                  "KATEGORI",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Kampus', 'Organisasi', 'Pribadi', 'General'].map((cat) {
                      final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? _getCategoryBgColor(cat) : Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: isSelected
                                  ? null
                                  : const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getCategoryCircleColor(cat),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected ? _getCategoryTextColor(cat) : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Date & Time Picker Section (Horizontal Layout)
                Row(
                  children: [
                    // Date picker field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TANGGAL",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              child: Text(
                                _getDateText(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedDeadlineDate == null ? Colors.black54 : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Time picker field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WAKTU",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              child: Text(
                                _getTimeText(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedDeadlineTime == null ? Colors.black54 : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 5. Mark as Important Switch
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFEA),
                    border: Border.all(color: Colors.black, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "TANDAI PENTING",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isImportant,
                        activeColor: const Color(0xFF9E3A25),
                        activeTrackColor: const Color(0xFFF9D6D0),
                        inactiveThumbColor: Colors.grey.shade700,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: (val) {
                          setState(() {
                            _isImportant = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 6. Cancel & Save buttons
                _isSaving
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : Row(
                        children: [
                          // BATAL (Cancel)
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "BATAL",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // SIMPAN (Save)
                          Expanded(
                            child: InkWell(
                              onTap: _saveTask,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9E3A25), // Terracotta
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      "SIMPAN",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Date picker launch
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadlineDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDeadlineDate = pickedDate;
      });
    }
  }

  // Time picker launch
  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDeadlineTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDeadlineTime = pickedTime;
      });
    }
  }

  // Get category font color
  Color _getCategoryTextColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'kampus':
        return const Color(0xFF2C5E8A);
      case 'organisasi':
        return const Color(0xFF8A3024);
      case 'pribadi':
        return const Color(0xFF2C6339);
      default:
        return Colors.black87;
    }
  }

  // Save changes to database
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      showToastDanger(
        title: "Session Expired",
        description: "Please log in again.",
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    DateTime? deadline;
    if (_selectedDeadlineDate != null) {
      final hour = _selectedDeadlineTime?.hour ?? 0;
      final minute = _selectedDeadlineTime?.minute ?? 0;
      deadline = DateTime(
        _selectedDeadlineDate!.year,
        _selectedDeadlineDate!.month,
        _selectedDeadlineDate!.day,
        hour,
        minute,
      );
    }

    final task = Task(
      id: _taskToEdit?.id,
      userId: currentUser.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _selectedCategory,
      deadline: deadline,
      isCompleted: _taskToEdit?.isCompleted ?? false,
      isImportant: _isImportant,
      createdAt: _taskToEdit?.createdAt,
    );

    try {
      final service = SupabaseService();
      if (_taskToEdit == null) {
        await service.createTask(task);
      } else {
        await service.updateTask(task);
      }

      // Update dashboard state
      updateState('dashboard');
      Navigator.pop(context);
    } catch (e) {
      showToastDanger(
        title: "Error Saving Activity",
        description: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
