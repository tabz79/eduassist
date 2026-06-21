import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduassist_app/services/models.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER METRICS & PROFILES ---

  /// Retrieves a user profile by user ID (auth UID)
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  /// Looks up a user by phone number
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final query = await _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print("Error looking up user by phone: $e");
      return null;
    }
  }

  // --- STUDENTS ---

  /// Gets students linked to a specific parent
  Future<List<Student>> getStudentsForParent(String parentId) async {
    try {
      final query = await _db
          .collection('students')
          .where('parentId', isEqualTo: parentId)
          .get();
      return query.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting parent students: $e");
      return [];
    }
  }

  /// Gets all students in a school for a specific class (Teacher/Admin view)
  Future<List<Student>> getStudentsInClass(String schoolId, String className) async {
    try {
      final query = await _db
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .where('class', isEqualTo: className)
          .get();
      return query.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting class students: $e");
      return [];
    }
  }

  // --- FEES ---

  /// Retrieves fee history & pending items for a student
  Future<List<FeeRecord>> getStudentFees(String studentId) async {
    try {
      final query = await _db
          .collection('fees')
          .where('studentId', isEqualTo: studentId)
          .get();
      final list = query.docs.map((doc) => FeeRecord.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.dueDate.compareTo(a.dueDate)); // Sort descending in memory
      return list;
    } catch (e) {
      print("Error getting student fees: $e");
      return [];
    }
  }

  /// Records a fee payment (marking a fee as paid)
  Future<bool> recordFeePayment(String feeId, String userId, String schoolId, String studentId, String receiptNo) async {
    try {
      await _db.collection('fees').doc(feeId).update({
        'status': 'paid',
        'paidDate': DateTime.now(),
        'receiptNo': receiptNo,
      });

      await logAction(
        action: 'PAY_FEE',
        userId: userId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'fees',
        status: 'success',
      );
      return true;
    } catch (e) {
      print("Error recording fee payment: $e");
      await logAction(
        action: 'PAY_FEE',
        userId: userId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'fees',
        status: 'error',
        errorCode: e.toString(),
      );
      return false;
    }
  }

  // --- ATTENDANCE ---

  /// Retrieves attendance history for a student
  Future<List<AttendanceRecord>> getStudentAttendance(String studentId) async {
    try {
      final query = await _db
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();
      final list = query.docs.map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.date.compareTo(a.date)); // Sort descending in memory
      return list;
    } catch (e) {
      print("Error getting student attendance: $e");
      return [];
    }
  }

  /// Saves or updates attendance for a student on a specific date
  Future<bool> markAttendance({
    required String studentId,
    required String schoolId,
    required String date, // YYYY-MM-DD
    required String status, // 'present' | 'absent'
    required String teacherId,
  }) async {
    final docId = "${studentId}_$date";
    try {
      await _db.collection('attendance').doc(docId).set({
        'studentId': studentId,
        'schoolId': schoolId,
        'date': date,
        'status': status,
        'markedBy': teacherId,
        'markedAt': DateTime.now(),
      });

      await logAction(
        action: 'MARK_ATTENDANCE',
        userId: teacherId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'attendance',
        status: 'success',
      );
      return true;
    } catch (e) {
      print("Error marking attendance: $e");
      await logAction(
        action: 'MARK_ATTENDANCE',
        userId: teacherId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'attendance',
        status: 'error',
        errorCode: e.toString(),
      );
      return false;
    }
  }

  // --- MARKS & REPORT CARDS ---

  /// Retrieves marks for a student (to display dynamically on report card)
  Future<List<MarkRecord>> getStudentMarks(String studentId) async {
    try {
      final query = await _db
          .collection('marks')
          .where('studentId', isEqualTo: studentId)
          .get();
      return query.docs.map((doc) => MarkRecord.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting student marks: $e");
      return [];
    }
  }

  /// Adds a single mark record for a student
  Future<bool> inputMarks({
    required String studentId,
    required String schoolId,
    required String subject,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    required String grade,
    required String teacherId,
  }) async {
    try {
      await _db.collection('marks').add({
        'studentId': studentId,
        'schoolId': schoolId,
        'subject': subject,
        'examName': examName,
        'marksObtained': marksObtained,
        'maxMarks': maxMarks,
        'grade': grade,
        'teacherId': teacherId,
        'markedAt': DateTime.now(),
      });

      await logAction(
        action: 'INPUT_MARKS',
        userId: teacherId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'marks',
        status: 'success',
      );
      return true;
    } catch (e) {
      print("Error entering marks: $e");
      await logAction(
        action: 'INPUT_MARKS',
        userId: teacherId,
        schoolId: schoolId,
        studentId: studentId,
        module: 'marks',
        status: 'error',
        errorCode: e.toString(),
      );
      return false;
    }
  }

  // --- LOGGING ---

  /// Logs system and security actions
  Future<void> logAction({
    required String action,
    required String userId,
    required String schoolId,
    String? studentId,
    required String module,
    required String status,
    String? errorCode,
  }) async {
    try {
      await _db.collection('logs').add({
        'action': action,
        'userId': userId,
        'studentId': studentId,
        'schoolId': schoolId,
        'timestamp': DateTime.now(),
        'module': module,
        'status': status,
        'errorCode': errorCode,
      });
    } catch (e) {
      print("Error writing to logs collection: $e");
    }
  }

  // --- FOUNDATION UTILITIES (PHASE 0) ---

  /// Generates a random structured ID with given prefix (e.g. STUxxxxx)
  String generateCustomId(String prefix) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer(prefix);
    for (int i = 0; i < 5; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  // --- ENROLLMENTS & CLASSROOM UPDATES (PHASE 1A) ---

  /// Retrieves enrollments for a class
  Future<List<Enrollment>> getEnrollmentsForClass(String schoolId, String className) async {
    try {
      final query = await _db
          .collection('enrollments')
          .where('schoolId', isEqualTo: schoolId)
          .where('class', isEqualTo: className)
          .get();
      return query.docs.map((doc) => Enrollment.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting enrollments: $e");
      return [];
    }
  }

  /// Get student details for specific list of student IDs
  Future<List<Student>> getStudentsByIds(String schoolId, List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    try {
      final query = await _db
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      final allStudents = query.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
      return allStudents.where((s) => studentIds.contains(s.id)).toList();
    } catch (e) {
      print("Error fetching students by ids: $e");
      return [];
    }
  }

  /// Posts a classroom update
  Future<bool> postClassroomUpdate({
    required String schoolId,
    required String teacherId,
    required String className,
    required String section,
    required String subject,
    required String chapter,
    required String topicCovered,
    required String homework,
    String? photoUrl,
  }) async {
    try {
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      await _db.collection('classroom_updates').add({
        'schoolId': schoolId,
        'teacherId': teacherId,
        'class': className,
        'section': section,
        'subject': subject,
        'chapter': chapter,
        'topicCovered': topicCovered,
        'homework': homework,
        'photoUrl': photoUrl,
        'date': dateStr,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error posting classroom update: $e");
      return false;
    }
  }

  /// Gets classroom updates for a child's class and section
  Future<List<ClassroomUpdate>> getClassroomUpdates(String schoolId, String className) async {
    try {
      final query = await _db
          .collection('classroom_updates')
          .where('schoolId', isEqualTo: schoolId)
          .where('class', isEqualTo: className)
          .get();
      final list = query.docs.map((doc) => ClassroomUpdate.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort in memory
      return list;
    } catch (e) {
      print("Error fetching classroom updates: $e");
      return [];
    }
  }

  // --- TESTS & EXAMS (PHASE 1B) ---

  /// Creates a test configuration
  Future<bool> createTestConfig({
    required String schoolId,
    required String className,
    required String subject,
    required String testName,
    required double maxMarks,
    required String date,
  }) async {
    try {
      await _db.collection('tests').add({
        'schoolId': schoolId,
        'class': className,
        'subject': subject,
        'testName': testName,
        'maxMarks': maxMarks,
        'date': date,
      });
      return true;
    } catch (e) {
      print("Error creating test config: $e");
      return false;
    }
  }

  /// Retrieves tests for a class
  Future<List<TestConfig>> getTestsForClass(String schoolId, String className) async {
    try {
      final query = await _db
          .collection('tests')
          .where('schoolId', isEqualTo: schoolId)
          .where('class', isEqualTo: className)
          .get();
      return query.docs.map((doc) => TestConfig.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting tests for class: $e");
      return [];
    }
  }
}
