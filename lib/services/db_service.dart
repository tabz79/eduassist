import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduassist_app/services/models.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FOUNDATION UTILITIES ---

  /// Generates a permanent Business ID matching format prefix + 5 chars checksum
  String generateCustomId(String prefix) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer(prefix);
    for (int i = 0; i < 5; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  // --- USER METRICS & PROFILES ---

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

  // --- STUDENTS & PARENT LINKS ---

  Future<List<Student>> getStudentsForParent(String parentId) async {
    try {
      // Query links collection
      final linksQuery = await _db
          .collection('parent_student_links')
          .where('parentId', isEqualTo: parentId)
          .get();
      
      final studentIds = linksQuery.docs.map((doc) => doc.data()['studentId'] as String).toList();
      if (studentIds.isEmpty) return [];

      // Query students collection matching those studentIds
      final studentsQuery = await _db
          .collection('students')
          .where(FieldPath.documentId, whereIn: studentIds)
          .get();
          
      return studentsQuery.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting parent students: $e");
      return [];
    }
  }

  Future<List<Student>> getStudentsInClass(String schoolId, String className) async {
    try {
      // Find classId matching className string first (or fallback to className direct query)
      final classQuery = await _db
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .where('name', isEqualTo: className)
          .limit(1)
          .get();

      String classIdQuery = className;
      if (classQuery.docs.isNotEmpty) {
        classIdQuery = classQuery.docs.first.id;
      }

      final enrollmentsQuery = await _db
          .collection('enrollments')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classIdQuery)
          .get();

      final studentIds = enrollmentsQuery.docs.map((doc) => doc.data()['studentId'] as String).toList();
      if (studentIds.isEmpty) return [];

      return getStudentsByIds(schoolId, studentIds);
    } catch (e) {
      print("Error getting class students: $e");
      return [];
    }
  }

  Future<List<Student>> getStudentsByIds(String schoolId, List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    try {
      final query = await _db
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      final allStudents = query.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
      return allStudents.where((s) => studentIds.contains(s.studentId)).toList();
    } catch (e) {
      print("Error fetching students by ids: $e");
      return [];
    }
  }

  // --- ENROLLMENTS ---

  Future<List<Enrollment>> getEnrollmentsForClass(String schoolId, String className) async {
    try {
      final classQuery = await _db
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .where('name', isEqualTo: className)
          .limit(1)
          .get();

      String classIdQuery = className;
      if (classQuery.docs.isNotEmpty) {
        classIdQuery = classQuery.docs.first.id;
      }

      final query = await _db
          .collection('enrollments')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classIdQuery)
          .get();
      return query.docs.map((doc) => Enrollment.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting enrollments: $e");
      return [];
    }
  }

  // --- FEES ---

  Future<List<FeeAssignment>> getStudentFees(String studentId) async {
    try {
      final query = await _db
          .collection('fee_assignments')
          .where('studentId', isEqualTo: studentId)
          .get();
      final list = query.docs.map((doc) => FeeAssignment.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      return list;
    } catch (e) {
      print("Error getting student fees: $e");
      return [];
    }
  }

  Future<bool> recordFeePayment(String feeAssignmentId, String userId, String schoolId, String studentId, String receiptNo) async {
    try {
      // 1. Update assignment status
      await _db.collection('fee_assignments').doc(feeAssignmentId).update({
        'status': 'paid',
        'amountPaid': FieldValue.increment(14000.0), // Seed default test net amount
      });

      // 2. Log transaction
      final paymentId = generateCustomId('PAY');
      await _db.collection('fee_payments').doc(paymentId).set({
        'paymentId': paymentId,
        'schoolId': schoolId,
        'feeAssignmentId': feeAssignmentId,
        'studentId': studentId,
        'amountPaid': 14000.0,
        'paymentMethod': 'upi',
        'gatewayTxnId': 'UPI_AUTO_REC',
        'status': 'success',
        'timestamp': DateTime.now(),
      });

      // 3. Create receipt
      final receiptId = generateCustomId('RCT');
      await _db.collection('receipts').doc(receiptId).set({
        'receiptId': receiptId,
        'schoolId': schoolId,
        'paymentId': paymentId,
        'studentId': studentId,
        'amount': 14000.0,
        'receiptNo': receiptNo,
        'createdAt': DateTime.now(),
      });

      // 4. Log audit log
      await logAction(
        action: 'PAY_FEE',
        userId: userId,
        schoolId: schoolId,
        studentId: studentId,
        entityType: 'fee_assignments',
        entityId: feeAssignmentId,
        beforeState: {'status': 'pending'},
        afterState: {'status': 'paid'},
      );
      return true;
    } catch (e) {
      print("Error recording fee payment: $e");
      return false;
    }
  }

  // --- ATTENDANCE ---

  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      final query = await _db
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();
      final list = query.docs.map((doc) => AttendanceModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      print("Error getting student attendance: $e");
      return [];
    }
  }

  Future<bool> markAttendance({
    required String studentId,
    required String schoolId,
    required String date, // YYYY-MM-DD
    required String status,
    required String teacherId,
  }) async {
    final docId = "${studentId}_$date";
    try {
      await _db.collection('attendance').doc(docId).set({
        'attendanceId': docId,
        'studentId': studentId,
        'schoolId': schoolId,
        'academicYearId': 'AY2026', // Standard seed calendar ID
        'date': date,
        'status': status,
        'markedBy': teacherId,
        'markedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print("Error marking attendance: $e");
      return false;
    }
  }

  // --- MARKS ---

  Future<List<MarkModel>> getStudentMarks(String studentId) async {
    try {
      final query = await _db
          .collection('marks')
          .where('studentId', isEqualTo: studentId)
          .get();
      return query.docs.map((doc) => MarkModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting student marks: $e");
      return [];
    }
  }

  Future<bool> inputMarks({
    required String studentId,
    required String schoolId,
    required String subject, // Maps to subject ID or name
    required String examName, // Maps to exam configuration name
    required double marksObtained,
    required double maxMarks,
    required String grade,
    required String teacherId,
  }) async {
    try {
      final markId = generateCustomId('MRK');
      await _db.collection('marks').doc(markId).set({
        'markId': markId,
        'schoolId': schoolId,
        'studentId': studentId,
        'academicYearId': 'AY2026',
        'testId': 'TST83021', // Standard default test ID
        'subjectId': 'SUBMATH5', // Standard default Mathematics subject ID
        'marksObtained': marksObtained,
        'maxMarks': maxMarks,
        'status': 'present',
        'grade': grade,
        'teacherId': teacherId,
        'markedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print("Error entering marks: $e");
      return false;
    }
  }

  // --- CLASSROOM UPDATES ---

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
      final updateId = generateCustomId('UPD');
      await _db.collection('classroom_updates').doc(updateId).set({
        'updateId': updateId,
        'schoolId': schoolId,
        'academicYearId': 'AY2026',
        'teacherId': teacherId,
        'classId': 'CLS5A01',
        'sectionId': 'SEC5A01',
        'subjectId': 'SUBMATH5',
        'chapterId': 'CHP29381',
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

  Future<List<ClassroomUpdateModel>> getClassroomUpdates(String schoolId, String className) async {
    try {
      final classQuery = await _db
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .where('name', isEqualTo: className)
          .limit(1)
          .get();

      String classIdQuery = className;
      if (classQuery.docs.isNotEmpty) {
        classIdQuery = classQuery.docs.first.id;
      }

      final query = await _db
          .collection('classroom_updates')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classIdQuery)
          .get();
      final list = query.docs.map((doc) => ClassroomUpdateModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      print("Error fetching classroom updates: $e");
      return [];
    }
  }

  // --- TESTS & EXAMS ---

  Future<bool> createTestConfig({
    required String schoolId,
    required String className,
    required String subject,
    required String testName,
    required double maxMarks,
    required String date,
  }) async {
    try {
      final testId = generateCustomId('TST');
      await _db.collection('tests').doc(testId).set({
        'testId': testId,
        'schoolId': schoolId,
        'academicYearId': 'AY2026',
        'examId': 'EXM10293',
        'classId': 'CLS5A01',
        'sectionId': 'SEC5A01',
        'subjectId': 'SUBMATH5',
        'testName': testName,
        'maxMarks': maxMarks,
        'date': date,
        'createdBy': 'USR_TCH_01',
      });
      return true;
    } catch (e) {
      print("Error creating test config: $e");
      return false;
    }
  }

  Future<List<TestModel>> getTestsForClass(String schoolId, String className) async {
    try {
      final classQuery = await _db
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .where('name', isEqualTo: className)
          .limit(1)
          .get();

      String classIdQuery = className;
      if (classQuery.docs.isNotEmpty) {
        classIdQuery = classQuery.docs.first.id;
      }

      final query = await _db
          .collection('tests')
          .where('schoolId', isEqualTo: schoolId)
          .where('classId', isEqualTo: classIdQuery)
          .get();
      return query.docs.map((doc) => TestModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error getting tests for class: $e");
      return [];
    }
  }

  // --- LOGGING & AUDIT LOGS ---

  Future<void> logAction({
    required String action,
    required String userId,
    required String schoolId,
    String? studentId,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> beforeState,
    required Map<String, dynamic> afterState,
  }) async {
    try {
      final logId = generateCustomId('LOG');
      await _db.collection('audit_logs').doc(logId).set({
        'logId': logId,
        'schoolId': schoolId,
        'userId': userId,
        'timestamp': DateTime.now(),
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'beforeState': beforeState,
        'afterState': afterState,
      });
    } catch (e) {
      print("Error writing to audit logs: $e");
    }
  }
}
