import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:eduassist_app/screens/mobile_frame.dart';
import 'package:eduassist_app/widgets/edu_design_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;
  final UserModel parent;
  final bool isEmbedded;
  final int? initialTabIndex;
  final VoidCallback? onBack;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.parent,
    this.isEmbedded = false,
    this.initialTabIndex,
    this.onBack,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DbService _dbService = DbService();
  bool _isLoading = true;

  List<FeeRecord> _fees = [];
  List<AttendanceRecord> _attendance = [];
  List<MarkRecord> _marks = [];
  List<ClassroomUpdate> _updates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.initialTabIndex != null) {
      _tabController.index = widget.initialTabIndex!;
    }
    _loadStudentData();
  }

  @override
  void didUpdateWidget(covariant StudentDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null && widget.initialTabIndex != _tabController.index) {
      _tabController.index = widget.initialTabIndex!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    try {
      final fees = await _dbService.getStudentFees(widget.student.id);
      final attendance = await _dbService.getStudentAttendance(widget.student.id);
      final marks = await _dbService.getStudentMarks(widget.student.id);
      final updates = await _dbService.getClassroomUpdates(widget.student.schoolId, widget.student.className);

      if (mounted) {
        setState(() {
          _fees = fees;
          _attendance = attendance;
          _marks = marks;
          _updates = updates;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading student data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayFee(FeeRecord fee) async {
    final receiptNo = "REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _dbService.recordFeePayment(
      fee.id,
      widget.parent.id,
      widget.student.schoolId,
      widget.student.id,
      receiptNo,
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Successful! Receipt: $receiptNo'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStudentData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isEmbedded) {
      // Clean embedded layout without nested top appbars/tabbars
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), // tab index is driven by parent bottom nav bar
          children: [
            _buildReportCardTab(),
            _buildAttendanceTab(),
            _buildUpdatesTab(),
            _buildProfileTab(),
          ],
        ),
      );
    }

    return MobileFrame(
      appBar: AppBar(
        title: Text(widget.student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Fees'),
            Tab(text: 'Attendance'),
            Tab(text: 'Grades'),
            Tab(text: 'Updates'),
          ],
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildFeesTab(),
          _buildAttendanceTab(),
          _buildReportCardTab(),
          _buildUpdatesTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final attendance = _attendance;
    double attendanceRate = 0.0;
    if (attendance.isNotEmpty) {
      final presents = attendance.where((a) => a.status == 'present').length;
      attendanceRate = (presents / attendance.length) * 100;
    } else {
      attendanceRate = 94.0;
    }

    final pendingFees = _fees.where((f) => f.status == 'pending');
    final double pendingSum = pendingFees.fold(0.0, (sum, f) => sum + f.amount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EduTheme.space24, vertical: EduTheme.space12),
        child: Column(
          children: [
            // Custom Header Row with Back Button & Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
                  onPressed: widget.onBack,
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: EduTheme.colorTextDark),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: EduTheme.space8),

            // Profile Avatar with Double Ring and Camera overlay
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFEFF6FF), width: 3),
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.15), width: 2),
                        ),
                      ),
                      EduAvatar(
                        name: widget.student.name,
                        size: 86,
                      ),
                      // Floating Camera Indicator Badge overlay
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, color: EduTheme.colorPrimaryBrandTeal, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EduTheme.space16),
                  Text(
                    widget.student.name,
                    style: EduTheme.typographyDisplayL.copyWith(color: EduTheme.colorTextDark, fontSize: 22),
                  ),
                  const SizedBox(height: EduTheme.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: EduTheme.radius20,
                        ),
                        child: Text(
                          'Class ${widget.student.className}',
                          style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: EduTheme.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: EduTheme.radius20,
                        ),
                        child: Text(
                          'Roll No. 12',
                          style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space16),
            
            Center(
              child: Text(
                'Admission No: 2026-001  •  Academic Year: 2026-2027',
                style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: EduTheme.space24),
            
            // 4-Grid Cards side-by-side using fully Tinted Surfaces & scale animations
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: EduTheme.space12,
              mainAxisSpacing: EduTheme.space12,
              childAspectRatio: 1.5,
              children: [
                _buildGridCard(
                  icon: Icons.person_outline,
                  title: 'Class Teacher',
                  value: 'Mrs. Priya Patel',
                  iconColor: EduTheme.colorPrimaryBrandTeal,
                  bgColor: const Color(0xFFF0FAF8),
                ),
                _buildGridCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Attendance',
                  value: '${attendanceRate.toInt()}%',
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
                _buildGridCard(
                  icon: Icons.wallet_outlined,
                  title: 'Fee Status',
                  value: pendingSum > 0 ? '₹${pendingSum.toInt()} Due' : 'Paid',
                  iconColor: pendingSum > 0 ? const Color(0xFFF97316) : const Color(0xFF10B981),
                  bgColor: pendingSum > 0 ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                ),
                _buildGridCard(
                  icon: Icons.assignment_outlined,
                  title: 'Latest Result',
                  value: _marks.isNotEmpty ? '${_marks.first.marksObtained.toInt()}/${_marks.first.maxMarks.toInt()}' : '18/20',
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                ),
              ],
            ),
            const SizedBox(height: EduTheme.space24),
            
            // About Aarav Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Aarav',
                style: EduTheme.typographyTitle,
              ),
            ),
            const SizedBox(height: EduTheme.space12),
            EduCard(
              child: Column(
                children: [
                  EduInfoTile(icon: Icons.cake_outlined, label: 'Date of Birth', value: '12 May 2015'),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  EduInfoTile(icon: Icons.bloodtype_outlined, label: 'Blood Group', value: 'O+'),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  EduInfoTile(icon: Icons.phone_outlined, label: 'Mobile No.', value: '+91 98765 43210'),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  EduInfoTile(icon: Icons.location_on_outlined, label: 'Address', value: '123 Park Street, Indore,\nMadhya Pradesh - 452001'),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space24),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: EduTheme.radius16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // extra padding for bottom bar clearance
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return EduCard(
      color: bgColor,
      border: Border.all(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(horizontal: EduTheme.space12, vertical: EduTheme.space8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(EduTheme.space8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: EduTheme.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FEES TAB VIEW ---
  Widget _buildFeesTab() {
    if (_fees.isEmpty) {
      return const Center(child: Text("No fee records found."));
    }

    final pendingFees = _fees.where((f) => f.status == 'pending').toList();
    final paidFees = _fees.where((f) => f.status == 'paid').toList();

    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (pendingFees.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                "Pending Dues",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
            ),
            ...pendingFees.map((fee) => _buildFeeCard(fee, isPending: true)),
            const SizedBox(height: 24),
          ],
          if (paidFees.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                "Payment History",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
            ),
            ...paidFees.map((fee) => _buildFeeCard(fee, isPending: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeCard(FeeRecord fee, {required bool isPending}) {
    final formatCurrency = fee.amount.toInt();
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fee.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                  ),
                ),
                Text(
                  '₹$formatCurrency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPending ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPending
                      ? 'Due Date: ${_formatDate(fee.dueDate)}'
                      : 'Paid On: ${fee.paidDate != null ? _formatDate(fee.paidDate!) : "N/A"}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : 'PAID',
                    style: TextStyle(
                      color: isPending ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (!isPending && fee.receiptNo != null) ...[
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt: ${fee.receiptNo}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading Receipt PDF...')),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text(
                          'Download PDF',
                          style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handlePayFee(fee),
                  icon: const Icon(Icons.payment, size: 14, color: Colors.white),
                  label: const Text('Simulate Online Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- ATTENDANCE TAB VIEW ---
  Widget _buildAttendanceTab() {
    if (_attendance.isEmpty) {
      return const Center(child: Text("No attendance records found."));
    }

    final totalDays = _attendance.length;
    final presentDays = _attendance.where((a) => a.status == 'present').length;
    final absentDays = totalDays - presentDays;
    final rate = (presentDays / totalDays) * 100;

    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'Attendance Rate',
                  value: '${rate.toInt()}%',
                  color: rate >= 80 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'Present / Absent',
                  value: '$presentDays / $absentDays',
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: _handleReportAbsence,
              icon: const Icon(Icons.sick, color: Color(0xFFF59E0B)),
              label: const Text('Report Absence Today', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF59E0B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Attendance History",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
          ),
          ..._attendance.map((log) => _buildAttendanceLogTile(log)),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAttendanceLogTile(AttendanceRecord log) {
    final isPresent = log.status == 'present';
    final isReported = log.status == 'reported_absent';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            log.date,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPresent 
                  ? const Color(0xFFECFDF5) 
                  : (isReported ? const Color(0xFFFEF3C7) : const Color(0xFFFEF2F2)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              isPresent ? 'PRESENT' : (isReported ? 'REPORTED' : 'ABSENT'),
              style: TextStyle(
                color: isPresent 
                    ? const Color(0xFF10B981) 
                    : (isReported ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REPORT CARD TAB VIEW ---
  Widget _buildReportCardTab() {
    if (_marks.isEmpty) {
      return const Center(child: Text("No examination records found."));
    }

    final Map<String, List<MarkRecord>> exams = {};
    for (var m in _marks) {
      exams.putIfAbsent(m.examName, () => []).add(m);
    }

    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: exams.entries.map((entry) {
          final examName = entry.key;
          final examMarks = entry.value;

          double totalObtained = 0.0;
          double totalMax = 0.0;
          for (var score in examMarks) {
            totalObtained += score.marksObtained;
            totalMax += score.maxMarks;
          }
          final double averagePercent = (totalObtained / totalMax) * 100;

          String overallGrade = 'D';
          if (averagePercent >= 90) overallGrade = 'A+';
          else if (averagePercent >= 80) overallGrade = 'A';
          else if (averagePercent >= 70) overallGrade = 'B';
          else if (averagePercent >= 60) overallGrade = 'C';

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            examName.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Score: ${totalObtained.toInt()} / ${totalMax.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${averagePercent.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                          ),
                          Text(
                            'Grade: $overallGrade',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 11))),
                            Text('Marks', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 11)),
                            SizedBox(width: 48),
                            Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      const Divider(height: 8),
                      ...examMarks.map((mark) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    mark.subject,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                                  ),
                                ),
                                Text(
                                  '${mark.marksObtained.toInt()} / ${mark.maxMarks.toInt()}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(width: 48),
                                Container(
                                  width: 36,
                                  alignment: Alignment.center,
                                  child: Text(
                                    mark.grade,
                                    style: TextStyle(
                                      color: mark.grade.startsWith('A')
                                          ? const Color(0xFF10B981)
                                          : mark.grade.startsWith('B')
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  // --- CLASSROOM UPDATES TAB VIEW ---
  Widget _buildUpdatesTab() {
    if (_updates.isEmpty) {
      return const Center(child: Text("No classroom updates posted yet."));
    }

    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _updates.length,
        itemBuilder: (context, index) {
          final update = _updates[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          update.subject,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        update.date,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chapter: ${update.chapter}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Topic Covered: ${update.topicCovered}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  ),
                  if (update.homework.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.assignment, size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: 6),
                        Text(
                          'Homework:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      update.homework,
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleReportAbsence() async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Report Absence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notify the school about your child\'s absence today.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (e.g. Sick, Personal Leave)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final todayStr = DateTime.now().toIso8601String().substring(0, 10);
              final docId = "${widget.student.id}_$todayStr";
              
              await FirebaseFirestore.instance.collection('attendance').doc(docId).set({
                'studentId': widget.student.id,
                'schoolId': widget.student.schoolId,
                'date': todayStr,
                'status': 'reported_absent',
                'reason': reasonController.text.trim(),
                'markedBy': widget.parent.id,
                'markedAt': Timestamp.now(),
              });
              
              _loadStudentData();
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
