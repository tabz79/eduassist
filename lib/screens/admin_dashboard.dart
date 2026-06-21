import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DbService _dbService = DbService();
  int _currentStep = 0;
  bool _isLoading = false;

  // Configuration Fields
  final _academicYearController = TextEditingController(text: '2026-2027');
  final _classNameController = TextEditingController(text: 'Grade 5');
  final _sectionNameController = TextEditingController(text: 'A');
  final _sectionCapacityController = TextEditingController(text: '30');
  final _subjectNameController = TextEditingController(text: 'Mathematics');

  // Onboarding Fields - Teacher
  final _teacherNameController = TextEditingController();
  final _teacherPhoneController = TextEditingController();
  final _teacherSpecController = TextEditingController();

  // Onboarding Fields - Student
  final _studentNameController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  // Fee Fields
  final _feeTitleController = TextEditingController(text: 'Tuition Fee');
  final _feeAmountController = TextEditingController(text: '5000');

  // Lists for dropdown configurations
  final List<String> _activeClasses = ['Grade 4', 'Grade 2', 'Nursery'];
  List<UserModel> _schoolTeachers = [];
  List<Student> _schoolStudents = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final queryUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolId', isEqualTo: widget.admin.schoolId)
          .where('role', isEqualTo: 'teacher')
          .get();
      final teachers = queryUsers.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();

      final queryStudents = await FirebaseFirestore.instance
          .collection('students')
          .where('schoolId', isEqualTo: widget.admin.schoolId)
          .get();
      final students = queryStudents.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();

      setState(() {
        _schoolTeachers = teachers;
        _schoolStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading admin data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupAcademicYear() async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('academic_years').add({
      'schoolId': widget.admin.schoolId,
      'year': _academicYearController.text.trim(),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() => _isLoading = false);
    _showSuccess('Academic Year configured successfully!');
  }

  Future<void> _createClass() async {
    final cls = _classNameController.text.trim();
    if (cls.isEmpty) return;
    setState(() {
      if (!_activeClasses.contains(cls)) {
        _activeClasses.add(cls);
      }
    });
    _showSuccess('Class created successfully!');
  }

  Future<void> _createSection() async {
    final sec = _sectionNameController.text.trim();
    final cap = int.tryParse(_sectionCapacityController.text) ?? 30;
    _showSuccess('Section $sec configured with capacity $cap!');
  }

  Future<void> _createSubject() async {
    final sub = _subjectNameController.text.trim();
    _showSuccess('Subject $sub mapped to class ${_classNameController.text}!');
  }

  Future<void> _onboardTeacher() async {
    final name = _teacherNameController.text.trim();
    final phone = _teacherPhoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showWarning('Name and Phone are required.');
      return;
    }

    setState(() => _isLoading = true);
    final customId = _dbService.generateCustomId('TCH');
    await FirebaseFirestore.instance.collection('users').doc(customId).set({
      'name': name,
      'phone': phone,
      'role': 'teacher',
      'schoolId': widget.admin.schoolId,
      'specialization': _teacherSpecController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _teacherNameController.clear();
    _teacherPhoneController.clear();
    _teacherSpecController.clear();
    await _loadAdminData();
    _showSuccess('Teacher onboarded: $customId');
  }

  Future<void> _onboardStudentAndParent() async {
    final sName = _studentNameController.text.trim();
    final pName = _parentNameController.text.trim();
    final pPhone = _parentPhoneController.text.trim();
    final roll = int.tryParse(_studentRollController.text) ?? 1;

    if (sName.isEmpty || pName.isEmpty || pPhone.isEmpty) {
      _showWarning('Student Name, Parent Name, and Parent Phone are required.');
      return;
    }

    setState(() => _isLoading = true);
    String parentId = _dbService.generateCustomId('PAR');
    final queryParent = await _dbService.getUserByPhone(pPhone);
    if (queryParent != null) {
      parentId = queryParent.id;
    } else {
      await FirebaseFirestore.instance.collection('users').doc(parentId).set({
        'name': pName,
        'phone': pPhone,
        'role': 'parent',
        'schoolId': widget.admin.schoolId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final studentId = _dbService.generateCustomId('STU');
    await FirebaseFirestore.instance.collection('students').doc(studentId).set({
      'name': sName,
      'class': _classNameController.text.trim(),
      'parentId': parentId,
      'schoolId': widget.admin.schoolId,
    });

    await FirebaseFirestore.instance.collection('enrollments').doc("${studentId}_${_academicYearController.text}").set({
      'studentId': studentId,
      'schoolId': widget.admin.schoolId,
      'academicYear': _academicYearController.text.trim(),
      'class': _classNameController.text.trim(),
      'section': _sectionNameController.text.trim(),
      'rollNumber': roll,
    });

    _studentNameController.clear();
    _studentRollController.clear();
    _parentNameController.clear();
    _parentPhoneController.clear();
    await _loadAdminData();
    _showSuccess('Student admitted & Parent linked!');
  }

  Future<void> _createFees() async {
    final title = _feeTitleController.text.trim();
    final amount = double.tryParse(_feeAmountController.text) ?? 1000.0;

    setState(() => _isLoading = true);
    for (var s in _schoolStudents) {
      await FirebaseFirestore.instance.collection('fees').add({
        'studentId': s.id,
        'schoolId': widget.admin.schoolId,
        'title': title,
        'amount': amount,
        'status': 'pending',
        'dueDate': DateTime.now().add(const Duration(days: 30)),
        'paidDate': null,
        'receiptNo': null,
      });
    }
    setState(() => _isLoading = false);
    _showSuccess('Fee allocated successfully to ${_schoolStudents.length} students!');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left Sidebar Layout
          Container(
            width: 260,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EduAssist',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'Principal Console',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _buildSidebarItem(Icons.dashboard, 'Dashboard', true),
                _buildSidebarItem(Icons.people, 'Teachers', false),
                _buildSidebarItem(Icons.child_care, 'Students', false),
                _buildSidebarItem(Icons.wallet, 'Fees Structure', false),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Right Main Console Area
          Expanded(
            child: Column(
              children: [
                // Top Search & Welcome Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome back, ${widget.admin.name}! 👋',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
                          const SizedBox(width: 18),
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Text('IE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick stats summary cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      Icons.groups,
                                      'Students Enrolled',
                                      _schoolStudents.length.toString(),
                                      const Color(0xFFEFF6FF),
                                      const Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildMetricCard(
                                      Icons.person,
                                      'Faculty Members',
                                      _schoolTeachers.length.toString(),
                                      const Color(0xFFF0FDF4),
                                      const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildMetricCard(
                                      Icons.class_outlined,
                                      'Active Classes',
                                      _activeClasses.length.toString(),
                                      const Color(0xFFFFF7ED),
                                      const Color(0xFFF97316),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Core Stepper Wizard Layout
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Wizard Card (Flex 3)
                                  Expanded(
                                    flex: 3,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Stepper(
                                          type: StepperType.vertical,
                                          currentStep: _currentStep,
                                          onStepTapped: (step) => setState(() => _currentStep = step),
                                          onStepContinue: () {
                                            if (_currentStep < 4) {
                                              setState(() => _currentStep++);
                                            }
                                          },
                                          onStepCancel: () {
                                            if (_currentStep > 0) {
                                              setState(() => _currentStep--);
                                            }
                                          },
                                          steps: [
                                            Step(
                                              title: const Text('Academic Calendar Setup', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: _buildAcademicYearStep(),
                                              isActive: _currentStep >= 0,
                                            ),
                                            Step(
                                              title: const Text('Define Classes & Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: _buildClassesStep(),
                                              isActive: _currentStep >= 1,
                                            ),
                                            Step(
                                              title: const Text('Faculty Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: _buildTeacherStep(),
                                              isActive: _currentStep >= 2,
                                            ),
                                            Step(
                                              title: const Text('Student Admission & Linking', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: _buildStudentStep(),
                                              isActive: _currentStep >= 3,
                                            ),
                                            Step(
                                              title: const Text('Fee Allocations & Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: _buildFeesStep(),
                                              isActive: _currentStep >= 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right Quick Info Card (Flex 2)
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        _buildOnboardedListCard('Faculty Roster', _schoolTeachers, true),
                                        const SizedBox(height: 24),
                                        _buildOnboardedListCard('Admitted Students', _schoolStudents, false),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
        title: Text(
          title,
          style: TextStyle(
            color: active ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String value, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardedListCard(String title, List<dynamic> items, bool isTeacher) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: Text('${items.length} Active', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No entries added yet', style: TextStyle(color: Color(0xFF94A3B8)))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length > 5 ? 5 : items.length,
              separatorBuilder: (c, i) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isTeacher ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                      child: Text(
                        item.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isTeacher ? const Color(0xFF2563EB) : const Color(0xFF10B981)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(
                            isTeacher ? (item.specialization ?? 'Faculty') : 'Class ${item.className}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAcademicYearStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Establish the current operating calendar rules for registrations.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _academicYearController,
          decoration: const InputDecoration(labelText: 'Academic Operating Year'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _setupAcademicYear, child: const Text('Initialize Year')),
      ],
    );
  }

  Widget _buildClassesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Register default classrooms and catalog course sections.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _classNameController,
          decoration: const InputDecoration(labelText: 'Class Name'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sectionNameController,
                decoration: const InputDecoration(labelText: 'Section Code'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _sectionCapacityController,
                decoration: const InputDecoration(labelText: 'Student Capacity'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _subjectNameController,
          decoration: const InputDecoration(labelText: 'Primary Subject Map'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(onPressed: _createClass, child: const Text('Create Class')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _createSection, child: const Text('Create Section')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _createSubject, child: const Text('Map Subject')),
          ],
        ),
      ],
    );
  }

  Widget _buildTeacherStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create user login profiles for academic teaching staff.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _teacherNameController,
          decoration: const InputDecoration(labelText: 'Teacher Full Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _teacherPhoneController,
          decoration: const InputDecoration(labelText: 'Mobile Sign-In Number'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _teacherSpecController,
          decoration: const InputDecoration(labelText: 'Core Specialization Course'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _onboardTeacher, child: const Text('Onboard Teacher')),
      ],
    );
  }

  Widget _buildStudentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Register students, configure roll numbers and connect parent SMS accounts.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _studentNameController,
          decoration: const InputDecoration(labelText: 'Student Full Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _studentRollController,
          decoration: const InputDecoration(labelText: 'Class Roll Number'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _parentNameController,
          decoration: const InputDecoration(labelText: 'Parent/Guardian Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _parentPhoneController,
          decoration: const InputDecoration(labelText: 'Parent Sign-In Mobile'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _onboardStudentAndParent, child: const Text('Onboard Student')),
      ],
    );
  }

  Widget _buildFeesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Issue tuition structures and billing items school-wide.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _feeTitleController,
          decoration: const InputDecoration(labelText: 'Fee Account Title'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _feeAmountController,
          decoration: const InputDecoration(labelText: 'Billing Amount (INR)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _createFees, child: const Text('Allocate Fee Structure')),
      ],
    );
  }
}
