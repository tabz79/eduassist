import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:eduassist_app/screens/mobile_frame.dart';
import 'package:eduassist_app/widgets/edu_design_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherDashboard extends StatefulWidget {
  final UserModel teacher;

  const TeacherDashboard({super.key, required this.teacher});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final DbService _dbService = DbService();
  int _selectedIndex = 0; // 0 = Home/Dashboard, 1 = Classes workspace list, 2 = Calendar/Syllabus, 3 = Notifications, 4 = Profile
  bool _isLoading = false;

  // Selected class for actions
  String _selectedClass = 'Grade 4';
  List<Student> _classStudents = [];
  Map<String, String> _attendanceMap = {}; // studentId -> status ('present', 'absent', 'reported_absent')

  // Search query for student list in attendance
  String _searchQuery = '';

  // Classroom Update controller fields
  final _subjectController = TextEditingController(text: 'Science');
  final _chapterController = TextEditingController(text: 'Fractions');
  final _topicController = TextEditingController();
  final _homeworkController = TextEditingController();

  // Test & Marks fields
  List<TestConfig> _tests = [];
  TestConfig? _selectedTest;
  Map<String, TextEditingController> _marksControllers = {};
  Map<String, String> _marksStatusMap = {};
  final _newTestNameController = TextEditingController();
  final _maxMarksController = TextEditingController(text: '20');

  // Seeded classes Mrs. Priya Patel can see
  final List<String> _myClasses = ['Grade 4', 'Grade 2', 'Nursery'];

  // Current view controller for deep-dives (e.g., 'main_dashboard', 'attendance_grid', 'post_update', 'create_test', 'enter_marks')
  String _currentView = 'main_dashboard';

  @override
  void initState() {
    super.initState();
    _loadClassStudents();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _homeworkController.dispose();
    _subjectController.dispose();
    _chapterController.dispose();
    _newTestNameController.dispose();
    _maxMarksController.dispose();
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadClassStudents() async {
    setState(() => _isLoading = true);
    try {
      final enrollments = await _dbService.getEnrollmentsForClass(widget.teacher.schoolId, _selectedClass);
      final studentIds = enrollments.map((e) => e.studentId).toList();
      final students = await _dbService.getStudentsByIds(widget.teacher.schoolId, studentIds);

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final queryAttendance = await FirebaseFirestore.instance
          .collection('attendance')
          .where('schoolId', isEqualTo: widget.teacher.schoolId)
          .where('date', isEqualTo: todayStr)
          .get();
      final Map<String, String> existingAttendance = {
        for (var doc in queryAttendance.docs)
          doc.data()['studentId'] ?? '': doc.data()['status'] ?? 'present'
      };

      setState(() {
        _classStudents = students;
        _attendanceMap = {
          for (var s in students)
            s.id: existingAttendance[s.id] ?? 'present'
        };
      });

      await _loadTests();
      setState(() => _isLoading = false);
    } catch (e) {
      print("Error loading class students: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTests() async {
    try {
      final tests = await _dbService.getTestsForClass(widget.teacher.schoolId, _selectedClass);
      setState(() {
        _tests = tests;
        if (tests.isNotEmpty) {
          _selectedTest = tests.first;
          _initMarksControllers();
        } else {
          _selectedTest = null;
          _marksControllers.clear();
          _marksStatusMap.clear();
        }
      });
    } catch (e) {
      print("Error loading tests: $e");
    }
  }

  void _initMarksControllers() {
    _marksControllers = {
      for (var s in _classStudents) s.id: TextEditingController(text: '18')
    };
    _marksStatusMap = {
      for (var s in _classStudents) s.id: 'present'
    };
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int successCount = 0;

    for (var entry in _attendanceMap.entries) {
      final success = await _dbService.markAttendance(
        studentId: entry.key,
        schoolId: widget.teacher.schoolId,
        date: todayStr,
        status: entry.value,
        teacherId: widget.teacher.id,
      );
      if (success) successCount++;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance Saved! ($successCount marked)'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _currentView = 'main_dashboard';
      });
    }
  }

  Future<void> _submitClassroomUpdate() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Topic Covered cannot be empty'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _dbService.postClassroomUpdate(
      schoolId: widget.teacher.schoolId,
      teacherId: widget.teacher.id,
      className: _selectedClass,
      section: 'A',
      subject: _subjectController.text.trim(),
      chapter: _chapterController.text.trim(),
      topicCovered: _topicController.text.trim(),
      homework: _homeworkController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted successfully!'), backgroundColor: Colors.green),
        );
        _topicController.clear();
        _homeworkController.clear();
        setState(() {
          _currentView = 'main_dashboard';
        });
      }
    }
  }

  Future<void> _createTest() async {
    final name = _newTestNameController.text.trim();
    final maxMarks = double.tryParse(_maxMarksController.text) ?? 20.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test Name cannot be empty'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _dbService.createTestConfig(
      schoolId: widget.teacher.schoolId,
      className: _selectedClass,
      subject: _subjectController.text.trim(),
      testName: name,
      maxMarks: maxMarks,
      date: DateTime.now().toIso8601String().substring(0, 10),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test created successfully!'), backgroundColor: Colors.green),
        );
        _newTestNameController.clear();
        await _loadTests();
        setState(() {
          _currentView = 'enter_marks';
        });
      }
    }
  }

  Future<void> _submitGrades() async {
    if (_selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a test first'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    int successCount = 0;

    for (var student in _classStudents) {
      final status = _marksStatusMap[student.id] ?? 'present';
      double obtained = 0.0;
      String gradeStr = 'F';

      if (status == 'present') {
        obtained = double.tryParse(_marksControllers[student.id]?.text ?? '0') ?? 0.0;
        final pct = (obtained / _selectedTest!.maxMarks) * 100;
        if (pct >= 95) gradeStr = 'A+';
        else if (pct >= 85) gradeStr = 'A';
        else if (pct >= 70) gradeStr = 'B';
        else if (pct >= 50) gradeStr = 'C';
        else if (pct >= 35) gradeStr = 'D';
        else gradeStr = 'F';
      } else if (status == 'absent') {
        gradeStr = 'Absent';
      } else {
        gradeStr = 'Exempted';
      }

      final success = await _dbService.inputMarks(
        studentId: student.id,
        schoolId: widget.teacher.schoolId,
        subject: _selectedTest!.subject,
        examName: _selectedTest!.testName,
        marksObtained: obtained,
        maxMarks: _selectedTest!.maxMarks,
        grade: gradeStr,
        teacherId: widget.teacher.id,
      );

      if (success) successCount++;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grades submitted successfully! ($successCount marked)'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _currentView = 'main_dashboard';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      bottomNavigationBar: _buildBottomNav(),
      child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentBody(),
    );
  }

  Widget _buildCurrentBody() {
    switch (_selectedIndex) {
      case 0:
        switch (_currentView) {
          case 'attendance_grid':
            return _buildAttendanceSubView();
          case 'post_update':
            return _buildPostUpdateSubView();
          case 'create_test':
            return _buildCreateTestSubView();
          case 'enter_marks':
            return _buildEnterMarksSubView();
          case 'notifications':
            return _buildNotificationsScreen();
          case 'calendar':
            return _buildCalendarScreen();
          default:
            return _buildMainDashboardSubView();
        }
      case 1:
        return _buildClassesScreen();
      case 2:
        return _buildStudentsScreen();
      case 3:
        return _buildProfileScreen();
      case 4:
        return _buildMoreScreen();
      default:
        return _buildMainDashboardSubView();
    }
  }

  // --- SCREEN 2: MAIN DASHBOARD VIEW ---
  Widget _buildMainDashboardSubView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Header Accent Profile Card: Clean light-teal container matching mockup
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF0FAF8),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F9F90).withValues(alpha: 0.15), width: 1.5),
                        ),
                        child: EduAvatar(
                          name: widget.teacher.name,
                          size: 44,
                        ),
                      ),
                      const SizedBox(width: EduTheme.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning, 👋',
                            style: EduTheme.typographyMeta.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.teacher.name,
                            style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Bell Notifications Button with badge '3'
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_outlined, color: EduTheme.colorTextDark),
                              onPressed: () {
                                setState(() {
                                  _currentView = 'notifications';
                                });
                              },
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: EduTheme.space8),
                      // Logout button
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_outlined, color: EduTheme.colorTextDark),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: EduTheme.space24),
              // Clean Class Teacher Card
              EduCard(
                color: Colors.white,
                padding: const EdgeInsets.all(EduTheme.space16),
                shadow: EduTheme.shadowLevel1,
                borderRadius: EduTheme.radius20,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(EduTheme.space12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F5F4),
                        borderRadius: EduTheme.radius16,
                      ),
                      child: const Icon(Icons.people_outline, color: EduTheme.colorPrimaryBrandTeal, size: 24),
                    ),
                    const SizedBox(width: EduTheme.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class Teacher',
                            style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_selectedClass • Section A',
                            style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    // Circular progress indicator showing 85% Syllabus
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              value: 0.85,
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(EduTheme.colorPrimaryBrandTeal),
                              backgroundColor: Color(0xFFF1F5F9),
                            ),
                          ),
                          Text(
                            '85%',
                            style: EduTheme.typographyMeta.copyWith(
                              fontWeight: FontWeight.bold,
                              color: EduTheme.colorTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal week calendar slider
        _buildWeekCalendarSlider(),

        // Today's Schedule Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Schedule",
                    style: EduTheme.typographyHeading.copyWith(color: EduTheme.colorTextDark, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Text(
                      'View All',
                      style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorPrimaryBrandTeal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: EduTheme.space4),
              _buildPeriodItem(
                'Period 1',
                'Grade 4 Science',
                '8:00 - 8:45 AM',
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Grade 4';
                    _currentView = 'attendance_grid';
                  });
                  _loadClassStudents();
                },
              ),
              _buildPeriodItem(
                'Period 2',
                'Grade 2 Science',
                '8:50 - 9:35 AM',
                const Color(0xFF10B981),
                const Color(0xFFECFDF5),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Grade 2';
                    _currentView = 'attendance_grid';
                  });
                  _loadClassStudents();
                },
              ),
              _buildPeriodItem(
                'Period 3',
                'Nursery Science',
                '9:40 - 10:25 AM',
                const Color(0xFF8B5CF6),
                const Color(0xFFF5F3FF),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Nursery';
                    _currentView = 'attendance_grid';
                  });
                  _loadClassStudents();
                },
              ),
            ],
          ),
        ),

        // Quick Actions Grid (4 white cards)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Actions",
                style: EduTheme.typographyHeading.copyWith(color: EduTheme.colorTextDark, fontSize: 18),
              ),
              const SizedBox(height: EduTheme.space16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.how_to_reg,
                    label: 'Attendance',
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    onTap: () {
                      setState(() {
                        _selectedClass = 'Grade 4';
                        _currentView = 'attendance_grid';
                      });
                      _loadClassStudents();
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.post_add,
                    label: 'Post Update',
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    onTap: () {
                      setState(() {
                        _currentView = 'post_update';
                      });
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.assignment_outlined,
                    label: 'Assignments',
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFFEFF6FF),
                    onTap: () {
                      setState(() {
                        _currentView = 'create_test';
                      });
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.more_horiz,
                    label: 'More',
                    iconColor: const Color(0xFFF97316),
                    iconBgColor: const Color(0xFFFFF7ED),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pending Tasks Checklist
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pending Tasks",
                style: EduTheme.typographyHeading.copyWith(color: EduTheme.colorTextDark, fontSize: 18),
              ),
              const SizedBox(height: EduTheme.space12),
              // Attendance Task
              EduCard(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                padding: const EdgeInsets.all(EduTheme.space16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, color: Color(0xFFF97316), size: 20),
                    ),
                    const SizedBox(width: EduTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grade 4 Attendance',
                            style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mark today\'s attendance for Grade 4 Science',
                            style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: EduTheme.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Text(
                        'Pending',
                        style: EduTheme.typographyMeta.copyWith(
                          color: const Color(0xFFC2410C),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Grade 4';
                    _currentView = 'attendance_grid';
                  });
                  _loadClassStudents();
                },
              ),
              const SizedBox(height: 12),
              // Homework Review Task
              EduCard(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                padding: const EdgeInsets.all(EduTheme.space16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Color(0xFF8B5CF6), size: 20),
                    ),
                    const SizedBox(width: EduTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Homework Review',
                            style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Share topic and homework for Grade 2',
                            style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: EduTheme.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Text(
                        'Pending',
                        style: EduTheme.typographyMeta.copyWith(
                          color: const Color(0xFFC2410C),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Grade 2';
                    _currentView = 'post_update';
                  });
                },
              ),
              const SizedBox(height: 12),
              // Test - Fractions Task
              EduCard(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                padding: const EdgeInsets.all(EduTheme.space16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.grade_outlined, color: Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: EduTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test - Fractions',
                            style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Enter exam marks for Grade 4 topic fractions',
                            style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: EduTheme.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Text(
                        'Pending',
                        style: EduTheme.typographyMeta.copyWith(
                          color: const Color(0xFFC2410C),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedClass = 'Grade 4';
                    _currentView = 'enter_marks';
                  });
                  _loadClassStudents();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendarSlider() {
    final days = [
      {'name': 'MON', 'day': '14', 'selected': false},
      {'name': 'TUE', 'day': '15', 'selected': true},
      {'name': 'WED', 'day': '16', 'selected': false},
      {'name': 'THU', 'day': '17', 'selected': false},
      {'name': 'FRI', 'day': '18', 'selected': false},
      {'name': 'SAT', 'day': '19', 'selected': false},
      {'name': 'SUN', 'day': '20', 'selected': false},
    ];

    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(vertical: EduTheme.space12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day['selected'] as bool;
          return Container(
            width: 50,
            decoration: BoxDecoration(
              color: isSelected ? EduTheme.colorPrimaryBrandTeal : const Color(0xFFF8FAFC),
              borderRadius: EduTheme.radius24,
              border: Border.all(
                color: isSelected ? EduTheme.colorPrimaryBrandTeal : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day['name'] as String,
                  style: EduTheme.typographyMeta.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  day['day'] as String,
                  style: EduTheme.typographyCaption.copyWith(
                    color: isSelected ? Colors.white : EduTheme.colorTextDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodItem(String period, String classNameSubject, String time, Color themeColor, Color bgColor, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: EduTheme.radius16,
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [EduTheme.shadowLevel1],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.people_alt_outlined, color: themeColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period,
                    style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    classNameSubject,
                    style: EduTheme.typographyBody.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return EduCard(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1F5F9)),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: EduTheme.typographyMeta.copyWith(
              color: EduTheme.colorTextDark,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- SCREEN 3: MY CLASSES SCREEN ---
  Widget _buildClassesScreen() {
    final Map<String, int> syllabusProgress = {
      'Grade 4': 85,
      'Grade 2': 72,
      'Nursery': 60,
    };
    final Map<String, int> studentCounts = {
      'Grade 4': 30,
      'Grade 2': 28,
      'Nursery': 25,
    };
    final Map<String, String> subjects = {
      'Grade 4': 'Science',
      'Grade 2': 'Science',
      'Nursery': 'General Knowledge',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Classes',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: EduTheme.colorTextDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adding a class is only available for admins.')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _myClasses.length,
        separatorBuilder: (c, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final clsName = _myClasses[index];
          final progress = syllabusProgress[clsName] ?? 50;
          final count = studentCounts[clsName] ?? 30;
          final subject = subjects[clsName] ?? 'Science';

          Color bgAccent = const Color(0xFFEFF6FF);
          Color iconColor = const Color(0xFF3B82F6);
          if (index == 1) {
            bgAccent = const Color(0xFFF0FDF4);
            iconColor = const Color(0xFF10B981);
          } else if (index == 2) {
            bgAccent = const Color(0xFFFFF7ED);
            iconColor = const Color(0xFFF97316);
          }

          return EduCard(
            color: Colors.white,
            padding: const EdgeInsets.all(EduTheme.space24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(EduTheme.space12),
                  decoration: BoxDecoration(
                    color: bgAccent,
                    borderRadius: EduTheme.radius16,
                  ),
                  child: Icon(Icons.school_outlined, color: iconColor, size: 24),
                ),
                const SizedBox(width: EduTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$clsName • Section A',
                        style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$subject  •  $count Students',
                        style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: EduTheme.space8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress / 100,
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                            backgroundColor: const Color(0xFFF1F5F9),
                          ),
                          Text(
                            '$progress%',
                            style: EduTheme.typographyMeta.copyWith(
                              fontWeight: FontWeight.bold,
                              color: EduTheme.colorTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Syllabus',
                      style: EduTheme.typographyMeta.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: EduTheme.space12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedClass = clsName;
                      _selectedIndex = 0;
                      _currentView = 'attendance_grid';
                    });
                    _loadClassStudents();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SCREEN 5: TAKE ATTENDANCE VIEW ---
  Widget _buildAttendanceSubView() {
    final filteredStudents = _classStudents.where((student) {
      return student.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    int presentCount = _attendanceMap.values.where((v) => v == 'present').length;
    int absentCount = _attendanceMap.values.where((v) => v == 'absent').length;
    int reportedCount = _attendanceMap.values.where((v) => v == 'reported_absent').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Take Attendance',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
            ),
            Text(
              '$_selectedClass  •  Science',
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () {
            setState(() {
              _currentView = 'main_dashboard';
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: EduTheme.colorTextDark, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Pill Counters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCountPill('Present', presentCount, const Color(0xFFECFDF5), const Color(0xFF047857)),
                _buildStatusCountPill('Absent', absentCount, const Color(0xFFFEF2F2), const Color(0xFFB91C1C)),
                _buildStatusCountPill('Reported', reportedCount, const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: EduTheme.radius16,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: EduTheme.typographyCaption.copyWith(color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: EduTheme.radius16,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.tune, color: Color(0xFF64748B), size: 20),
                ),
              ],
            ),
          ),
          // Student List
          Expanded(
            child: filteredStudents.isEmpty
                ? const EduEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No Students Found',
                    description: 'No students match your search criteria.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final status = _attendanceMap[student.id] ?? 'present';

                      Color capsuleBg = const Color(0xFFECFDF5);
                      Color capsuleText = const Color(0xFF047857);
                      IconData statusIcon = Icons.check_circle_outline;
                      String statusTextLabel = 'Present';

                      if (status == 'absent') {
                        capsuleBg = const Color(0xFFFEF2F2);
                        capsuleText = const Color(0xFFB91C1C);
                        statusIcon = Icons.highlight_off;
                        statusTextLabel = 'Absent';
                      } else if (status == 'reported_absent') {
                        capsuleBg = const Color(0xFFFFF7ED);
                        capsuleText = const Color(0xFFC2410C);
                        statusIcon = Icons.warning_amber_rounded;
                        statusTextLabel = 'Reported';
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: EduTheme.radius20,
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [EduTheme.shadowLevel1],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                              ),
                              child: EduAvatar(
                                name: student.name,
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${student.name}',
                                    style: EduTheme.typographyBody.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Roll No. ${index + 12}',
                                    style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (status == 'present') {
                                    _attendanceMap[student.id] = 'absent';
                                  } else if (status == 'absent') {
                                    _attendanceMap[student.id] = 'reported_absent';
                                  } else {
                                    _attendanceMap[student.id] = 'present';
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: capsuleBg,
                                  borderRadius: EduTheme.radius16,
                                  border: Border.all(color: capsuleText.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, color: capsuleText, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusTextLabel,
                                      style: EduTheme.typographyMeta.copyWith(color: capsuleText, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: EduTheme.radius16,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: EduTheme.radius16),
                ),
                child: Text(
                  'Save Attendance',
                  style: EduTheme.typographyBody.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCountPill(String label, int count, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: EduTheme.radius20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: EduTheme.typographyMeta.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: EduTheme.typographyMeta.copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // --- SCREEN 6: POST CLASS UPDATE VIEW ---
  Widget _buildPostUpdateSubView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Post Class Update',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
            ),
            Text(
              '$_selectedClass  •  Science',
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () {
            setState(() {
              _currentView = 'main_dashboard';
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: _buildInputDecoration('Select Class'),
              items: _myClasses.map((String c) {
                return DropdownMenuItem<String>(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedClass = val;
                  });
                }
              },
            ),
            const SizedBox(height: EduTheme.space16),
            DropdownButtonFormField<String>(
              value: _subjectController.text,
              decoration: _buildInputDecoration('Subject'),
              items: ['Science', 'Mathematics', 'English', 'General Knowledge'].map((String s) {
                return DropdownMenuItem<String>(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _subjectController.text = val;
                  });
                }
              },
            ),
            const SizedBox(height: EduTheme.space16),
            DropdownButtonFormField<String>(
              value: _chapterController.text,
              decoration: _buildInputDecoration('Chapter'),
              items: ['Fractions', 'Forces and Motion', 'Living Things', 'Environment'].map((String c) {
                return DropdownMenuItem<String>(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _chapterController.text = val;
                  });
                }
              },
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              controller: _topicController,
              decoration: _buildInputDecoration('Topic Covered').copyWith(
                hintText: 'e.g. Addition and Subtraction of Fractions',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              controller: _homeworkController,
              decoration: _buildInputDecoration('Homework Assigned (Optional)').copyWith(
                hintText: 'e.g. Solve exercises 1 to 5',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              decoration: _buildInputDecoration('Notes (Optional)').copyWith(
                hintText: 'e.g. Revise fraction basics',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: EduTheme.space24),
            Text(
              'Blackboard Photo (Optional)',
              style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: EduTheme.space8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: EduTheme.radius16,
                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B), size: 24),
                    ),
                    const SizedBox(height: EduTheme.space8),
                    Text(
                      'Upload Blackboard Photo',
                      style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: EduTheme.space32),
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: EduTheme.radius16,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitClassroomUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: EduTheme.radius16),
                ),
                child: Text(
                  'Publish Update',
                  style: EduTheme.typographyBody.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: EduTheme.radius16,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: EduTheme.radius16,
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // --- SCREEN 8: CREATE TEST VIEW ---
  Widget _buildCreateTestSubView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Create Test',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
            ),
            Text(
              '$_selectedClass  •  Science',
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () {
            setState(() {
              _currentView = 'main_dashboard';
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _newTestNameController,
              decoration: _buildInputDecoration('Test Name').copyWith(
                hintText: 'e.g. Fractions Quiz',
              ),
            ),
            const SizedBox(height: EduTheme.space16),
            DropdownButtonFormField<String>(
              value: _subjectController.text,
              decoration: _buildInputDecoration('Subject'),
              items: ['Science', 'Mathematics', 'English', 'General Knowledge'].map((String s) {
                return DropdownMenuItem<String>(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _subjectController.text = val;
                  });
                }
              },
            ),
            const SizedBox(height: EduTheme.space16),
            DropdownButtonFormField<String>(
              value: _chapterController.text,
              decoration: _buildInputDecoration('Chapter'),
              items: ['Fractions', 'Forces and Motion', 'Living Things', 'Environment'].map((String c) {
                return DropdownMenuItem<String>(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _chapterController.text = val;
                  });
                }
              },
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              controller: _maxMarksController,
              decoration: _buildInputDecoration('Maximum Marks').copyWith(
                hintText: 'e.g. 20',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              decoration: _buildInputDecoration('Test Date').copyWith(
                hintText: '20 July 2026',
                suffixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 20),
              ),
              readOnly: true,
              onTap: () {},
            ),
            const SizedBox(height: EduTheme.space16),
            TextFormField(
              decoration: _buildInputDecoration('Description (Optional)').copyWith(
                hintText: 'Short quiz on basic fractions.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: EduTheme.space32),
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: EduTheme.radius16,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _createTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: EduTheme.radius16),
                ),
                child: Text(
                  'Create Test',
                  style: EduTheme.typographyBody.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 9: ENTER MARKS VIEW ---
  Widget _buildEnterMarksSubView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Enter Marks',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
            ),
            Text(
              '$_selectedClass  •  Science',
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () {
            setState(() {
              _currentView = 'main_dashboard';
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_tests.isEmpty)
            const Expanded(
              child: EduEmptyState(
                icon: Icons.assignment_late_outlined,
                title: 'No Tests Configured',
                description: 'Please go back and create a test config first.',
              ),
            )
          else ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Select Test: ',
                    style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: EduTheme.radius12,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TestConfig>(
                          value: _selectedTest,
                          isExpanded: true,
                          items: _tests.map((TestConfig t) {
                            return DropdownMenuItem<TestConfig>(
                              value: t,
                              child: Text(
                                '${t.testName} (Max: ${t.maxMarks.toInt()})',
                                style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTest = val;
                                _initMarksControllers();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _classStudents.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = _classStudents[index];
                  final controller = _marksControllers[student.id];
                  final status = _marksStatusMap[student.id] ?? 'present';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: EduTheme.radius20,
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [EduTheme.shadowLevel1],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://api.dicebear.com/7.x/adventurer/png?seed=${student.name}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const CircleAvatar(
                                backgroundColor: Color(0xFFEFF6FF),
                                child: Icon(Icons.person, color: Color(0xFF14B8A6)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: EduTheme.typographyBody.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Roll No: ${index + 12}',
                                style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 36,
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  fillColor: const Color(0xFFF8FAFC),
                                  filled: true,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: EduTheme.radius12,
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: EduTheme.radius12,
                                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/ ${_selectedTest?.maxMarks.toInt() ?? 20}',
                              style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _marksStatusMap[student.id] = (status == 'present') ? 'absent' : 'present';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'present' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                              borderRadius: EduTheme.radius12,
                            ),
                            child: Text(
                              status == 'present' ? 'Present' : 'Absent',
                              style: EduTheme.typographyMeta.copyWith(
                                color: status == 'present' ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: EduTheme.radius16,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitGrades,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: EduTheme.radius16),
                  ),
                  child: Text(
                    'Save Marks',
                    style: EduTheme.typographyBody.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- ADDITIONAL WORKSPACE TABS BUILDERS ---
  Widget _buildCalendarScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'School Calendar',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: const EduEmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'No Events Scheduled',
        description: 'There are no school holidays or calendar events scheduled for this week.',
      ),
    );
  }

  Widget _buildNotificationsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildNotificationItem(
            'Absence Alert',
            'Aarav Sharma has been reported absent by parent Ramesh Kumar.',
            '10 mins ago',
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
            Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            'New Guidelines',
            'Syllabus progression instructions for Science classes updated.',
            '2 hours ago',
            const Color(0xFFEFF6FF),
            const Color(0xFF3B82F6),
            Icons.info_outline,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            'System Notification',
            'Database successfully seeded and reset with school data.',
            'Yesterday',
            const Color(0xFFECFDF5),
            const Color(0xFF10B981),
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, Color bg, Color iconColor, IconData icon) {
    return EduCard(
      color: Colors.white,
      padding: const EdgeInsets.all(EduTheme.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: EduTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      time,
                      style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            EduCard(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 3),
                    ),
                    child: EduAvatar(
                      name: widget.teacher.name,
                      size: 90,
                    ),
                  ),
                  const SizedBox(height: EduTheme.space16),
                  Text(
                    widget.teacher.name,
                    style: EduTheme.typographyHeading.copyWith(color: EduTheme.colorTextDark, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Science Teacher',
                    style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: EduTheme.space24),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: EduTheme.space16),
                  _buildProfileField(Icons.phone_outlined, 'Phone', widget.teacher.phone),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.school_outlined, 'School ID', widget.teacher.schoolId),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.badge_outlined, 'Role', widget.teacher.role.toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: Text(
                  'Log Out',
                  style: EduTheme.typographyBody.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                  backgroundColor: const Color(0xFFFEF2F2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: EduTheme.radius16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return EduFloatingTabBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          _currentView = 'main_dashboard';
        });
      },
      activeIcons: const [
        Icons.home,
        Icons.school,
        Icons.people,
        Icons.person,
        Icons.more_horiz,
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Classes'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Students'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), label: 'More'),
      ],
    );
  }

  Widget _buildStudentsScreen() {
    final filteredStudents = _classStudents.where((student) {
      return student.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Students List',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: EduTheme.radius16,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [EduTheme.shadowLevel1],
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  hintStyle: EduTheme.typographyCaption.copyWith(color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty
                ? const EduEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No Students Found',
                    description: 'Try checking another class or query.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: EduTheme.radius20,
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [EduTheme.shadowLevel1],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                              ),
                              child: EduAvatar(
                                name: student.name,
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: EduTheme.typographyBody.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Roll No. ${index + 12}  •  ${_selectedClass}',
                                    style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'More Actions',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMoreItem(Icons.calendar_month_outlined, 'Calendar & Events', 'View school holidays & term schedules', () {
            setState(() {
              _selectedIndex = 0;
              _currentView = 'calendar';
            });
          }),
          const SizedBox(height: 12),
          _buildMoreItem(Icons.notifications_outlined, 'Notifications', 'View system notices and admin reports', () {
            setState(() {
              _selectedIndex = 0;
              _currentView = 'notifications';
            });
          }),
          const SizedBox(height: 12),
          _buildMoreItem(Icons.settings_outlined, 'Settings', 'Update account settings and notification triggers', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings feature coming soon!')),
            );
          }),
          const SizedBox(height: 12),
          _buildMoreItem(Icons.help_outline, 'Help & Feedback', 'Reach support or read user guide documentation', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Support documentation coming soon!')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoreItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return EduCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FAF8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: EduTheme.colorPrimaryBrandTeal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
