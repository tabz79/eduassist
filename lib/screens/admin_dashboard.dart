import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduassist_app/widgets/edu_design_system.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DbService _dbService = DbService();
  String _currentRoute = 'dashboard';
  bool _isLoading = false;

  // Configuration Lists loaded from database
  List<UserModel> _schoolTeachers = [];
  List<Student> _schoolStudents = [];
  List<AcademicYear> _academicYearsList = [];
  List<ClassModel> _classesList = [];
  List<SectionModel> _sectionsList = [];
  List<SubjectModel> _subjectsList = [];
  List<ExamModel> _examsList = [];
  List<FeeAssignment> _feeAssignmentsList = [];
  List<FeeStructure> _feeStructuresList = [];
  List<AuditLog> _auditLogsList = [];
  List<Announcement> _announcementsList = [];
  List<TeacherAssignment> _teacherAssignmentsList = [];
  List<Timetable> _timetablesList = [];
  List<ClassroomUpdateModel> _classroomUpdatesList = [];
  List<Enrollment> _enrollmentsList = [];
  List<ParentStudentLink> _parentStudentLinksList = [];
  List<UserModel> _schoolParents = [];

  // Local state options lists
  final List<String> _activeClasses = [];

  // Controllers for general inputs
  final _searchController = TextEditingController();

  // Academic Configuration Controllers
  final _academicYearController = TextEditingController(text: '2026-2027');
  final _yearStartDateController = TextEditingController(text: '2026-06-01');
  final _yearEndDateController = TextEditingController(text: '2027-04-30');

  // Class & Section Controllers
  final _classNameController = TextEditingController();
  final _sectionNameController = TextEditingController();
  final _sectionCapacityController = TextEditingController(text: '30');

  // Subject Controllers
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();

  // Timetable Controllers
  String _selectedTimetableDay = 'monday';
  int _timetablePeriodNumber = 1;
  String? _timetableSelectedClassId;
  String? _timetableSelectedSectionId;
  String? _timetableSelectedSubjectId;
  String? _timetableSelectedTeacherId;
  final _timetableStartTimeController = TextEditingController(text: '08:00');
  final _timetableEndTimeController = TextEditingController(text: '08:45');

  // Exam Controllers
  final _examNameController = TextEditingController();
  final _examTermController = TextEditingController(text: 'Term 1');
  final _examWeightageController = TextEditingController(text: '10');

  // Admission Controllers
  final _studentNameController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _studentDobController = TextEditingController(text: '2015-05-12');
  final _studentGenderController = TextEditingController(text: 'male');
  final _studentBloodController = TextEditingController(text: 'O+');
  final _studentAddressController = TextEditingController(text: '123 Park Street, Indore, MP');
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String? _admissionsSelectedClassId;
  String? _admissionsSelectedSectionId;

  // Promotion Controllers
  String? _promoFromClassId;
  String? _promoFromSectionId;
  String? _promoToClassId;
  String? _promoToSectionId;
  String? _promoToAcademicYearId;
  final List<String> _promoSelectedStudentIds = [];

  // Transfer Controllers
  String? _transferSelectedStudentId;
  String _transferSelectedStatus = 'transferred';

  // Class Workspace Navigation state variables (Milestone 4)
  String? _workspaceClassId;
  String? _workspaceSectionId;
  int _workspaceActiveTab = 0; // 0: Overview, 1: Students, 2: Teachers, 3: Subjects, 4: Timetable, 5: Exams & Marks, 6: Fees & Collection

  // Teacher Controllers
  final _teacherNameController = TextEditingController();
  final _teacherPhoneController = TextEditingController();
  final _teacherEmailController = TextEditingController();
  final _teacherSpecController = TextEditingController();

  // Teacher Assignment Controllers
  String? _assignTeacherId;
  String? _assignClassId;
  String? _assignSectionId;
  String? _assignSubjectId;
  String _assignType = 'subject_teacher';

  // Fee Structure Controllers
  final _feeTitleController = TextEditingController();
  final _feeAmountController = TextEditingController();
  final _feeDueDateController = TextEditingController(text: '2026-07-20');

  // Fee Assignment Controllers
  String? _feeAllocStructureId;
  String? _feeAllocClassId;
  String? _feeAllocSectionId;

  // Announcement Controllers
  final _announcementTitleController = TextEditingController();
  final _announcementBodyController = TextEditingController();
  String _announcementScope = 'school';
  String? _announcementClassId;
  String? _announcementSectionId;

  // School Profile Controllers
  final _schoolNameController = TextEditingController();
  final _schoolBoardController = TextEditingController();
  final _schoolAddressController = TextEditingController();

  // Wizard state variables for Milestone 2
  int _admissionWizardStep = 0;
  bool _admissionParentSearched = false;
  UserModel? _admissionFoundParent;
  final _admissionParentPhoneController = TextEditingController();
  final _admissionParentNameController = TextEditingController();

  int _parentLinkWizardStep = 0;
  String? _parentLinkSelectedStudentId;
  bool _parentLinkParentSearched = false;
  UserModel? _parentLinkFoundParent;
  final _parentLinkParentPhoneController = TextEditingController();
  final _parentLinkParentNameController = TextEditingController();
  String _parentLinkRelationship = 'father';

  int _teacherAssignWizardStep = 0;
  String? _tWizardTeacherId;
  String? _tWizardClassId;
  String? _tWizardSectionId;
  String? _tWizardSubjectId;
  String _tWizardType = 'subject_teacher';

  // School operational settings controllers (Milestone 3)
  final _settingsStartTimeController = TextEditingController(text: '08:00');
  final _settingsEndTimeController = TextEditingController(text: '14:30');
  final _settingsPeriodDurationController = TextEditingController(text: '45');
  final _settingsLunchStartController = TextEditingController(text: '11:00');
  final _settingsLunchDurationController = TextEditingController(text: '30');
  List<String> _settingsWorkingDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

  final List<Map<String, dynamic>> _sidebarStructure = [
    {
      'title': 'General',
      'items': [
        {'route': 'dashboard', 'label': 'Dashboard', 'icon': Icons.dashboard},
      ]
    },
    {
      'title': 'Academic',
      'items': [
        {'route': 'academic_years', 'label': 'Academic Years', 'icon': Icons.date_range},
        {'route': 'classes_sections', 'label': 'Classes & Sections', 'icon': Icons.business},
        {'route': 'subjects', 'label': 'Subjects', 'icon': Icons.book},
        {'route': 'timetables', 'label': 'Timetables', 'icon': Icons.schedule},
        {'route': 'exams', 'label': 'Exams', 'icon': Icons.assessment},
      ]
    },
    {
      'title': 'Students',
      'items': [
        {'route': 'students', 'label': 'Students Roster', 'icon': Icons.people},
        {'route': 'admissions', 'label': 'Admissions Wizard', 'icon': Icons.person_add},
        {'route': 'parent_linker', 'label': 'Link Parents', 'icon': Icons.link},
        {'route': 'promotions', 'label': 'Promotions Console', 'icon': Icons.trending_up},
        {'route': 'transfers', 'label': 'Transfers Registry', 'icon': Icons.swap_horiz},
      ]
    },
    {
      'title': 'Teachers',
      'items': [
        {'route': 'teachers', 'label': 'Teachers Directory', 'icon': Icons.supervisor_account},
        {'route': 'assignments', 'label': 'Assignments Mapper', 'icon': Icons.assignment_ind},
      ]
    },
    {
      'title': 'Finance',
      'items': [
        {'route': 'fee_structures', 'label': 'Fee Structures', 'icon': Icons.payments},
        {'route': 'fee_assignments', 'label': 'Fee Assignments', 'icon': Icons.assignment},
        {'route': 'payments', 'label': 'Payments Log', 'icon': Icons.receipt_long},
      ]
    },
    {
      'title': 'Communication',
      'items': [
        {'route': 'announcements', 'label': 'Announcements', 'icon': Icons.campaign},
        {'route': 'classroom_updates', 'label': 'Classroom Updates', 'icon': Icons.rate_review},
      ]
    },
    {
      'title': 'Reports',
      'items': [
        {'route': 'attendance_reports', 'label': 'Attendance Reports', 'icon': Icons.fact_check},
        {'route': 'fee_reports', 'label': 'Fee Reports', 'icon': Icons.account_balance_wallet},
      ]
    },
    {
      'title': 'Settings',
      'items': [
        {'route': 'school_profile', 'label': 'School Profile', 'icon': Icons.school},
        {'route': 'academic_config', 'label': 'Academic Config', 'icon': Icons.settings},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadSchoolProfile();
  }

  Future<void> _loadSchoolProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('schools').doc(widget.admin.schoolId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _schoolNameController.text = data['name'] ?? '';
        _schoolBoardController.text = data['board'] ?? '';
        _schoolAddressController.text = data['address'] ?? '';
        
        if (data['startTime'] != null) _settingsStartTimeController.text = data['startTime'];
        if (data['endTime'] != null) _settingsEndTimeController.text = data['endTime'];
        if (data['periodDuration'] != null) _settingsPeriodDurationController.text = data['periodDuration'].toString();
        if (data['lunchBreakStart'] != null) _settingsLunchStartController.text = data['lunchBreakStart'];
        if (data['lunchBreakDuration'] != null) _settingsLunchDurationController.text = data['lunchBreakDuration'].toString();
        if (data['workingDays'] != null) {
          _settingsWorkingDays = List<String>.from(data['workingDays']);
        }
      }
    } catch (e) {
      print("Error loading school profile: $e");
    }
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final schoolId = widget.admin.schoolId;

    // Load Teachers
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolId', isEqualTo: schoolId)
          .where('role', isEqualTo: 'teacher')
          .get();
      _schoolTeachers = query.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading teachers: $e");
    }

    // Load Students
    try {
      final query = await FirebaseFirestore.instance
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _schoolStudents = query.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading students: $e");
    }

    // Load Academic Years
    try {
      final query = await FirebaseFirestore.instance
          .collection('academic_years')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _academicYearsList = query.docs.map((doc) => AcademicYear.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading academic years: $e");
    }

    // Load Classes
    try {
      final query = await FirebaseFirestore.instance
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _classesList = query.docs.map((doc) => ClassModel.fromMap(doc.data(), doc.id)).toList();
      _activeClasses.clear();
      _activeClasses.addAll(_classesList.map((c) => c.name));
    } catch (e) {
      print("Error loading classes: $e");
    }

    // Load Sections
    try {
      final query = await FirebaseFirestore.instance
          .collection('sections')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _sectionsList = query.docs.map((doc) => SectionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading sections: $e");
    }

    // Load Subjects
    try {
      final query = await FirebaseFirestore.instance
          .collection('subjects')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _subjectsList = query.docs.map((doc) => SubjectModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading subjects: $e");
    }

    // Load Exams
    try {
      final query = await FirebaseFirestore.instance
          .collection('exams')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _examsList = query.docs.map((doc) => ExamModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading exams: $e");
    }

    // Load Fee Assignments
    try {
      final query = await FirebaseFirestore.instance
          .collection('fee_assignments')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _feeAssignmentsList = query.docs.map((doc) => FeeAssignment.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading fee assignments: $e");
    }

    // Load Fee Structures
    try {
      final query = await FirebaseFirestore.instance
          .collection('fee_structures')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _feeStructuresList = query.docs.map((doc) => FeeStructure.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading fee structures: $e");
    }

    // Load Audit Logs
    try {
      final query = await FirebaseFirestore.instance
          .collection('audit_logs')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _auditLogsList = query.docs.map((doc) => AuditLog.fromMap(doc.data(), doc.id)).toList();
      _auditLogsList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print("Error loading audit logs: $e");
    }

    // Load Announcements
    try {
      final query = await FirebaseFirestore.instance
          .collection('announcements')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _announcementsList = query.docs.map((doc) => Announcement.fromMap(doc.data(), doc.id)).toList();
      _announcementsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Error loading announcements: $e");
    }

    // Load Teacher Assignments
    try {
      final query = await FirebaseFirestore.instance
          .collection('teacher_assignments')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _teacherAssignmentsList = query.docs.map((doc) => TeacherAssignment.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading assignments: $e");
    }

    // Load Timetables
    try {
      final query = await FirebaseFirestore.instance
          .collection('timetables')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _timetablesList = query.docs.map((doc) => Timetable.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading timetables: $e");
    }

    // Load Classroom Updates
    try {
      final query = await FirebaseFirestore.instance
          .collection('classroom_updates')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _classroomUpdatesList = query.docs.map((doc) => ClassroomUpdateModel.fromMap(doc.data(), doc.id)).toList();
      _classroomUpdatesList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print("Error loading classroom updates: $e");
    }

    // Load Enrollments
    try {
      final query = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _enrollmentsList = query.docs.map((doc) => Enrollment.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading enrollments: $e");
    }

    // Load Parent-Student Links
    try {
      final query = await FirebaseFirestore.instance
          .collection('parent_student_links')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      _parentStudentLinksList = query.docs.map((doc) => ParentStudentLink.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading parent-student links: $e");
    }

    // Load Parents
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolId', isEqualTo: schoolId)
          .where('role', isEqualTo: 'parent')
          .get();
      _schoolParents = query.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading parents: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF10B981)),
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFF59E0B)),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  String _getReadableAction(String action) {
    switch (action) {
      case 'SYSTEM_INIT_SEED':
        return 'System Initialized';
      case 'PAY_FEE':
        return 'Fee Payment Recorded';
      case 'UPDATE_MARKS':
        return 'Student Marks Updated';
      case 'PROMOTE_STUDENT':
        return 'Student Promoted';
      case 'CHANGE_FEES':
        return 'Fee Structure Modified';
      case 'PUBLISH_REPORT_CARD':
        return 'Report Card Published';
      default:
        return action.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
    }
  }

  String _getReadableDetails(String entityType, String entityId) {
    final cleanEntity = entityType.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
    return '$cleanEntity Record ($entityId)';
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFECFDF5);
    Color border = const Color(0xFFA7F3D0);
    Color text = const Color(0xFF047857);
    String statusStr = status.toUpperCase();

    if (status == 'reported_absent' || status == 'pending' || status == 'inactive' || status == 'class' || status == 'transferred') {
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
    } else if (status == 'absent' || status == 'dropped') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFCA5A5);
      text = const Color(0xFFB91C1C);
    } else if (status == 'section' || status == 'partially_paid') {
      bg = const Color(0xFFFAF5FF);
      border = const Color(0xFFE9D5FF);
      text = const Color(0xFF7C3AED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: border),
      ),
      child: Text(
        statusStr,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  // --- CRUD BASE METHODS FOR STUDENTS, TEACHERS, SUBJECTS & ASSIGNMENTS ---

  Future<void> _deleteStudentDoc(String studentId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).delete();
      final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
      await FirebaseFirestore.instance.collection('enrollments').doc('ENR_${studentId}_$activeYear').delete();
      final links = await FirebaseFirestore.instance.collection('parent_student_links').where('studentId', isEqualTo: studentId).get();
      for (var doc in links.docs) {
        await doc.reference.delete();
      }
      _showSuccess('Student registry withdrawn successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error deleting student: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStudentDoc(String studentId, String name, String address, String dob, String gender, String bloodGroup, String classId, String sectionId, int rollNo) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
        'name': name,
        'address': address,
        'dob': dob,
        'gender': gender,
        'bloodGroup': bloodGroup,
      });
      final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
      final enrollmentId = 'ENR_${studentId}_$activeYear';
      await FirebaseFirestore.instance.collection('enrollments').doc(enrollmentId).update({
        'classId': classId,
        'sectionId': sectionId,
        'rollNumber': rollNo,
      });
      _showSuccess('Student profile updated successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error updating student: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTeacherDoc(String teacherId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(teacherId).delete();
      final assignments = await FirebaseFirestore.instance.collection('teacher_assignments').where('teacherId', isEqualTo: teacherId).get();
      for (var doc in assignments.docs) {
        await doc.reference.delete();
      }
      _showSuccess('Teacher account deleted successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error deleting teacher: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTeacherDoc(String teacherId, String name, String phone, String email, String spec) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(teacherId).update({
        'name': name,
        'phone': phone,
        'email': email,
        'specialization': spec,
      });
      _showSuccess('Teacher profile updated successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error updating teacher: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSubjectDoc(String subjectId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('subjects').doc(subjectId).delete();
      final assignments = await FirebaseFirestore.instance.collection('teacher_assignments').where('subjectId', isEqualTo: subjectId).get();
      for (var doc in assignments.docs) {
        await doc.reference.delete();
      }
      _showSuccess('Subject deleted successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error deleting subject: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSubjectDoc(String subjectId, String name, String code, String classId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('subjects').doc(subjectId).update({
        'name': name,
        'code': code,
        'classId': classId,
      });
      _showSuccess('Subject details updated successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error updating subject: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAssignmentDoc(String assignmentId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('teacher_assignments').doc(assignmentId).delete();
      _showSuccess('Teacher assignment removed successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error deleting assignment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAssignmentDoc(String assignmentId, String teacherId, String assignmentType, String classId, String sectionId, String subjectId) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('teacher_assignments').doc(assignmentId).update({
        'teacherId': teacherId,
        'assignmentType': assignmentType,
        'classId': classId,
        'sectionId': sectionId,
        'subjectId': subjectId,
      });
      _showSuccess('Teacher assignment updated successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error updating assignment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- CRUD / OPERATIONS METHODS ---

  Future<void> _createAcademicYear() async {
    final yr = _academicYearController.text.trim();
    if (yr.isEmpty) return;
    setState(() => _isLoading = true);
    final customId = _dbService.generateCustomId('AY');
    try {
      await FirebaseFirestore.instance.collection('academic_years').doc(customId).set({
        'academicYearId': customId,
        'schoolId': widget.admin.schoolId,
        'year': yr,
        'startDate': _yearStartDateController.text.trim(),
        'endDate': _yearEndDateController.text.trim(),
        'status': 'active',
      });
      _showSuccess('Academic Year created!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createClassDoc() async {
    final name = _classNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final classId = 'CLS_${name.replaceAll(' ', '_').toUpperCase()}';
    try {
      await FirebaseFirestore.instance.collection('classes').doc(classId).set({
        'classId': classId,
        'schoolId': widget.admin.schoolId,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _classNameController.clear();
      _showSuccess('Class created successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createSectionDoc() async {
    final name = _sectionNameController.text.trim();
    final cap = int.tryParse(_sectionCapacityController.text) ?? 30;
    if (name.isEmpty || _classesList.isEmpty) return;
    setState(() => _isLoading = true);
    final secId = _dbService.generateCustomId('SEC');
    final classId = _classesList.first.classId; // Default to first class for mapping
    try {
      await FirebaseFirestore.instance.collection('sections').doc(secId).set({
        'sectionId': secId,
        'schoolId': widget.admin.schoolId,
        'classId': classId,
        'name': name,
        'capacity': cap,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _sectionNameController.clear();
      _showSuccess('Section $name created with capacity $cap!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createSubjectDocWithClass(String classId) async {
    final name = _subjectNameController.text.trim();
    final code = _subjectCodeController.text.trim();
    if (name.isEmpty || code.isEmpty) {
      _showWarning('Please fill subject name and code.');
      return;
    }
    setState(() => _isLoading = true);
    final subId = _dbService.generateCustomId('SUB');
    final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
    try {
      await FirebaseFirestore.instance.collection('subjects').doc(subId).set({
        'subjectId': subId,
        'schoolId': widget.admin.schoolId,
        'academicYearId': activeYear,
        'classId': classId,
        'name': name,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _subjectNameController.clear();
      _subjectCodeController.clear();
      _showSuccess('Subject $name mapped!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createTimetableSlot() async {
    if (_timetableSelectedClassId == null ||
        _timetableSelectedSectionId == null ||
        _timetableSelectedSubjectId == null ||
        _timetableSelectedTeacherId == null) {
      _showWarning('Please fill all slot fields.');
      return;
    }
    setState(() => _isLoading = true);
    final ttId = _dbService.generateCustomId('TT');
    final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
    try {
      await FirebaseFirestore.instance.collection('timetables').doc(ttId).set({
        'timetableId': ttId,
        'schoolId': widget.admin.schoolId,
        'academicYearId': activeYear,
        'classId': _timetableSelectedClassId,
        'sectionId': _timetableSelectedSectionId,
        'dayOfWeek': _selectedTimetableDay,
        'periodNumber': _timetablePeriodNumber,
        'subjectId': _timetableSelectedSubjectId,
        'teacherId': _timetableSelectedTeacherId,
        'startTime': _timetableStartTimeController.text,
        'endTime': _timetableEndTimeController.text,
      });
      _showSuccess('Timetable slot added successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createExam() async {
    final name = _examNameController.text.trim();
    final weight = double.tryParse(_examWeightageController.text) ?? 10.0;
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final examId = _dbService.generateCustomId('EXM');
    final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
    try {
      await FirebaseFirestore.instance.collection('exams').doc(examId).set({
        'examId': examId,
        'schoolId': widget.admin.schoolId,
        'academicYearId': activeYear,
        'name': name,
        'term': _examTermController.text.trim(),
        'weightage': weight,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _examNameController.clear();
      _showSuccess('Exam structure saved!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _onboardTeacherDoc() async {
    final name = _teacherNameController.text.trim();
    final phone = _teacherPhoneController.text.trim();
    final email = _teacherEmailController.text.trim();
    final spec = _teacherSpecController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showWarning('Teacher Name and Phone are required.');
      return;
    }
    setState(() => _isLoading = true);
    final tId = _dbService.generateCustomId('TCH');
    try {
      await FirebaseFirestore.instance.collection('users').doc(tId).set({
        'userId': tId,
        'schoolId': widget.admin.schoolId,
        'phone': phone,
        'email': email,
        'name': name,
        'role': 'teacher',
        'status': 'active',
        'specialization': spec,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _teacherNameController.clear();
      _teacherPhoneController.clear();
      _teacherEmailController.clear();
      _teacherSpecController.clear();
      _showSuccess('Teacher account onboarded!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createTeacherAssignment() async {
    if (_assignTeacherId == null || _assignClassId == null || _assignSectionId == null) {
      _showWarning('Please select Teacher, Class and Section.');
      return;
    }
    setState(() => _isLoading = true);
    final assignId = _dbService.generateCustomId('ASN');
    final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
    try {
      await FirebaseFirestore.instance.collection('teacher_assignments').doc(assignId).set({
        'assignmentId': assignId,
        'schoolId': widget.admin.schoolId,
        'teacherId': _assignTeacherId,
        'academicYearId': activeYear,
        'classId': _assignClassId,
        'sectionId': _assignSectionId,
        'subjectId': _assignSubjectId ?? '',
        'assignmentType': _assignType,
      });
      _showSuccess('Teacher assignment configured!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _admitStudentDoc() async {
    final sName = _studentNameController.text.trim();
    final pName = _parentNameController.text.trim();
    final pPhone = _parentPhoneController.text.trim();
    final roll = int.tryParse(_studentRollController.text) ?? 1;

    if (sName.isEmpty || pName.isEmpty || pPhone.isEmpty || _admissionsSelectedClassId == null || _admissionsSelectedSectionId == null) {
      _showWarning('Fill in Student details, Parent details, Class and Section.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Create or Find Parent User
      String pId = _dbService.generateCustomId('PAR');
      final queryParent = await _dbService.getUserByPhone(pPhone);
      if (queryParent != null) {
        pId = queryParent.id;
      } else {
        await FirebaseFirestore.instance.collection('users').doc(pId).set({
          'userId': pId,
          'schoolId': widget.admin.schoolId,
          'name': pName,
          'phone': pPhone,
          'role': 'parent',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 2. Create Student Global Record
      final sId = _dbService.generateCustomId('STU');
      await FirebaseFirestore.instance.collection('students').doc(sId).set({
        'studentId': sId,
        'schoolId': widget.admin.schoolId,
        'name': sName,
        'dob': _studentDobController.text,
        'gender': _studentGenderController.text,
        'bloodGroup': _studentBloodController.text,
        'address': _studentAddressController.text,
        'globalStatus': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Link Parent-Student Emergency Mappings
      final linkId = _dbService.generateCustomId('LNK');
      await FirebaseFirestore.instance.collection('parent_student_links').doc(linkId).set({
        'linkId': linkId,
        'schoolId': widget.admin.schoolId,
        'parentId': pId,
        'studentId': sId,
        'relationship': 'father',
        'isEmergencyContact': true,
      });

      // 4. Create Active Enrollment
      final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
      final enrollmentId = 'ENR_${sId}_$activeYear';
      await FirebaseFirestore.instance.collection('enrollments').doc(enrollmentId).set({
        'enrollmentId': enrollmentId,
        'studentId': sId,
        'schoolId': widget.admin.schoolId,
        'academicYearId': activeYear,
        'classId': _admissionsSelectedClassId,
        'sectionId': _admissionsSelectedSectionId,
        'rollNumber': roll,
        'enrollmentStatus': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _studentNameController.clear();
      _studentRollController.clear();
      _parentNameController.clear();
      _parentPhoneController.clear();
      _showSuccess('Student admitted & parent accounts linked!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _promoteStudentsBulk() async {
    if (_promoFromClassId == null || _promoFromSectionId == null || _promoToClassId == null || _promoToSectionId == null || _promoToAcademicYearId == null) {
      _showWarning('Select current parameters, next academic year, class, and section.');
      return;
    }
    if (_promoSelectedStudentIds.isEmpty) {
      _showWarning('No students selected for promotion.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var studentId in _promoSelectedStudentIds) {
        final enrollmentId = 'ENR_${studentId}_$_promoToAcademicYearId';
        final docRef = FirebaseFirestore.instance.collection('enrollments').doc(enrollmentId);
        batch.set(docRef, {
          'enrollmentId': enrollmentId,
          'studentId': studentId,
          'schoolId': widget.admin.schoolId,
          'academicYearId': _promoToAcademicYearId,
          'classId': _promoToClassId,
          'sectionId': _promoToSectionId,
          'rollNumber': 1, // Default fallback roll number
          'enrollmentStatus': 'promoted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      _promoSelectedStudentIds.clear();
      _showSuccess('Bulk promotion completed successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _changeLifecycleStatus() async {
    if (_transferSelectedStudentId == null) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(_transferSelectedStudentId).update({
        'globalStatus': _transferSelectedStatus,
      });
      _showSuccess('Student lifecycle updated to $_transferSelectedStatus!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _createFeeStructure() async {
    final title = _feeTitleController.text.trim();
    final amount = double.tryParse(_feeAmountController.text) ?? 5000.0;
    if (title.isEmpty) return;
    setState(() => _isLoading = true);
    final feeStructureId = _dbService.generateCustomId('FST');
    final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
    try {
      await FirebaseFirestore.instance.collection('fee_structures').doc(feeStructureId).set({
        'feeStructureId': feeStructureId,
        'schoolId': widget.admin.schoolId,
        'academicYearId': activeYear,
        'title': title,
        'amount': amount,
        'dueDate': Timestamp.fromDate(DateTime.parse(_feeDueDateController.text)),
      });
      _feeTitleController.clear();
      _feeAmountController.clear();
      _showSuccess('Fee structure configured!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _allocateFeeBulk() async {
    if (_feeAllocStructureId == null || _feeAllocClassId == null || _feeAllocSectionId == null) {
      _showWarning('Select Fee Structure, Class and Section.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final selectedStructure = _feeStructuresList.firstWhere((fs) => fs.feeStructureId == _feeAllocStructureId);

      // Query active enrollments for target class/section
      final queryEnrollments = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('schoolId', isEqualTo: widget.admin.schoolId)
          .where('classId', isEqualTo: _feeAllocClassId)
          .where('sectionId', isEqualTo: _feeAllocSectionId)
          .where('enrollmentStatus', isEqualTo: 'active')
          .get();

      final enrollments = queryEnrollments.docs.map((doc) => Enrollment.fromMap(doc.data(), doc.id)).toList();
      if (enrollments.isEmpty) {
        _showWarning('No active students found in this class section.');
        setState(() => _isLoading = false);
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (var enr in enrollments) {
        final feeAssId = 'FAS_${enr.studentId}_${selectedStructure.feeStructureId}';
        final docRef = FirebaseFirestore.instance.collection('fee_assignments').doc(feeAssId);
        batch.set(docRef, {
          'feeAssignmentId': feeAssId,
          'schoolId': widget.admin.schoolId,
          'studentId': enr.studentId,
          'academicYearId': selectedStructure.academicYearId,
          'feeStructureId': selectedStructure.feeStructureId,
          'title': selectedStructure.title,
          'amount': selectedStructure.amount,
          'discount': 0.0,
          'netAmount': selectedStructure.amount,
          'status': 'pending',
          'amountPaid': 0.0,
          'dueDate': Timestamp.fromDate(selectedStructure.dueDate),
        });
      }
      await batch.commit();
      _showSuccess('Fee allocated successfully to ${enrollments.length} students.');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _postAnnouncement() async {
    final title = _announcementTitleController.text.trim();
    final body = _announcementBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;
    setState(() => _isLoading = true);
    final announceId = _dbService.generateCustomId('ANC');
    try {
      await FirebaseFirestore.instance.collection('announcements').doc(announceId).set({
        'announcementId': announceId,
        'schoolId': widget.admin.schoolId,
        'senderId': widget.admin.userId,
        'title': title,
        'body': body,
        'scope': _announcementScope,
        'targetClassId': _announcementClassId ?? '',
        'targetSectionId': _announcementSectionId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _announcementTitleController.clear();
      _announcementBodyController.clear();
      _showSuccess('Announcement dispatched successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  Future<void> _updateSchoolProfile() async {
    final name = _schoolNameController.text.trim();
    final board = _schoolBoardController.text.trim();
    final addr = _schoolAddressController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('schools').doc(widget.admin.schoolId).update({
        'name': name,
        'board': board,
        'address': addr,
      });
      _showSuccess('School profile updated successfully!');
      await _loadAdminData();
    } catch (e) {
      _showWarning('Error: $e');
    }
  }

  // --- RENDERING PAGE VIEWS ---

  Widget _buildDashboardHome() {
    // Analytics calculations
    final totalStudentsCount = _schoolStudents.length;
    final totalTeachersCount = _schoolTeachers.length;
    final activeClassesCount = _classesList.length;

    double totalBilled = 0;
    double totalCollected = 0;
    for (var f in _feeAssignmentsList) {
      totalBilled += f.netAmount;
      totalCollected += f.amountPaid;
    }
    final rate = totalBilled > 0 ? (totalCollected / totalBilled * 100).toStringAsFixed(1) : '0.0';
    final outstanding = totalBilled - totalCollected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row of 6 Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = (constraints.maxWidth - 5 * EduTheme.space16) / 6;
              return Wrap(
                spacing: EduTheme.space16,
                runSpacing: EduTheme.space16,
                children: [
                  _buildStatMetricCard('Students', totalStudentsCount.toString(), Icons.groups, const Color(0xFFEFF6FF), const Color(0xFF2563EB), cardWidth),
                  _buildStatMetricCard('Faculty', totalTeachersCount.toString(), Icons.supervisor_account, const Color(0xFFF0FDF4), const Color(0xFF10B981), cardWidth),
                  _buildStatMetricCard('Classes', activeClassesCount.toString(), Icons.class_outlined, const Color(0xFFFFF7ED), const Color(0xFFF97316), cardWidth),
                  _buildStatMetricCard('Collection Rate', '$rate%', Icons.trending_up, const Color(0xFFFAF5FF), const Color(0xFF8B5CF6), cardWidth),
                  _buildStatMetricCard('Collected', '₹${totalCollected.toStringAsFixed(0)}', Icons.wallet, const Color(0xFFECFDF5), const Color(0xFF059669), cardWidth),
                  _buildStatMetricCard('Outstanding', '₹${outstanding.toStringAsFixed(0)}', Icons.money_off, const Color(0xFFFEF2F2), const Color(0xFFDC2626), cardWidth),
                ],
              );
            },
          ),
          const SizedBox(height: EduTheme.space32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Collection Rate Card
                    _buildVisualCard(
                      'Collection & Billing Overview',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Billed: ₹${totalBilled.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              Text('Rate: $rate%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: totalBilled > 0 ? (totalCollected / totalBilled) : 0,
                            minHeight: 12,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: EduTheme.space24),
                    // Recent Activity Audit Feed
                    _buildVisualCard(
                      'Operational Activity Feed',
                      _auditLogsList.isEmpty
                          ? const EduEmptyState(icon: Icons.history, title: 'No activity logs', description: 'Operations are running cleanly.')
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _auditLogsList.length > 5 ? 5 : _auditLogsList.length,
                              separatorBuilder: (c, i) => const Divider(height: 24),
                              itemBuilder: (context, idx) {
                                final log = _auditLogsList[idx];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFF1F5F9),
                                    child: Icon(Icons.history, color: Color(0xFF64748B)),
                                  ),
                                  title: Text(_getReadableAction(log.action), style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                                  subtitle: Text(_getReadableDetails(log.entityType, log.entityId)),
                                  trailing: Text(_formatDate(log.timestamp), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EduTheme.space24),
              // Right Column (flex 2)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Upcoming Activity
                    _buildVisualCard(
                      'Upcoming Roster & Events',
                      Column(
                        children: [
                          _buildEventRow('Upcoming Exams', '${_examsList.length} Scheduled', Icons.assignment, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                          const Divider(height: 24),
                          _buildEventRow('Active Announcements', '${_announcementsList.length} Dispatched', Icons.campaign, const Color(0xFFFFF7ED), const Color(0xFFF97316)),
                          const Divider(height: 24),
                          _buildEventRow('Academic Calendar Status', 'Operating: 2026-2027', Icons.calendar_today, const Color(0xFFF0FDF4), const Color(0xFF10B981)),
                        ],
                      ),
                    ),
                    const SizedBox(height: EduTheme.space24),
                    // Quick Status Student Overview
                    _buildVisualCard(
                      'Student Roster Lifecycle',
                      Column(
                        children: [
                          _buildCountLabel('Active Enrolled', _schoolStudents.length, const Color(0xFFECFDF5), const Color(0xFF047857)),
                          const SizedBox(height: 8),
                          _buildCountLabel('Academic Classes Configured', _classesList.length, const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetricCard(String title, String value, IconData icon, Color bgColor, Color iconColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(EduTheme.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: EduTheme.radius16,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [EduTheme.shadowLevel1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildVisualCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EduTheme.space24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: EduTheme.radius20,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [EduTheme.shadowLevel1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildEventRow(String title, String subtitle, IconData icon, Color bg, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: EduTheme.colorTextDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountLabel(String title, int count, Color bg, Color textC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: EduTheme.radius12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textC)),
          Text(count.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textC)),
        ],
      ),
    );
  }

  Widget _buildAcademicYearsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Operating Calendars',
              _academicYearsList.isEmpty
                  ? const EduEmptyState(icon: Icons.calendar_today, title: 'No academic years', description: 'Add a new calendar below.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _academicYearsList.length,
                      separatorBuilder: (c, i) => const Divider(height: 24),
                      itemBuilder: (context, idx) {
                        final yr = _academicYearsList[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(yr.year, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                          subtitle: Text('Duration: ${yr.startDate} to ${yr.endDate}'),
                          trailing: _buildStatusBadge(yr.status),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Add Academic Year',
              Column(
                children: [
                  TextFormField(controller: _academicYearController, decoration: const InputDecoration(labelText: 'Academic Year')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _yearStartDateController, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _yearEndDateController, decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _createAcademicYear, child: const Text('Add Year')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSectionsView() {
    if (_workspaceClassId != null && _workspaceSectionId != null) {
      return _buildClassWorkspace();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildVisualCard(
                  'Academic Class Roster',
                  _classesList.isEmpty
                      ? const EduEmptyState(icon: Icons.class_outlined, title: 'No classes registered', description: 'Register classes on the right.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _classesList.length,
                          separatorBuilder: (c, i) => const Divider(height: 24),
                          itemBuilder: (context, idx) {
                            final cls = _classesList[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                              subtitle: Text('ID: ${cls.classId}'),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                _buildVisualCard(
                  'Class Workspace Selector (Select Section to Enter Workspace)',
                  _sectionsList.isEmpty
                      ? const EduEmptyState(icon: Icons.layers, title: 'No sections configured', description: 'Create sections mapping.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _sectionsList.length,
                          separatorBuilder: (c, i) => const Divider(height: 24),
                          itemBuilder: (context, idx) {
                            final sec = _sectionsList[idx];
                            final cls = _classesList.firstWhere((c) => c.classId == sec.classId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unknown', createdAt: DateTime.now()));
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.meeting_room, color: Color(0xFF2563EB)),
                              title: Text('${cls.name} - Section ${sec.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                              subtitle: Text('Capacity: ${sec.capacity} | Click to Open operational cockpit'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () {
                                setState(() {
                                  _workspaceClassId = sec.classId;
                                  _workspaceSectionId = sec.sectionId;
                                  _workspaceActiveTab = 0;
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildVisualCard(
                  'Register Class',
                  Column(
                    children: [
                      TextFormField(controller: _classNameController, decoration: const InputDecoration(labelText: 'Class Name (e.g. Grade 5)')),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _createClassDoc, child: const Text('Add Class')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildVisualCard(
                  'Configure Section',
                  Column(
                    children: [
                      TextFormField(controller: _sectionNameController, decoration: const InputDecoration(labelText: 'Section Name (e.g. A)')),
                      const SizedBox(height: 12),
                      TextFormField(controller: _sectionCapacityController, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _admissionsSelectedClassId,
                        items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => _admissionsSelectedClassId = val),
                        decoration: const InputDecoration(labelText: 'Target Class Mapping'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _createSectionDoc, child: const Text('Add Section')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _registerSubjectSelectedClassId;

  void _showEditSubjectDialog(SubjectModel sub) {
    final nameCtrl = TextEditingController(text: sub.name);
    final codeCtrl = TextEditingController(text: sub.code);
    String? selClassId = sub.classId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject Mappings', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
            const SizedBox(height: 12),
            TextFormField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Subject Code')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selClassId,
              items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
              onChanged: (val) => selClassId = val,
              decoration: const InputDecoration(labelText: 'Mapped Class'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSubjectDoc(sub.subjectId, nameCtrl.text.trim(), codeCtrl.text.trim(), selClassId ?? '');
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Subjects Catalog',
              _subjectsList.isEmpty
                  ? const EduEmptyState(icon: Icons.book, title: 'No subjects', description: 'Register core subjects on the right.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subjectsList.length,
                      separatorBuilder: (c, i) => const Divider(height: 24),
                      itemBuilder: (context, idx) {
                        final sub = _subjectsList[idx];
                        final targetClass = _classesList.firstWhere((c) => c.classId == sub.classId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unassigned', createdAt: DateTime.now()));
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                          subtitle: Text('Code: ${sub.code} | Class: ${targetClass.name}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
                                onPressed: () => _showEditSubjectDialog(sub),
                                tooltip: 'Edit Subject',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Subject'),
                                      content: Text('Are you sure you want to delete the subject ${sub.name}? This will remove all associated teacher assignments.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteSubjectDoc(sub.subjectId);
                                          },
                                          child: const Text('Delete Subject'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'Delete Subject',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Register Subject',
              Column(
                children: [
                  TextFormField(controller: _subjectNameController, decoration: const InputDecoration(labelText: 'Subject Name')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _subjectCodeController, decoration: const InputDecoration(labelText: 'Subject Code')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _registerSubjectSelectedClassId,
                    items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _registerSubjectSelectedClassId = val),
                    decoration: const InputDecoration(labelText: 'Target Class'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_registerSubjectSelectedClassId == null) {
                        _showWarning('Please select a target class first.');
                        return;
                      }
                      // Use selection to create subject
                      _createSubjectDocWithClass(_registerSubjectSelectedClassId!);
                    },
                    child: const Text('Add Subject'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetablesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildVisualCard(
                  'Academic Schedule Roster',
                  _timetablesList.isEmpty
                      ? const EduEmptyState(icon: Icons.schedule, title: 'No Timetable entries', description: 'Add period slot slots below.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _timetablesList.length,
                          separatorBuilder: (c, i) => const Divider(height: 24),
                          itemBuilder: (context, idx) {
                            final tt = _timetablesList[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.timer),
                              title: Text('Period ${tt.periodNumber} - ${tt.dayOfWeek.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${tt.startTime} to ${tt.endTime}'),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildVisualCard(
                  'Add Timetable Slot',
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedTimetableDay,
                        items: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
                            .map((day) => DropdownMenuItem(value: day, child: Text(day.toUpperCase())))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTimetableDay = val ?? 'monday'),
                        decoration: const InputDecoration(labelText: 'Day of Week'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _timetableSelectedClassId,
                        items: _classesList
                            .map((cls) => DropdownMenuItem(value: cls.classId, child: Text(cls.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _timetableSelectedClassId = val),
                        decoration: const InputDecoration(labelText: 'Select Class'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _timetableSelectedSectionId,
                        items: _sectionsList
                            .map((sec) => DropdownMenuItem(value: sec.sectionId, child: Text(sec.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _timetableSelectedSectionId = val),
                        decoration: const InputDecoration(labelText: 'Select Section'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _timetableSelectedSubjectId,
                        items: _subjectsList
                            .map((sub) => DropdownMenuItem(value: sub.subjectId, child: Text(sub.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _timetableSelectedSubjectId = val),
                        decoration: const InputDecoration(labelText: 'Select Subject'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _timetableSelectedTeacherId,
                        items: _schoolTeachers
                            .map((tch) => DropdownMenuItem(value: tch.userId, child: Text(tch.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _timetableSelectedTeacherId = val),
                        decoration: const InputDecoration(labelText: 'Select Faculty'),
                      ),
                      DropdownButtonFormField<int>(
                        value: _timetablePeriodNumber,
                        items: List.generate(8, (i) => i + 1)
                            .map((p) => DropdownMenuItem(value: p, child: Text('Period $p')))
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _timetablePeriodNumber = val;
                            // Time Slot Engine math
                            try {
                              final startParts = _settingsStartTimeController.text.split(':');
                              final startH = int.parse(startParts[0]);
                              final startM = int.parse(startParts[1]);
                              final duration = int.parse(_settingsPeriodDurationController.text);
                              
                              final lunchStartParts = _settingsLunchStartController.text.split(':');
                              final lunchH = int.parse(lunchStartParts[0]);
                              final lunchM = int.parse(lunchStartParts[1]);
                              final lunchDur = int.parse(_settingsLunchDurationController.text);
                              
                              DateTime current = DateTime(2026, 6, 21, startH, startM);
                              DateTime lunchStart = DateTime(2026, 6, 21, lunchH, lunchM);
                              
                              for (int p = 1; p <= val; p++) {
                                // If current time equals or exceeds lunch start time, add lunch duration
                                if (current.isAfter(lunchStart) || current.isAtSameMomentAs(lunchStart)) {
                                  current = current.add(Duration(minutes: lunchDur));
                                  // Reset lunch start to end of lunch so we don't trigger it again
                                  lunchStart = lunchStart.add(Duration(days: 1)); 
                                }
                                if (p == val) {
                                  final startStr = "${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}";
                                  final endTemp = current.add(Duration(minutes: duration));
                                  final endStr = "${endTemp.hour.toString().padLeft(2, '0')}:${endTemp.minute.toString().padLeft(2, '0')}";
                                  _timetableStartTimeController.text = startStr;
                                  _timetableEndTimeController.text = endStr;
                                }
                                current = current.add(Duration(minutes: duration));
                              }
                            } catch (e) {
                              print("Error running timetable slot engine: $e");
                            }
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Period Number *'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _timetableStartTimeController, decoration: const InputDecoration(labelText: 'Start Time (Auto-calculated)'), readOnly: true)),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _timetableEndTimeController, decoration: const InputDecoration(labelText: 'End Time (Auto-calculated)'), readOnly: true)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _createTimetableSlot, child: const Text('Add Slot')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Exam Weights config',
              _examsList.isEmpty
                  ? const EduEmptyState(icon: Icons.assessment, title: 'No configured exams', description: 'Add exam entries.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _examsList.length,
                      separatorBuilder: (c, i) => const Divider(height: 24),
                      itemBuilder: (context, idx) {
                        final ex = _examsList[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                          subtitle: Text('Term: ${ex.term}'),
                          trailing: Text('Weight: ${ex.weightage}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Configure Assessment',
              Column(
                children: [
                  TextFormField(controller: _examNameController, decoration: const InputDecoration(labelText: 'Assessment Title')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _examTermController, decoration: const InputDecoration(labelText: 'Operating Term')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _examWeightageController, decoration: const InputDecoration(labelText: 'Weight Percentage'), keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _createExam, child: const Text('Add Structure')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    void _showStudentDetailDialog(Student s, String classSecText, String rollNoText) {
    // Find parent linkage
    final link = _parentStudentLinksList.firstWhere((l) => l.studentId == s.studentId, orElse: () => ParentStudentLink(linkId: '', schoolId: '', parentId: '', studentId: s.studentId, relationship: '', isEmergencyContact: false));
    final parent = link.parentId.isEmpty ? null : _schoolParents.firstWhere((p) => p.userId == link.parentId, orElse: () => UserModel(userId: link.parentId, schoolId: '', phone: '', email: '', name: 'Not Linked', role: 'parent', status: 'active', createdAt: DateTime.now()));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: EduTheme.colorPrimaryBrandTeal),
            const SizedBox(width: 10),
            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academic Placement: $classSecText (Roll No: $rollNoText)'),
            const SizedBox(height: 8),
            Text('Date of Birth: ${s.dob}'),
            const SizedBox(height: 8),
            Text('Gender: ${s.gender.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Blood Group: ${s.bloodGroup}'),
            const SizedBox(height: 8),
            Text('Residential Address: ${s.address}'),
            const Divider(height: 24),
            const Text('Guardian Contacts', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Text('Name: ${parent?.name ?? "Not Linked"}'),
            const SizedBox(height: 8),
            Text('Phone: ${parent?.phone ?? "No contact phone"}'),
            const SizedBox(height: 8),
            Text('Email: ${parent?.email ?? "No contact email"}'),
            const SizedBox(height: 8),
            Text('Emergency Contact: ${link.isEmergencyContact ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showEditStudentDialog(Student s, Enrollment enrollment) {
    final nameCtrl = TextEditingController(text: s.name);
    final addrCtrl = TextEditingController(text: s.address);
    final dobCtrl = TextEditingController(text: s.dob);
    final genderCtrl = TextEditingController(text: s.gender);
    final bloodCtrl = TextEditingController(text: s.bloodGroup);
    final rollCtrl = TextEditingController(text: enrollment.rollNumber.toString());
    
    String? selClassId = enrollment.classId.isEmpty ? null : enrollment.classId;
    String? selSecId = enrollment.sectionId.isEmpty ? null : enrollment.sectionId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Student Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Student Full Name')),
                const SizedBox(height: 12),
                TextFormField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextFormField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)')),
                const SizedBox(height: 12),
                TextFormField(controller: genderCtrl, decoration: const InputDecoration(labelText: 'Gender')),
                const SizedBox(height: 12),
                TextFormField(controller: bloodCtrl, decoration: const InputDecoration(labelText: 'Blood Group')),
                const SizedBox(height: 12),
                TextFormField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selClassId,
                  items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                  onChanged: (val) => setDialogState(() => selClassId = val),
                  decoration: const InputDecoration(labelText: 'Class'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selSecId,
                  items: _sectionsList.map((sec) => DropdownMenuItem(value: sec.sectionId, child: Text(sec.name))).toList(),
                  onChanged: (val) => setDialogState(() => selSecId = val),
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final rNum = int.tryParse(rollCtrl.text) ?? 1;
                Navigator.pop(context);
                _updateStudentDoc(s.studentId, nameCtrl.text.trim(), addrCtrl.text.trim(), dobCtrl.text.trim(), genderCtrl.text.trim(), bloodCtrl.text.trim(), selClassId ?? '', selSecId ?? '', rNum);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Column(
        children: [
          _buildVisualCard(
            'High-Density Student Roster',
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search roster by student name...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _schoolStudents.isEmpty
                    ? const EduEmptyState(icon: Icons.people, title: 'No student registry', description: 'Admit student in the admissions view.')
                    : Table(
                        border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1.2),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                            children: [
                              Padding(padding: EdgeInsets.all(12), child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                              Padding(padding: EdgeInsets.all(12), child: Text('CLASS & SECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                              Padding(padding: EdgeInsets.all(12), child: Text('ROLL NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                              Padding(padding: EdgeInsets.all(12), child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                              Padding(padding: EdgeInsets.all(12), child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            ],
                          ),
                          ..._schoolStudents
                              .where((s) => s.name.toLowerCase().contains(_searchController.text.toLowerCase()))
                              .map((s) {
                                final enrollment = _enrollmentsList.firstWhere(
                                  (e) => e.studentId == s.studentId,
                                  orElse: () => Enrollment(enrollmentId: '', studentId: s.studentId, schoolId: '', academicYearId: '', classId: '', sectionId: '', rollNumber: 0, enrollmentStatus: '', updatedAt: DateTime.now())
                                );
                                final targetClass = _classesList.firstWhere((c) => c.classId == enrollment.classId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unassigned', createdAt: DateTime.now()));
                                final targetSection = _sectionsList.firstWhere((sec) => sec.sectionId == enrollment.sectionId, orElse: () => SectionModel(sectionId: '', schoolId: '', classId: '', name: '', capacity: 30, createdAt: DateTime.now()));
                                final classSecText = enrollment.classId.isEmpty ? 'Unassigned' : '${targetClass.name} - ${targetSection.name}';
                                final rollNoText = enrollment.rollNumber > 0 ? enrollment.rollNumber.toString() : '-';

                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    Padding(padding: const EdgeInsets.all(12), child: Text(classSecText)),
                                    Padding(padding: const EdgeInsets.all(12), child: Text(rollNoText)),
                                    Padding(padding: const EdgeInsets.all(12), child: _buildStatusBadge(s.globalStatus)),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: Colors.blue, size: 18),
                                            onPressed: () => _showStudentDetailDialog(s, classSecText, rollNoText),
                                            tooltip: 'View Profile',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                                            onPressed: () => _showEditStudentDialog(s, enrollment),
                                            tooltip: 'Edit Profile',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Withdraw Student Registration'),
                                                  content: Text('Are you sure you want to completely withdraw ${s.name} from the school database? This will clear active enrollment records.'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteStudentDoc(s.studentId);
                                                      },
                                                      child: const Text('Withdraw Registration'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            tooltip: 'Withdraw Student',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildVisualCard(
            'Guided Student Admission Wizard',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Row
                Row(
                  children: [
                    _buildStepIndicator(0, 'Info', _admissionWizardStep),
                    _buildStepLine(),
                    _buildStepIndicator(1, 'Placement', _admissionWizardStep),
                    _buildStepLine(),
                    _buildStepIndicator(2, 'Parent', _admissionWizardStep),
                    _buildStepLine(),
                    _buildStepIndicator(3, 'Review', _admissionWizardStep),
                  ],
                ),
                const SizedBox(height: 32),

                // Wizard Steps Switcher
                if (_admissionWizardStep == 0) ...[
                  const Text('Step 1: Student Demographics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  TextFormField(controller: _studentNameController, decoration: const InputDecoration(labelText: 'Student Full Name *')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _studentDobController, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD) *')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _studentGenderController, decoration: const InputDecoration(labelText: 'Gender'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _studentBloodController, decoration: const InputDecoration(labelText: 'Blood Group'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _studentAddressController, decoration: const InputDecoration(labelText: 'Residential Address')),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_studentNameController.text.trim().isEmpty || _studentDobController.text.trim().isEmpty) {
                            _showWarning('Student Name and DOB are required.');
                            return;
                          }
                          setState(() => _admissionWizardStep = 1);
                        },
                        child: const Text('Next: Placement'),
                      ),
                    ],
                  ),
                ] else if (_admissionWizardStep == 1) ...[
                  const Text('Step 2: Class & Section Placement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _admissionsSelectedClassId,
                    items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _admissionsSelectedClassId = val),
                    decoration: const InputDecoration(labelText: 'Assign Class *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _admissionsSelectedSectionId,
                    items: _sectionsList
                        .where((s) => s.classId == _admissionsSelectedClassId)
                        .map((s) => DropdownMenuItem(value: s.sectionId, child: Text(s.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _admissionsSelectedSectionId = val),
                    decoration: const InputDecoration(labelText: 'Assign Section *'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _studentRollController, decoration: const InputDecoration(labelText: 'Roll Number *'), keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => setState(() => _admissionWizardStep = 0), child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () {
                          if (_admissionsSelectedClassId == null || _admissionsSelectedSectionId == null || _studentRollController.text.trim().isEmpty) {
                            _showWarning('Class, Section and Roll Number are required.');
                            return;
                          }
                          setState(() => _admissionWizardStep = 2);
                        },
                        child: const Text('Next: Parent Linking'),
                      ),
                    ],
                  ),
                ] else if (_admissionWizardStep == 2) ...[
                  const Text('Step 3: Guardian Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _admissionParentPhoneController,
                          decoration: const InputDecoration(labelText: 'Search Guardian Phone *'),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final phone = _admissionParentPhoneController.text.trim();
                          if (phone.isEmpty) {
                            _showWarning('Please enter phone number to lookup.');
                            return;
                          }
                          setState(() => _isLoading = true);
                          final parent = await _dbService.getUserByPhone(phone);
                          setState(() {
                            _admissionFoundParent = parent;
                            _admissionParentSearched = true;
                            if (parent != null) {
                              _admissionParentNameController.text = parent.name;
                            } else {
                              _admissionParentNameController.clear();
                            }
                            _isLoading = false;
                          });
                        },
                        child: const Text('Lookup'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_admissionParentSearched) ...[
                    if (_admissionFoundParent != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Found existing parent: ${_admissionFoundParent!.name} (${_admissionFoundParent!.phone})')),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('No existing guardian found. Please input the new guardian profile below.'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: _admissionParentNameController, decoration: const InputDecoration(labelText: 'Guardian Name *')),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => setState(() => _admissionWizardStep = 1), child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () {
                          if (!_admissionParentSearched) {
                            _showWarning('Please search/lookup parent via mobile number.');
                            return;
                          }
                          if (_admissionFoundParent == null && _admissionParentNameController.text.trim().isEmpty) {
                            _showWarning('Please provide a guardian name.');
                            return;
                          }
                          setState(() => _admissionWizardStep = 3);
                        },
                        child: const Text('Next: Review & Confirm'),
                      ),
                    ],
                  ),
                ] else if (_admissionWizardStep == 3) ...[
                  const Text('Step 4: Review Admission Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  _buildReviewRow('Student Name', _studentNameController.text),
                  _buildReviewRow('Date of Birth', _studentDobController.text),
                  _buildReviewRow('Gender/Blood', '${_studentGenderController.text} / ${_studentBloodController.text}'),
                  _buildReviewRow('Address', _studentAddressController.text),
                  _buildReviewRow('Class & Section', '${_classesList.firstWhere((c) => c.classId == _admissionsSelectedClassId).name} - ${_sectionsList.firstWhere((s) => s.sectionId == _admissionsSelectedSectionId).name}'),
                  _buildReviewRow('Roll Number', _studentRollController.text),
                  _buildReviewRow('Guardian Name', _admissionFoundParent != null ? _admissionFoundParent!.name : _admissionParentNameController.text),
                  _buildReviewRow('Guardian Phone', _admissionParentPhoneController.text),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => setState(() => _admissionWizardStep = 2), child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () async {
                          // Adapt existing _admitStudentDoc to use wizard variables
                          setState(() => _isLoading = true);
                          try {
                            String pId = _admissionFoundParent != null ? _admissionFoundParent!.userId : _dbService.generateCustomId('PAR');
                            if (_admissionFoundParent == null) {
                              await FirebaseFirestore.instance.collection('users').doc(pId).set({
                                'userId': pId,
                                'schoolId': widget.admin.schoolId,
                                'name': _admissionParentNameController.text.trim(),
                                'phone': _admissionParentPhoneController.text.trim(),
                                'role': 'parent',
                                'status': 'active',
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                            }

                            final sId = _dbService.generateCustomId('STU');
                            await FirebaseFirestore.instance.collection('students').doc(sId).set({
                              'studentId': sId,
                              'schoolId': widget.admin.schoolId,
                              'name': _studentNameController.text.trim(),
                              'dob': _studentDobController.text.trim(),
                              'gender': _studentGenderController.text.trim(),
                              'bloodGroup': _studentBloodController.text.trim(),
                              'address': _studentAddressController.text.trim(),
                              'globalStatus': 'active',
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            final linkId = _dbService.generateCustomId('LNK');
                            await FirebaseFirestore.instance.collection('parent_student_links').doc(linkId).set({
                              'linkId': linkId,
                              'schoolId': widget.admin.schoolId,
                              'parentId': pId,
                              'studentId': sId,
                              'relationship': 'father',
                              'isEmergencyContact': true,
                            });

                            final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
                            final enrollmentId = 'ENR_${sId}_$activeYear';
                            await FirebaseFirestore.instance.collection('enrollments').doc(enrollmentId).set({
                              'enrollmentId': enrollmentId,
                              'studentId': sId,
                              'schoolId': widget.admin.schoolId,
                              'academicYearId': activeYear,
                              'classId': _admissionsSelectedClassId,
                              'sectionId': _admissionsSelectedSectionId,
                              'rollNumber': int.tryParse(_studentRollController.text) ?? 1,
                              'enrollmentStatus': 'active',
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            // Clear forms and reset step
                            _studentNameController.clear();
                            _studentRollController.clear();
                            _admissionParentNameController.clear();
                            _admissionParentPhoneController.clear();
                            setState(() {
                              _admissionWizardStep = 0;
                              _admissionParentSearched = false;
                              _admissionFoundParent = null;
                            });

                            _showSuccess('Student admitted & parent accounts linked!');
                            await _loadAdminData();
                          } catch (e) {
                            _showWarning('Error: $e');
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: const Text('Confirm & Admit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, int currentStep) {
    bool active = step <= currentStep;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          child: Text('${step + 1}', style: TextStyle(color: active ? Colors.white : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: active ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }

  Widget _buildPromotionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Select Students for Promotion',
              _schoolStudents.isEmpty
                  ? const EduEmptyState(icon: Icons.people, title: 'No students available', description: 'Ensure roster has active accounts.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _schoolStudents.length,
                      itemBuilder: (context, idx) {
                        final s = _schoolStudents[idx];
                        final selected = _promoSelectedStudentIds.contains(s.studentId);
                        return CheckboxListTile(
                          title: Text(s.name),
                          subtitle: Text(s.studentId),
                          value: selected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _promoSelectedStudentIds.add(s.studentId);
                              } else {
                                _promoSelectedStudentIds.remove(s.studentId);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Bulk Promotion Console',
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _promoToAcademicYearId,
                    items: _academicYearsList.map((ay) => DropdownMenuItem(value: ay.academicYearId, child: Text(ay.year))).toList(),
                    onChanged: (val) => setState(() => _promoToAcademicYearId = val),
                    decoration: const InputDecoration(labelText: 'To Academic Year'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _promoToClassId,
                    items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _promoToClassId = val),
                    decoration: const InputDecoration(labelText: 'To Class'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _promoToSectionId,
                    items: _sectionsList.map((s) => DropdownMenuItem(value: s.sectionId, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _promoToSectionId = val),
                    decoration: const InputDecoration(labelText: 'To Section'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _promoteStudentsBulk, child: const Text('Promote Bulk')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentLinkerWizard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildVisualCard(
            'Guided Parent-Student Linker Wizard',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Row
                Row(
                  children: [
                    _buildStepIndicator(0, 'Find Parent', _parentLinkWizardStep),
                    _buildStepLine(),
                    _buildStepIndicator(1, 'Select Student', _parentLinkWizardStep),
                    _buildStepLine(),
                    _buildStepIndicator(2, 'Link & Confirm', _parentLinkWizardStep),
                  ],
                ),
                const SizedBox(height: 32),

                // Wizard Steps Switcher
                if (_parentLinkWizardStep == 0) ...[
                  const Text('Step 1: Locate Guardian Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _parentLinkParentPhoneController,
                          decoration: const InputDecoration(labelText: 'Search Guardian Phone *'),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final phone = _parentLinkParentPhoneController.text.trim();
                          if (phone.isEmpty) {
                            _showWarning('Please enter a mobile number to lookup.');
                            return;
                          }
                          setState(() => _isLoading = true);
                          final parent = await _dbService.getUserByPhone(phone);
                          setState(() {
                            _parentLinkFoundParent = parent;
                            _parentLinkParentSearched = true;
                            if (parent != null) {
                              _parentLinkParentNameController.text = parent.name;
                            } else {
                              _parentLinkParentNameController.clear();
                            }
                            _isLoading = false;
                          });
                        },
                        child: const Text('Lookup'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_parentLinkParentSearched) ...[
                    if (_parentLinkFoundParent != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Found existing parent record: ${_parentLinkFoundParent!.name}')),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('No existing guardian found. You can create a new guardian record during this step.'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: _parentLinkParentNameController, decoration: const InputDecoration(labelText: 'Guardian Full Name *')),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (!_parentLinkParentSearched) {
                            _showWarning('Please search/lookup parent via mobile number first.');
                            return;
                          }
                          if (_parentLinkFoundParent == null && _parentLinkParentNameController.text.trim().isEmpty) {
                            _showWarning('Please enter the Guardian Name.');
                            return;
                          }
                          setState(() => _parentLinkWizardStep = 1);
                        },
                        child: const Text('Next: Choose Student'),
                      ),
                    ],
                  ),
                ] else if (_parentLinkWizardStep == 1) ...[
                  const Text('Step 2: Connect Student Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _parentLinkSelectedStudentId,
                    items: _schoolStudents.map((s) => DropdownMenuItem(value: s.studentId, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _parentLinkSelectedStudentId = val),
                    decoration: const InputDecoration(labelText: 'Select Student *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _parentLinkRelationship,
                    items: const [
                      DropdownMenuItem(value: 'father', child: Text('Father')),
                      DropdownMenuItem(value: 'mother', child: Text('Mother')),
                      DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                    ],
                    onChanged: (val) => setState(() => _parentLinkRelationship = val ?? 'father'),
                    decoration: const InputDecoration(labelText: 'Relationship to Student'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => setState(() => _parentLinkWizardStep = 0), child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () {
                          if (_parentLinkSelectedStudentId == null) {
                            _showWarning('Please select a student to link.');
                            return;
                          }
                          setState(() => _parentLinkWizardStep = 2);
                        },
                        child: const Text('Next: Review Link'),
                      ),
                    ],
                  ),
                ] else if (_parentLinkWizardStep == 2) ...[
                  const Text('Step 3: Review Linkage Config', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  _buildReviewRow('Guardian Name', _parentLinkFoundParent != null ? _parentLinkFoundParent!.name : _parentLinkParentNameController.text),
                  _buildReviewRow('Guardian Phone', _parentLinkParentPhoneController.text),
                  _buildReviewRow('Linked Student', _schoolStudents.firstWhere((s) => s.studentId == _parentLinkSelectedStudentId).name),
                  _buildReviewRow('Relationship', _parentLinkRelationship.toUpperCase()),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => setState(() => _parentLinkWizardStep = 1), child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            String pId = _parentLinkFoundParent != null ? _parentLinkFoundParent!.userId : _dbService.generateCustomId('PAR');
                            if (_parentLinkFoundParent == null) {
                              await FirebaseFirestore.instance.collection('users').doc(pId).set({
                                'userId': pId,
                                'schoolId': widget.admin.schoolId,
                                'name': _parentLinkParentNameController.text.trim(),
                                'phone': _parentLinkParentPhoneController.text.trim(),
                                'role': 'parent',
                                'status': 'active',
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                            }

                            final linkId = _dbService.generateCustomId('LNK');
                            await FirebaseFirestore.instance.collection('parent_student_links').doc(linkId).set({
                              'linkId': linkId,
                              'schoolId': widget.admin.schoolId,
                              'parentId': pId,
                              'studentId': _parentLinkSelectedStudentId,
                              'relationship': _parentLinkRelationship,
                              'isEmergencyContact': true,
                            });

                            // Clear and reset wizard
                            _parentLinkParentNameController.clear();
                            _parentLinkParentPhoneController.clear();
                            setState(() {
                              _parentLinkWizardStep = 0;
                              _parentLinkSelectedStudentId = null;
                              _parentLinkFoundParent = null;
                              _parentLinkParentSearched = false;
                            });

                            _showSuccess('Parent and student linked successfully!');
                            await _loadAdminData();
                          } catch (e) {
                            _showWarning('Error: $e');
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: const Text('Confirm Linkage'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildClassWorkspace() {
    final cls = _classesList.firstWhere((c) => c.classId == _workspaceClassId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unknown', createdAt: DateTime.now()));
    final sec = _sectionsList.firstWhere((s) => s.sectionId == _workspaceSectionId, orElse: () => SectionModel(sectionId: '', schoolId: '', classId: '', name: 'Unknown', capacity: 30, createdAt: DateTime.now()));

    // Filter data for this workspace section
    final sectionEnrollments = _enrollmentsList.where((e) => e.classId == _workspaceClassId && e.sectionId == _workspaceSectionId).toList();
    final studentIds = sectionEnrollments.map((e) => e.studentId).toSet();
    final sectionStudents = _schoolStudents.where((s) => studentIds.contains(s.studentId)).toList();
    
    final sectionAssignments = _teacherAssignmentsList.where((ta) => ta.classId == _workspaceClassId && ta.sectionId == _workspaceSectionId).toList();
    final classTeachers = sectionAssignments.where((ta) => ta.assignmentType == 'class_teacher').toList();
    final subjectTeachers = sectionAssignments.where((ta) => ta.assignmentType == 'subject_teacher').toList();

    final sectionTimetable = _timetablesList.where((tt) => tt.classId == _workspaceClassId && tt.sectionId == _workspaceSectionId).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${cls.name} - Section ${sec.name} Workspace', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => setState(() => _workspaceClassId = null),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWorkspaceTab(0, 'Overview', Icons.dashboard),
                _buildWorkspaceTab(1, 'Students', Icons.people),
                _buildWorkspaceTab(2, 'Teachers', Icons.supervisor_account),
                _buildWorkspaceTab(3, 'Timetable', Icons.calendar_today),
                _buildWorkspaceTab(4, 'Exams & Marks', Icons.assessment),
                _buildWorkspaceTab(5, 'Fees Ledger', Icons.account_balance_wallet),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        color: const Color(0xFFF8FAFC),
        child: _buildWorkspaceContent(sectionStudents, classTeachers, subjectTeachers, sectionTimetable),
      ),
    );
  }

  Widget _buildWorkspaceTab(int index, String label, IconData icon) {
    final active = _workspaceActiveTab == index;
    return InkWell(
      onTap: () => setState(() => _workspaceActiveTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF2563EB) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceContent(
    List<Student> students,
    List<TeacherAssignment> classTeachers,
    List<TeacherAssignment> subjectTeachers,
    List<Timetable> timetable,
  ) {
    switch (_workspaceActiveTab) {
      case 0: // Overview
        final classTeacherNames = classTeachers.map((ta) {
          final t = _schoolTeachers.firstWhere((t) => t.userId == ta.teacherId, orElse: () => UserModel(userId: ta.teacherId, schoolId: '', phone: '', email: '', name: 'Unassigned', role: 'teacher', status: 'active', createdAt: DateTime.now()));
          return t.name;
        }).join(', ');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('TOTAL STUDENTS', '${students.length}', Icons.people, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('CLASS TEACHER', classTeacherNames.isNotEmpty ? classTeacherNames : 'None Assigned', Icons.supervisor_account, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('SUBJECT TEACHERS MAPPED', '${subjectTeachers.length}', Icons.book, Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildVisualCard(
                'Class Activity Log',
                const Column(
                  children: [
                    Expanded(child: EduEmptyState(icon: Icons.history, title: 'Class updates clean', description: 'No classroom announcements logged.')),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1: // Students
        return _buildVisualCard(
          'Enrolled Student Roster',
          students.isEmpty
              ? const EduEmptyState(icon: Icons.people, title: 'No students enrolled', description: 'Admit students to this class section.')
              : Table(
                  border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        Padding(padding: EdgeInsets.all(12), child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('DOB', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('GENDER', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('BLOOD GROUP', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...students.map((s) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: const EdgeInsets.all(12), child: Text(s.dob)),
                        Padding(padding: const EdgeInsets.all(12), child: Text(s.gender.toUpperCase())),
                        Padding(padding: const EdgeInsets.all(12), child: Text(s.bloodGroup)),
                      ],
                    )),
                  ],
                ),
        );
      case 2: // Teachers
        return _buildVisualCard(
          'Faculty Assignments',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Class Coordinators', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (classTeachers.isEmpty) const Text('No class teacher configured.') else ...classTeachers.map((ta) {
                final t = _schoolTeachers.firstWhere((t) => t.userId == ta.teacherId, orElse: () => UserModel(userId: ta.teacherId, schoolId: '', phone: '', email: '', name: 'Unassigned', role: 'teacher', status: 'active', createdAt: DateTime.now()));
                return ListTile(title: Text(t.name), subtitle: const Text('Primary Coordinator'));
              }),
              const Divider(height: 32),
              const Text('Subject Teachers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (subjectTeachers.isEmpty) const Text('No subject teachers configured.') else ...subjectTeachers.map((ta) {
                final t = _schoolTeachers.firstWhere((t) => t.userId == ta.teacherId, orElse: () => UserModel(userId: ta.teacherId, schoolId: '', phone: '', email: '', name: 'Unassigned', role: 'teacher', status: 'active', createdAt: DateTime.now()));
                final sub = _subjectsList.firstWhere((s) => s.subjectId == ta.subjectId, orElse: () => SubjectModel(subjectId: '', schoolId: '', academicYearId: '', classId: '', name: 'General', code: '', createdAt: DateTime.now()));
                return ListTile(title: Text(t.name), subtitle: Text('Subject: ${sub.name}'));
              }),
            ],
          ),
        );
      case 3: // Timetable
        return _buildVisualCard(
          'Weekly Time Table schedule',
          timetable.isEmpty
              ? const EduEmptyState(icon: Icons.calendar_today, title: 'No slots registered', description: 'Manage slots in Timetables screen.')
              : Table(
                  border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        Padding(padding: EdgeInsets.all(12), child: Text('DAY', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('PERIOD', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('SUBJECT', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(12), child: Text('TIME RANGE', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...timetable.map((tt) {
                      final sub = _subjectsList.firstWhere((s) => s.subjectId == tt.subjectId, orElse: () => SubjectModel(subjectId: '', schoolId: '', academicYearId: '', classId: '', name: 'General', code: '', createdAt: DateTime.now()));
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(12), child: Text(tt.dayOfWeek.toUpperCase())),
                          Padding(padding: const EdgeInsets.all(12), child: Text('Period ${tt.periodNumber}')),
                          Padding(padding: const EdgeInsets.all(12), child: Text(sub.name)),
                          Padding(padding: const EdgeInsets.all(12), child: Text('${tt.startTime} - ${tt.endTime}')),
                        ],
                      );
                    }),
                  ],
                ),
        );
      case 4: // Exams & Marks (Report Card Flow)
        return _buildWorkspaceMarksView(students);
      case 5: // Fees Ledger (Fee Collection Flow)
        return _buildWorkspaceFeesView(students);
      default:
        return const Center(child: Text('Invalid View Tab'));
    }
  }

  Widget _buildWorkspaceMarksView(List<Student> students) {
    return _buildVisualCard(
      'Academic Exams & Grading cockpit',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Direct Marks Entry & Report Card Generation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Marks Entry Registry'),
            onPressed: () {
              // Quick dialog to add mock mark sheet entry
              showDialog(
                context: context,
                builder: (context) {
                  String? selStudentId;
                  String? selExamId;
                  String? selSubjectId;
                  final markCtrl = TextEditingController(text: '85');
                  
                  return AlertDialog(
                    title: const Text('Log Student Marks'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selStudentId,
                          items: students.map((s) => DropdownMenuItem(value: s.studentId, child: Text(s.name))).toList(),
                          onChanged: (val) => selStudentId = val,
                          decoration: const InputDecoration(labelText: 'Select Student'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selExamId,
                          items: _examsList.map((e) => DropdownMenuItem(value: e.examId, child: Text(e.name))).toList(),
                          onChanged: (val) => selExamId = val,
                          decoration: const InputDecoration(labelText: 'Select Exam'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selSubjectId,
                          items: _subjectsList.where((s) => s.classId == _workspaceClassId).map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.name))).toList(),
                          onChanged: (val) => selSubjectId = val,
                          decoration: const InputDecoration(labelText: 'Select Subject'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(controller: markCtrl, decoration: const InputDecoration(labelText: 'Marks Obtained (out of 100)'), keyboardType: TextInputType.number),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () async {
                          if (selStudentId == null || selExamId == null || selSubjectId == null) return;
                          Navigator.pop(context);
                          setState(() => _isLoading = true);
                          try {
                            final mId = _dbService.generateCustomId('MRK');
                            await FirebaseFirestore.instance.collection('marks').doc(mId).set({
                              'markId': mId,
                              'schoolId': widget.admin.schoolId,
                              'studentId': selStudentId,
                              'examId': selExamId,
                              'subjectId': selSubjectId,
                              'marksObtained': double.tryParse(markCtrl.text.trim()) ?? 0,
                              'totalMarks': 100,
                              'remarks': 'Class Workspace Entrance',
                            });
                            _showSuccess('Marks entry updated!');
                            await _loadAdminData();
                          } catch (e) {
                            _showWarning('Error: $e');
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: const Text('Save Marks'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('Student Report Cards & Performance Sheet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0)),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  Padding(padding: EdgeInsets.all(12), child: Text('STUDENT NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('EXAM', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('REPORT CARD ACTION', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              ...students.map((s) {
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    const Padding(padding: EdgeInsets.all(12), child: Text('UT-1 & Final Term Evaluation')),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.print, size: 14),
                        label: const Text('Generate & Print Report', style: TextStyle(fontSize: 12)),
                        onPressed: () => _printReportCard(s),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _printReportCard(Student s) async {
    // Generate Report card HTML and show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Print Preview: ${s.name} Report Card'),
        content: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VIDYALAYA PRIMARY SCHOOL - ACADEMIC REPORT CARD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB))),
              const Divider(height: 24),
              Text('STUDENT NAME: ${s.name}'),
              Text('STUDENT ID: ${s.studentId}'),
              Text('CLASS LEVEL: ${_classesList.firstWhere((c) => c.classId == _workspaceClassId).name}'),
              const SizedBox(height: 16),
              const Text('EXAMINATION EVALUATION SHEET (UT-1)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('English: 85/100'),
                  Text('Mathematics: 92/100'),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Telugu: 88/100'),
                  Text('Science: 90/100'),
                ],
              ),
              const Divider(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Aggregate Grade: A', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Status: Promoted to next stage'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Report card document sent to print pipeline!');
            },
            child: const Text('Print Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceFeesView(List<Student> students) {
    // Filter fee allocations for this section
    final sectionFees = _feeAssignmentsList.where((fa) => students.any((s) => s.studentId == fa.studentId)).toList();

    return _buildVisualCard(
      'Section Fee ledger',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fee Assignments, Invoices & Receipt collection panel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          if (sectionFees.isEmpty)
            const EduEmptyState(icon: Icons.account_balance_wallet, title: 'No fees mapped', description: 'Map fee structures to this section.')
          else
            Table(
              border: TableBorder.all(color: const Color(0xFFE2E8F0)),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                  children: [
                    Padding(padding: EdgeInsets.all(12), child: Text('STUDENT NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('NET BILLED', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('PAID AMOUNT', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('PAYMENT STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...sectionFees.map((fa) {
                  final student = _schoolStudents.firstWhere((s) => s.studentId == fa.studentId, orElse: () => Student(studentId: fa.studentId, schoolId: '', name: 'Unknown Student', dob: '', gender: '', bloodGroup: '', address: '', globalStatus: 'active', createdAt: DateTime.now()));
                  final isFullyPaid = fa.status == 'paid' || fa.amountPaid >= fa.netAmount;
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(12), child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: const EdgeInsets.all(12), child: Text('INR ${fa.netAmount}')),
                      Padding(padding: const EdgeInsets.all(12), child: Text('INR ${fa.amountPaid}')),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          fa.status.toUpperCase(),
                          style: TextStyle(color: isFullyPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isFullyPaid)
                              IconButton(
                                icon: const Icon(Icons.payment, color: Colors.blue, size: 18),
                                onPressed: () => _collectFeePayment(fa, student),
                                tooltip: 'Collect Payment',
                              ),
                            IconButton(
                              icon: const Icon(Icons.receipt, color: Colors.grey, size: 18),
                              onPressed: () => _printFeeReceipt(fa, student),
                              tooltip: 'Print Receipt',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  void _collectFeePayment(FeeAssignment fa, Student student) {
    final payCtrl = TextEditingController(text: '${fa.netAmount - fa.amountPaid}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Fee Payment: ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Outstanding Balance: INR ${fa.netAmount - fa.amountPaid}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: payCtrl,
              decoration: const InputDecoration(labelText: 'Amount to Pay (INR) *'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final amt = double.tryParse(payCtrl.text.trim()) ?? 0;
                final newPaid = fa.amountPaid + amt;
                final status = newPaid >= fa.netAmount ? 'paid' : 'partial';
                
                await FirebaseFirestore.instance.collection('fee_assignments').doc(fa.feeAssignmentId).update({
                  'amountPaid': newPaid,
                  'paymentStatus': status,
                });
                _showSuccess('Payment recorded! Processing receipt...');
                await _loadAdminData();
              } catch (e) {
                _showWarning('Error: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Submit Payment'),
          ),
        ],
      ),
    );
  }

  void _printFeeReceipt(FeeAssignment fa, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt Preview: ${student.name}'),
        content: Container(
          width: 450,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VIDYALAYA PRIMARY SCHOOL - FEE RECEIPT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981))),
              const Divider(height: 24),
              Text('STUDENT: ${student.name}'),
              Text('CLASS LEVEL: ${_classesList.firstWhere((c) => c.classId == _workspaceClassId).name}'),
              Text('INVOICE REF: ${fa.feeAssignmentId}'),
              const Divider(height: 24),
              Text('TOTAL BILLED: INR ${fa.netAmount}'),
              Text('TOTAL COLLECTED: INR ${fa.amountPaid}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('BALANCE DUE: INR ${fa.netAmount - fa.amountPaid}'),
              const Divider(height: 24),
              const Text('Payment Mode: Cash / Counter Collect', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Receipt sent to layout spooler!');
            },
            child: const Text('Spool Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _buildVisualCard(
            'Transfer & Lifecycle Registry',
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _transferSelectedStudentId,
                  items: _schoolStudents.map((s) => DropdownMenuItem(value: s.studentId, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _transferSelectedStudentId = val),
                  decoration: const InputDecoration(labelText: 'Select Student'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _transferSelectedStatus,
                  items: ['transferred', 'graduated', 'dropped', 'active']
                      .map((st) => DropdownMenuItem(value: st, child: Text(st.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => _transferSelectedStatus = val ?? 'transferred'),
                  decoration: const InputDecoration(labelText: 'Status Change'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _changeLifecycleStatus, child: const Text('Update Student Lifecycle')),
              ],
            ),
          ),
        ),
      ),
    );
  }

    void _showTeacherDetailDialog(UserModel t) {
    // Find active assignments
    final activeAsns = _teacherAssignmentsList.where((ta) => ta.teacherId == t.userId).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.school, color: EduTheme.colorPrimaryBrandTeal),
            const SizedBox(width: 10),
            Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialization: ${t.specialization ?? "Primary Core"}'),
            const SizedBox(height: 8),
            Text('Phone: ${t.phone}'),
            const SizedBox(height: 8),
            Text('Email: ${t.email}'),
            const SizedBox(height: 8),
            Text('Status: ${t.status.toUpperCase()}'),
            const Divider(height: 24),
            const Text('Active Classroom Assignments', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            activeAsns.isEmpty
                ? const Text('No teaching assignments currently mapped.')
                : SizedBox(
                    width: 300,
                    height: 120,
                    child: ListView.builder(
                      itemCount: activeAsns.length,
                      itemBuilder: (context, idx) {
                        final ta = activeAsns[idx];
                        final cls = _classesList.firstWhere((c) => c.classId == ta.classId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unknown Class', createdAt: DateTime.now()));
                        final sec = _sectionsList.firstWhere((s) => s.sectionId == ta.sectionId, orElse: () => SectionModel(sectionId: '', schoolId: '', classId: '', name: '', capacity: 30, createdAt: DateTime.now()));
                        final sub = ta.subjectId.isEmpty 
                            ? null 
                            : _subjectsList.firstWhere((s) => s.subjectId == ta.subjectId, orElse: () => SubjectModel(subjectId: '', schoolId: '', academicYearId: '', classId: '', name: 'Unknown Subject', code: '', createdAt: DateTime.now()));
                        
                        final roleText = ta.assignmentType == 'class_teacher' ? 'Class Teacher' : 'Teaches ${sub?.name ?? "Subject"}';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('• ${cls.name}-${sec.name}: $roleText'),
                        );
                      },
                    ),
                  ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showEditTeacherDialog(UserModel t) {
    final nameCtrl = TextEditingController(text: t.name);
    final phoneCtrl = TextEditingController(text: t.phone);
    final emailCtrl = TextEditingController(text: t.email);
    final specCtrl = TextEditingController(text: t.specialization ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Teacher Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 12),
            TextFormField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Core Specialization')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTeacherDoc(t.userId, nameCtrl.text.trim(), phoneCtrl.text.trim(), emailCtrl.text.trim(), specCtrl.text.trim());
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Faculty Roster',
              _schoolTeachers.isEmpty
                  ? const EduEmptyState(icon: Icons.supervisor_account, title: 'No onboarded teachers', description: 'Admit teachers on the right.')
                  : Table(
                      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.2),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                          children: [
                            Padding(padding: EdgeInsets.all(12), child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('SPECIALIZATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('CONTACT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                          ],
                        ),
                        ..._schoolTeachers.map((t) => TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(12), child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(12), child: Text(t.specialization ?? 'General')),
                                Padding(padding: const EdgeInsets.all(12), child: Text(t.phone)),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.blue, size: 18),
                                        onPressed: () => _showTeacherDetailDialog(t),
                                        tooltip: 'View Profile',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                                        onPressed: () => _showEditTeacherDialog(t),
                                        tooltip: 'Edit Profile',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Teacher Profile'),
                                              content: Text('Are you sure you want to delete ${t.name}? This will remove all associated class & subject teaching assignments.'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteTeacherDoc(t.userId);
                                                  },
                                                  child: const Text('Delete Profile'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        tooltip: 'Delete Teacher',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Onboard Faculty',
              Column(
                children: [
                  TextFormField(controller: _teacherNameController, decoration: const InputDecoration(labelText: 'Teacher Full Name')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _teacherPhoneController, decoration: const InputDecoration(labelText: 'Mobile Number'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextFormField(controller: _teacherEmailController, decoration: const InputDecoration(labelText: 'Email Address')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _teacherSpecController, decoration: const InputDecoration(labelText: 'Core Specialization')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _onboardTeacherDoc, child: const Text('Onboard Teacher')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    void _showEditAssignmentDialog(TeacherAssignment ta) {
    String? selTeacherId = ta.teacherId;
    String? selClassId = ta.classId.isEmpty ? null : ta.classId;
    String? selSecId = ta.sectionId.isEmpty ? null : ta.sectionId;
    String? selSubId = ta.subjectId.isEmpty ? null : ta.subjectId;
    String selType = ta.assignmentType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Teacher Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selTeacherId,
                  items: _schoolTeachers.map((t) => DropdownMenuItem(value: t.userId, child: Text(t.name))).toList(),
                  onChanged: (val) => setDialogState(() => selTeacherId = val),
                  decoration: const InputDecoration(labelText: 'Teacher'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selClassId,
                  items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                  onChanged: (val) => setDialogState(() => selClassId = val),
                  decoration: const InputDecoration(labelText: 'Class'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selSecId,
                  items: _sectionsList.map((s) => DropdownMenuItem(value: s.sectionId, child: Text(s.name))).toList(),
                  onChanged: (val) => setDialogState(() => selSecId = val),
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selSubId,
                  items: [
                    const DropdownMenuItem<String>(value: '', child: Text('None (Class Teacher)')),
                    ..._subjectsList.map((sub) => DropdownMenuItem(value: sub.subjectId, child: Text(sub.name))),
                  ],
                  onChanged: (val) => setDialogState(() => selSubId = val),
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selType,
                  items: ['class_teacher', 'subject_teacher']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' ').toUpperCase())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selType = val ?? 'subject_teacher'),
                  decoration: const InputDecoration(labelText: 'Assignment Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateAssignmentDoc(ta.assignmentId, selTeacherId ?? '', selType, selClassId ?? '', selSecId ?? '', selSubId ?? '');
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Classroom Teacher Mappings',
              _teacherAssignmentsList.isEmpty
                  ? const EduEmptyState(icon: Icons.assignment_ind, title: 'No assignments configured', description: 'Configure teacher maps.')
                  : Table(
                      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(1),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                          children: [
                            Padding(padding: EdgeInsets.all(12), child: Text('TEACHER NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('ROLE TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('CLASS & SECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('SUBJECT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                            Padding(padding: EdgeInsets.all(12), child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                          ],
                        ),
                        ..._teacherAssignmentsList.map((ta) {
                          final teacher = _schoolTeachers.firstWhere((t) => t.userId == ta.teacherId, orElse: () => UserModel(userId: ta.teacherId, schoolId: '', phone: '', email: '', name: 'Unassigned', role: 'teacher', status: 'active', createdAt: DateTime.now()));
                          final cls = _classesList.firstWhere((c) => c.classId == ta.classId, orElse: () => ClassModel(classId: '', schoolId: '', name: 'Unknown', createdAt: DateTime.now()));
                          final sec = _sectionsList.firstWhere((s) => s.sectionId == ta.sectionId, orElse: () => SectionModel(sectionId: '', schoolId: '', classId: '', name: '', capacity: 30, createdAt: DateTime.now()));
                          final sub = ta.subjectId.isEmpty 
                              ? null 
                              : _subjectsList.firstWhere((s) => s.subjectId == ta.subjectId, orElse: () => SubjectModel(subjectId: '', schoolId: '', academicYearId: '', classId: '', name: 'None', code: '', createdAt: DateTime.now()));
                          
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(12), child: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: const EdgeInsets.all(12), child: Text(ta.assignmentType.toUpperCase().replaceAll('_', ' '))),
                              Padding(padding: const EdgeInsets.all(12), child: Text('${cls.name} - ${sec.name}')),
                              Padding(padding: const EdgeInsets.all(12), child: Text(sub?.name ?? 'Class Coordinator')),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                                      onPressed: () => _showEditAssignmentDialog(ta),
                                      tooltip: 'Edit Assignment',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Remove Assignment'),
                                            content: Text('Are you sure you want to completely remove this assignment for ${teacher.name}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteAssignmentDoc(ta.assignmentId);
                                                },
                                                child: const Text('Remove Mapping'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      tooltip: 'Delete Assignment',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Teacher Assignment Wizard',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStepIndicator(0, 'Faculty', _teacherAssignWizardStep),
                      _buildStepLine(),
                      _buildStepIndicator(1, 'Target', _teacherAssignWizardStep),
                      _buildStepLine(),
                      _buildStepIndicator(2, 'Review', _teacherAssignWizardStep),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_teacherAssignWizardStep == 0) ...[
                    const Text('Step 1: Select Faculty & Role', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tWizardTeacherId,
                      items: _schoolTeachers.map((t) => DropdownMenuItem(value: t.userId, child: Text(t.name))).toList(),
                      onChanged: (val) => setState(() => _tWizardTeacherId = val),
                      decoration: const InputDecoration(labelText: 'Select Teacher *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tWizardType,
                      items: ['class_teacher', 'subject_teacher']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' ').toUpperCase())))
                          .toList(),
                      onChanged: (val) => setState(() => _tWizardType = val ?? 'subject_teacher'),
                      decoration: const InputDecoration(labelText: 'Role Assignment Type *'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_tWizardTeacherId == null) {
                              _showWarning('Please select a teacher.');
                              return;
                            }
                            setState(() => _teacherAssignWizardStep = 1);
                          },
                          child: const Text('Next: Choose Target'),
                        ),
                      ],
                    ),
                  ] else if (_teacherAssignWizardStep == 1) ...[
                    const Text('Step 2: Class, Section & Subject', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tWizardClassId,
                      items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                      onChanged: (val) => setState(() => _tWizardClassId = val),
                      decoration: const InputDecoration(labelText: 'Select Class *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tWizardSectionId,
                      items: _sectionsList
                          .where((s) => s.classId == _tWizardClassId)
                          .map((s) => DropdownMenuItem(value: s.sectionId, child: Text(s.name)))
                          .toList(),
                      onChanged: (val) => setState(() => _tWizardSectionId = val),
                      decoration: const InputDecoration(labelText: 'Select Section *'),
                    ),
                    const SizedBox(height: 12),
                    if (_tWizardType == 'subject_teacher') ...[
                      DropdownButtonFormField<String>(
                        value: _tWizardSubjectId,
                        items: [
                          const DropdownMenuItem<String>(value: '', child: Text('None (Select Subject)')),
                          ..._subjectsList
                              .where((sub) => sub.classId == _tWizardClassId)
                              .map((sub) => DropdownMenuItem(value: sub.subjectId, child: Text(sub.name))),
                        ],
                        onChanged: (val) => setState(() => _tWizardSubjectId = val),
                        decoration: const InputDecoration(labelText: 'Select Subject *'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => setState(() => _teacherAssignWizardStep = 0), child: const Text('Back')),
                        ElevatedButton(
                          onPressed: () {
                            if (_tWizardClassId == null || _tWizardSectionId == null) {
                              _showWarning('Please specify Class and Section.');
                              return;
                            }
                            if (_tWizardType == 'subject_teacher' && (_tWizardSubjectId == null || _tWizardSubjectId!.isEmpty)) {
                              _showWarning('Please select a subject for subject teacher assignment.');
                              return;
                            }
                            setState(() => _teacherAssignWizardStep = 2);
                          },
                          child: const Text('Next: Review Mapping'),
                        ),
                      ],
                    ),
                  ] else if (_teacherAssignWizardStep == 2) ...[
                    const Text('Step 3: Review & Confirm Assignment', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildReviewRow('Teacher', _schoolTeachers.firstWhere((t) => t.userId == _tWizardTeacherId).name),
                    _buildReviewRow('Role Type', _tWizardType.toUpperCase().replaceAll('_', ' ')),
                    _buildReviewRow('Class & Section', '${_classesList.firstWhere((c) => c.classId == _tWizardClassId).name} - ${_sectionsList.firstWhere((s) => s.sectionId == _tWizardSectionId).name}'),
                    if (_tWizardType == 'subject_teacher')
                      _buildReviewRow('Subject', _subjectsList.firstWhere((s) => s.subjectId == _tWizardSubjectId, orElse: () => SubjectModel(subjectId: '', schoolId: '', academicYearId: '', classId: '', name: 'General Activities', code: '', createdAt: DateTime.now())).name),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => setState(() => _teacherAssignWizardStep = 1), child: const Text('Back')),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            final assignId = _dbService.generateCustomId('ASN');
                            final activeYear = _academicYearsList.isNotEmpty ? _academicYearsList.first.academicYearId : 'AY2026';
                            try {
                              await FirebaseFirestore.instance.collection('teacher_assignments').doc(assignId).set({
                                'assignmentId': assignId,
                                'schoolId': widget.admin.schoolId,
                                'teacherId': _tWizardTeacherId,
                                'academicYearId': activeYear,
                                'classId': _tWizardClassId,
                                'sectionId': _tWizardSectionId,
                                'subjectId': _tWizardType == 'class_teacher' ? '' : (_tWizardSubjectId ?? ''),
                                'assignmentType': _tWizardType,
                              });

                              // Reset wizard
                              setState(() {
                                _teacherAssignWizardStep = 0;
                                _tWizardTeacherId = null;
                                _tWizardClassId = null;
                                _tWizardSectionId = null;
                                _tWizardSubjectId = null;
                              });

                              _showSuccess('Teacher assignment configured successfully!');
                              await _loadAdminData();
                            } catch (e) {
                              _showWarning('Error: $e');
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          child: const Text('Confirm Mapping'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeStructuresView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Fee Structure Catalog',
              _feeStructuresList.isEmpty
                  ? const EduEmptyState(icon: Icons.payments, title: 'No active fee structures', description: 'Add fee allocations.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _feeStructuresList.length,
                      separatorBuilder: (c, i) => const Divider(height: 24),
                      itemBuilder: (context, idx) {
                        final fs = _feeStructuresList[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(fs.title, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                          subtitle: Text('Billed Amount: ₹${fs.amount.toStringAsFixed(2)}'),
                          trailing: Text('Due: ${_formatDate(fs.dueDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Configure Fees Structure',
              Column(
                children: [
                  TextFormField(controller: _feeTitleController, decoration: const InputDecoration(labelText: 'Account Billing Title')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _feeAmountController, decoration: const InputDecoration(labelText: 'Billing Amount (INR)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextFormField(controller: _feeDueDateController, decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _createFeeStructure, child: const Text('Save Structure')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeAssignmentsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildVisualCard(
            'School-Wide Fee Allocations',
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _feeAllocStructureId,
                  items: _feeStructuresList.map((fs) => DropdownMenuItem(value: fs.feeStructureId, child: Text(fs.title))).toList(),
                  onChanged: (val) => setState(() => _feeAllocStructureId = val),
                  decoration: const InputDecoration(labelText: 'Select Billing Structure'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _feeAllocClassId,
                  items: _classesList.map((c) => DropdownMenuItem(value: c.classId, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _feeAllocClassId = val),
                  decoration: const InputDecoration(labelText: 'Target Grade Class'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _feeAllocSectionId,
                  items: _sectionsList.map((s) => DropdownMenuItem(value: s.sectionId, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _feeAllocSectionId = val),
                  decoration: const InputDecoration(labelText: 'Target Section'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _allocateFeeBulk, child: const Text('Allocate Fee Structure')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Column(
        children: [
          _buildVisualCard(
            'Billing & Transaction Logs',
            _feeAssignmentsList.isEmpty
                ? const EduEmptyState(icon: Icons.receipt_long, title: 'No pending payments log', description: 'Run allocations to bill profiles.')
                : Table(
                    border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: EdgeInsets.all(12), child: Text('STUDENT ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                          Padding(padding: EdgeInsets.all(12), child: Text('FEE TITLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                          Padding(padding: EdgeInsets.all(12), child: Text('NET AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                          Padding(padding: EdgeInsets.all(12), child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                        ],
                      ),
                      ..._feeAssignmentsList.map((fa) => TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(12), child: Text(fa.studentId)),
                              Padding(padding: const EdgeInsets.all(12), child: Text(fa.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: const EdgeInsets.all(12), child: Text('₹${fa.netAmount}')),
                               Padding(padding: const EdgeInsets.all(12), child: _buildStatusBadge(fa.status)),
                            ],
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildVisualCard(
              'Dispatched School Notices',
              _announcementsList.isEmpty
                  ? const EduEmptyState(icon: Icons.campaign, title: 'No notices dispatched', description: 'Draft one on the right.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _announcementsList.length,
                      separatorBuilder: (c, i) => const Divider(height: 24),
                      itemBuilder: (context, idx) {
                        final anc = _announcementsList[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(anc.title, style: const TextStyle(fontWeight: FontWeight.bold, color: EduTheme.colorTextDark)),
                          subtitle: Text(anc.body),
                           trailing: _buildStatusBadge(anc.scope),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildVisualCard(
              'Dispatch Announcement',
              Column(
                children: [
                  TextFormField(controller: _announcementTitleController, decoration: const InputDecoration(labelText: 'Notice Title')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _announcementBodyController, decoration: const InputDecoration(labelText: 'Body Content'), maxLines: 4),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _announcementScope,
                    items: ['school', 'class', 'section']
                        .map((scope) => DropdownMenuItem(value: scope, child: Text(scope.toUpperCase())))
                        .toList(),
                    onChanged: (val) => setState(() => _announcementScope = val ?? 'school'),
                    decoration: const InputDecoration(labelText: 'Notice Scope Target'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _postAnnouncement, child: const Text('Dispatch notice')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomUpdatesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: _buildVisualCard(
        'Faculty Classroom Logs Feed',
        _classroomUpdatesList.isEmpty
            ? const EduEmptyState(icon: Icons.history, title: 'No logs recorded', description: 'Roster is current.')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classroomUpdatesList.length,
                separatorBuilder: (c, i) => const Divider(height: 24),
                itemBuilder: (context, idx) {
                  final log = _classroomUpdatesList[idx];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(log.topicCovered, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Homework: ${log.homework}'),
                    trailing: Text('Section: ${log.sectionId}'),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAttendanceReportsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: _buildVisualCard(
        'Daily Student Attendance Metrics',
        const EduEmptyState(icon: Icons.fact_check, title: 'No attendance records logged', description: 'Academic registers are clean.'),
      ),
    );
  }

  Widget _buildFeeReportsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: _buildVisualCard(
        'Financial Collections Audit',
        const EduEmptyState(icon: Icons.account_balance_wallet, title: 'No financial transactions logged', description: 'Receipt catalog is clean.'),
      ),
    );
  }

  Widget _buildSchoolProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildVisualCard(
            'School Administrative Profile',
            Column(
              children: [
                TextFormField(controller: _schoolNameController, decoration: const InputDecoration(labelText: 'Institution Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _schoolBoardController, decoration: const InputDecoration(labelText: 'Affiliation Board Code')),
                const SizedBox(height: 12),
                TextFormField(controller: _schoolAddressController, decoration: const InputDecoration(labelText: 'Physical Campus Address')),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _updateSchoolProfile, child: const Text('Update Profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicConfigView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EduTheme.space32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildVisualCard(
            'Operational School Settings',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configure institutional operation hours, duration parameters, and schedule configurations.', style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _settingsStartTimeController,
                  decoration: const InputDecoration(labelText: 'School Start Time (HH:MM, e.g. 08:00) *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _settingsEndTimeController,
                  decoration: const InputDecoration(labelText: 'School Dismissal Time (HH:MM, e.g. 14:30) *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _settingsPeriodDurationController,
                  decoration: const InputDecoration(labelText: 'Class Period Duration (Minutes, e.g. 45) *'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _settingsLunchStartController,
                        decoration: const InputDecoration(labelText: 'Lunch Break Start Time (HH:MM) *'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _settingsLunchDurationController,
                        decoration: const InputDecoration(labelText: 'Lunch Break Duration (Minutes) *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Academic Working Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].map((day) {
                    final isWorking = _settingsWorkingDays.contains(day);
                    return FilterChip(
                      selected: isWorking,
                      label: Text(day.toUpperCase().substring(0, 3)),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _settingsWorkingDays.add(day);
                          } else {
                            _settingsWorkingDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        try {
                          await FirebaseFirestore.instance.collection('schools').doc(widget.admin.schoolId).update({
                            'startTime': _settingsStartTimeController.text.trim(),
                            'endTime': _settingsEndTimeController.text.trim(),
                            'periodDuration': int.tryParse(_settingsPeriodDurationController.text.trim()) ?? 45,
                            'lunchBreakStart': _settingsLunchStartController.text.trim(),
                            'lunchBreakDuration': int.tryParse(_settingsLunchDurationController.text.trim()) ?? 30,
                            'workingDays': _settingsWorkingDays,
                          });
                          _showSuccess('School settings saved to database!');
                          await _loadSchoolProfile();
                        } catch (e) {
                          _showWarning('Error: $e');
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('Save School Configurations'),
                    ),
                    OutlinedButton(
                      onPressed: _loadAdminData,
                      child: const Text('Force Fetch Sync'),
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

  Widget _buildSidebarItem(IconData icon, String title, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: active ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget pageBody;
    switch (_currentRoute) {
      case 'dashboard':
        pageBody = _buildDashboardHome();
        break;
      case 'academic_years':
        pageBody = _buildAcademicYearsView();
        break;
      case 'classes_sections':
        pageBody = _buildClassesSectionsView();
        break;
      case 'subjects':
        pageBody = _buildSubjectsView();
        break;
      case 'timetables':
        pageBody = _buildTimetablesView();
        break;
      case 'exams':
        pageBody = _buildExamsView();
        break;
      case 'students':
        pageBody = _buildStudentsView();
        break;
      case 'admissions':
        pageBody = _buildAdmissionsView();
        break;
      case 'parent_linker':
        pageBody = _buildParentLinkerWizard();
        break;
      case 'promotions':
        pageBody = _buildPromotionsView();
        break;
      case 'transfers':
        pageBody = _buildTransfersView();
        break;
      case 'teachers':
        pageBody = _buildTeachersView();
        break;
      case 'assignments':
        pageBody = _buildAssignmentsView();
        break;
      case 'fee_structures':
        pageBody = _buildFeeStructuresView();
        break;
      case 'fee_assignments':
        pageBody = _buildFeeAssignmentsView();
        break;
      case 'payments':
        pageBody = _buildPaymentsView();
        break;
      case 'announcements':
        pageBody = _buildAnnouncementsView();
        break;
      case 'classroom_updates':
        pageBody = _buildClassroomUpdatesView();
        break;
      case 'attendance_reports':
        pageBody = _buildAttendanceReportsView();
        break;
      case 'fee_reports':
        pageBody = _buildFeeReportsView();
        break;
      case 'school_profile':
        pageBody = _buildSchoolProfileView();
        break;
      case 'academic_config':
        pageBody = _buildAcademicConfigView();
        break;
      default:
        pageBody = const Center(child: Text('Routing mismatch. Please contact portal administrator.'));
    }

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _schoolNameController.text.isNotEmpty ? _schoolNameController.text : 'EduAssist',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Text(
                            'Operations Console',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _sidebarStructure.map((section) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                section['title'].toUpperCase(),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0),
                              ),
                            ),
                            ... (section['items'] as List<Map<String, dynamic>>).map((item) {
                              final route = item['route'] as String;
                              return _buildSidebarItem(
                                item['icon'] as IconData,
                                item['label'] as String,
                                _currentRoute == route,
                                () => setState(() => _currentRoute = route),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
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
                      : pageBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}