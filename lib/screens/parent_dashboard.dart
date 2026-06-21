import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:eduassist_app/screens/student_details_screen.dart';
import 'package:eduassist_app/screens/mobile_frame.dart';
import 'package:eduassist_app/widgets/edu_design_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentDashboard extends StatefulWidget {
  final UserModel parent;

  const ParentDashboard({super.key, required this.parent});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final DbService _dbService = DbService();
  List<Student> _students = [];
  bool _isLoading = true;
  String _schoolName = 'Green Valley School';
  Student? _selectedStudent;
  int _currentTab = 0;
  String _selectedFilter = 'All'; // Filter chip selection for Class Updates

  Map<String, List<FeeRecord>> _studentFees = {};
  Map<String, List<AttendanceRecord>> _studentAttendance = {};
  Map<String, List<ClassroomUpdate>> _studentUpdates = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _dbService.getStudentsForParent(widget.parent.id);
      
      final schoolDoc = await FirebaseFirestore.instance
          .collection('schools')
          .doc(widget.parent.schoolId)
          .get();
      final sName = schoolDoc.data()?['name'] ?? 'Green Valley School';

      final feesMap = <String, List<FeeRecord>>{};
      final attendanceMap = <String, List<AttendanceRecord>>{};
      final updatesMap = <String, List<ClassroomUpdate>>{};

      for (var child in children) {
        final fees = await _dbService.getStudentFees(child.id);
        final attendance = await _dbService.getStudentAttendance(child.id);
        final updates = await _dbService.getClassroomUpdates(widget.parent.schoolId, child.className);
        
        feesMap[child.id] = fees;
        attendanceMap[child.id] = attendance;
        updatesMap[child.id] = updates;
      }

      if (mounted) {
        setState(() {
          _students = children;
          _schoolName = sName;
          _studentFees = feesMap;
          _studentAttendance = attendanceMap;
          _studentUpdates = updatesMap;
          
          if (children.isNotEmpty && _selectedStudent == null) {
            _selectedStudent = children.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading parent dashboard data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MobileFrame(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_students.isEmpty) {
      return MobileFrame(
        appBar: AppBar(
          title: const Text('No Linked Students'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: const Center(
          child: Text('No children linked to this parent phone number.'),
        ),
      );
    }

    // Screen 3 Child Selection
    if (_selectedStudent == null) {
      return _buildChildSelectionView();
    }

    return MobileFrame(
      bottomNavigationBar: EduFloatingTabBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Academics'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_outlined), label: 'Timeline'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _buildCurrentTabContent(),
      ),
    );
  }

  // --- SCREEN 3: CHILD SELECTION ---
  Widget _buildChildSelectionView() {
    return MobileFrame(
      appBar: AppBar(
        title: const Text(
          'Select Child',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(EduTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Choose a child to continue',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: EduTheme.space24),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _students.length,
                separatorBuilder: (c, i) => const SizedBox(height: EduTheme.space16),
                itemBuilder: (context, index) {
                  final child = _students[index];
                  final attendance = _studentAttendance[child.id] ?? [];
                  double attendanceRate = 0.0;
                  if (attendance.isNotEmpty) {
                    final presents = attendance.where((a) => a.status == 'present').length;
                    attendanceRate = (presents / attendance.length) * 100;
                  } else {
                    attendanceRate = 94.0;
                  }

                  final isSel = _selectedStudent == child;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStudent = child;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(EduTheme.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: EduTheme.radius24,
                        border: Border.all(
                          color: isSel ? EduTheme.colorPrimaryBrandTeal : const Color(0xFFE2E8F0),
                          width: isSel ? 2 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: EduTheme.colorPrimaryBrandTeal.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                )
                              ]
                            : [EduTheme.shadowLevel1],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://api.dicebear.com/7.x/adventurer/png?seed=${child.name}',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.person, color: EduTheme.colorPrimaryBrandTeal),
                              ),
                            ),
                          ),
                          const SizedBox(width: EduTheme.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.name,
                                  style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Class ${child.className}  •  Roll No. ${index + 12}',
                                  style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'attendance',
                                style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${attendanceRate.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: EduTheme.space12),
                          // Custom check pill matching mockup
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSel ? EduTheme.colorPrimaryBrandTeal : Colors.transparent,
                              border: Border.all(
                                color: isSel ? EduTheme.colorPrimaryBrandTeal : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                            child: isSel
                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: EduTheme.space16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Color(0xFF4F46E5), size: 18),
              label: const Text(
                'Add Another Child',
                style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E7FF), width: 1.5),
                backgroundColor: const Color(0xFFEEF2F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: EduTheme.radius16,
                ),
              ),
            ),
            const SizedBox(height: EduTheme.space16),
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [EduTheme.colorPrimaryBrandTeal, EduTheme.colorPrimaryBrandCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: EduTheme.radius16,
                boxShadow: [
                  BoxShadow(
                    color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedStudent == null && _students.isNotEmpty) {
                    _selectedStudent = _students.first;
                  }
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: EduTheme.radius16,
                  ),
                ),
                child: Text(
                  'Continue',
                  style: EduTheme.typographyBody.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: EduTheme.space12),
          ],
        ),
      ),
    );
  }

  // --- TAB ROUTER ---
  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildAcademicsTab();
      default:
        // Render timeline, notification and profiles cleanly in-page, disabling embedded tabs to align with mockup styles
        return StudentDetailsScreen(
          student: _selectedStudent!,
          parent: widget.parent,
          isEmbedded: true,
          initialTabIndex: _currentTab - 1, // Timeline (1), Notifications (2), Profile (3)
          onBack: () {
            setState(() {
              _currentTab = 0;
            });
          },
        );
    }
  }

  // --- SCREEN 1: PARENT DASHBOARD HOME ---
  Widget _buildHomeTab() {
    final child = _selectedStudent!;
    final attendance = _studentAttendance[child.id] ?? [];
    double attendanceRate = 0.0;
    if (attendance.isNotEmpty) {
      final presents = attendance.where((a) => a.status == 'present').length;
      attendanceRate = (presents / attendance.length) * 100;
    } else {
      attendanceRate = 94.0;
    }

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final todayLog = attendance.firstWhere(
      (a) => a.date == todayStr,
      orElse: () => AttendanceRecord(
        id: '',
        studentId: child.id,
        schoolId: child.schoolId,
        date: todayStr,
        status: 'present',
        markedBy: '',
        markedAt: DateTime.now(),
      ),
    );

    final fees = _studentFees[child.id] ?? [];
    final pendingFees = fees.where((f) => f.status == 'pending');
    final double pendingSum = pendingFees.fold(0.0, (sum, f) => sum + f.amount);

    final updates = _studentUpdates[child.id] ?? [];
    final latestUpdate = updates.isNotEmpty ? updates.first : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0F9F90).withValues(alpha: 0.15), width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://api.dicebear.com/7.x/adventurer/png?seed=${widget.parent.name}',
                              fit: BoxFit.cover,
                            ),
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
                              widget.parent.name,
                              style: EduTheme.typographyHeading.copyWith(
                                color: EduTheme.colorTextDark,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF475569), size: 26),
                          onPressed: () {
                            setState(() {
                              _currentTab = 3;
                            });
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
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
                              '2',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: EduTheme.space24),
                // Reusable Student Hero Card
                EduStudentHeroCard(
                  studentName: child.name,
                  className: child.className,
                  rollNo: '12',
                  schoolName: _schoolName,
                  attendanceRate: attendanceRate,
                  onTap: () {
                    setState(() {
                      _selectedStudent = null;
                    });
                  },
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today status pill
                EduStatusPill(
                  dateText: 'Today • 15 July, 2026',
                  status: todayLog.status,
                ),
                const SizedBox(height: EduTheme.space24),
                
                // Today's Update
                _buildSectionHeader("Today's Update", tabIndex: 3),
                const SizedBox(height: EduTheme.space12),
                EduTimelineCard(
                  title: latestUpdate?.subject ?? 'Mathematics',
                  category: 'lesson',
                  time: '10:30 AM',
                  detailLine1: 'Chapter: ${latestUpdate?.chapter ?? "Fractions"}',
                  detailLine2: 'Topic: ${latestUpdate?.topicCovered ?? "Equivalent Fractions"}',
                ),
                const SizedBox(height: EduTheme.space24),
                
                // Homework
                _buildSectionHeader("Homework", tabIndex: 3),
                const SizedBox(height: EduTheme.space12),
                EduTimelineCard(
                  title: '2 Assignments',
                  category: 'homework',
                  time: 'Yesterday',
                  detailLine1: 'Science, Mathematics',
                  detailLine2: latestUpdate?.homework ?? 'Complete questions 1 to 5 from chapter 4 exercises.',
                  onTap: () {
                    setState(() {
                      _currentTab = 1; // switch to updates tab
                    });
                  },
                ),
                const SizedBox(height: EduTheme.space24),

                // Upcoming test (Screen 1 details)
                _buildSectionHeader("Upcoming Test", tabIndex: 1, showViewAll: false),
                const SizedBox(height: EduTheme.space12),
                EduTimelineCard(
                  title: 'Fractions Assessment',
                  category: 'test',
                  time: '3 Days Left',
                  detailLine1: 'Mathematics',
                  detailLine2: 'Date: 18 July 2026',
                ),
                const SizedBox(height: EduTheme.space24),
                
                // Fees Reminder
                _buildSectionHeader("Fees Reminder", tabIndex: 1, showViewAll: false),
                const SizedBox(height: EduTheme.space12),
                EduTimelineCard(
                  title: pendingSum > 0 ? '₹${pendingSum.toInt()} Due' : 'Fees Cleared',
                  category: 'fee',
                  time: pendingSum > 0 ? 'Pay Now' : 'Paid',
                  detailLine1: pendingSum > 0 ? 'Due Date: 20 July 2026' : 'No outstanding dues',
                  detailLine2: pendingSum > 0 ? 'Standard Term 2 Tuition Fee Invoice' : 'Thank you for your timely payment.',
                  onTap: pendingSum > 0 
                      ? () {
                          setState(() {
                            _currentTab = 1; // Directs to Academics -> Fees subview
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required int tabIndex, bool showViewAll = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark),
        ),
        if (showViewAll)
          TextButton(
            onPressed: () {
              setState(() {
                _currentTab = tabIndex;
              });
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
            child: const Text(
              'View All',
              style: TextStyle(color: EduTheme.colorPrimaryBrandTeal, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
      ],
    );
  }

  // --- SCREEN 2: CLASS UPDATES (ACADEMICS TAB) ---
  Widget _buildAcademicsTab() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final child = _selectedStudent!;
    final updates = _studentUpdates[child.id] ?? [];

    final List<Widget> updateCards = [];

    // Filter and build card list
    for (var update in updates) {
      final isToday = update.date == todayStr;
      final displayTime = isToday ? '10:30 AM' : 'Yesterday';

      if (_selectedFilter == 'All' || _selectedFilter == 'Lessons') {
        if (updateCards.isNotEmpty) {
          updateCards.add(const SizedBox(height: 16));
        }
        updateCards.add(
          EduTimelineCard(
            title: update.subject,
            category: 'lesson',
            time: displayTime,
            detailLine1: 'Chapter: ${update.chapter}',
            detailLine2: 'Topic: ${update.topicCovered}',
            footerLeft: 'Mrs. Priya Patel',
            footerRight: update.date,
          ),
        );
      }

      if (update.homework.isNotEmpty) {
        if (_selectedFilter == 'All' || _selectedFilter == 'Homework') {
          if (updateCards.isNotEmpty) {
            updateCards.add(const SizedBox(height: 16));
          }
          updateCards.add(
            EduTimelineCard(
              title: 'Homework Assigned',
              category: 'homework',
              time: displayTime,
              detailLine1: 'Subject: ${update.subject}',
              detailLine2: update.homework,
              footerLeft: 'Mrs. Priya Patel',
              footerRight: update.date,
            ),
          );
        }
      }
    }

    // Add mockup class notice card for Notices or All filter to match mockup
    if (_selectedFilter == 'All' || _selectedFilter == 'Notices') {
      if (updateCards.isNotEmpty) {
        updateCards.add(const SizedBox(height: 16));
      }
      updateCards.add(
        const EduTimelineCard(
          title: 'Class Notice',
          category: 'notice',
          time: '12 Jul',
          detailLine1: 'PTM will be held on',
          detailLine2: '20 July 2026 (Saturday)',
          footerLeft: 'Mrs. Priya Patel',
          footerRight: '12 July, 2026',
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Class Updates',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: EduTheme.colorTextDark),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
          onPressed: () {
            setState(() {
              _currentTab = 0;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: EduTheme.colorTextDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chip strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: EduTheme.space12, horizontal: 16),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                EduActionChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                const SizedBox(width: 8),
                EduActionChip(
                  label: 'Lessons',
                  isSelected: _selectedFilter == 'Lessons',
                  onTap: () => setState(() => _selectedFilter = 'Lessons'),
                ),
                const SizedBox(width: 8),
                EduActionChip(
                  label: 'Homework',
                  isSelected: _selectedFilter == 'Homework',
                  onTap: () => setState(() => _selectedFilter = 'Homework'),
                ),
                const SizedBox(width: 8),
                EduActionChip(
                  label: 'Notices',
                  isSelected: _selectedFilter == 'Notices',
                  onTap: () => setState(() => _selectedFilter = 'Notices'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: updateCards.isEmpty
                ? const EduEmptyState(
                    icon: Icons.menu_book,
                    title: 'No Updates Found',
                    description: 'There are no updates matching your selection for today.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    children: updateCards,
                  ),
          ),
        ],
      ),
    );
  }
}
