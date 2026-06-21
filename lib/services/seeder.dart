import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    print("DatabaseSeeder: Starting database seeding...");

    // 1. Seed School
    final schoolId = "school_1";
    try {
      print("DatabaseSeeder: Seeding schools...");
      await _db.collection('schools').doc(schoolId).set({
        'name': 'Indo English High School',
        'ownerId': 'admin_1',
        'createdAt': DateTime.now(),
      });
      print("DatabaseSeeder: Seeded school successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding school: $e");
      throw Exception("Schools seed failed: $e");
    }

    // 2. Seed Users
    try {
      print("DatabaseSeeder: Seeding users...");
      final List<Map<String, dynamic>> users = [
        {
          'id': 'admin_1',
          'name': 'Principal Rajesh Sharma',
          'phone': '+91 9999911111',
          'role': 'admin',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
        {
          'id': 'teacher_1',
          'name': 'Mrs. Priya Patel',
          'phone': '+91 9999922221',
          'role': 'teacher',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
        {
          'id': 'teacher_2',
          'name': 'Mr. Amit Verma',
          'phone': '+91 9999922222',
          'role': 'teacher',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
        {
          'id': 'teacher_3',
          'name': 'Mrs. Sunita Rao',
          'phone': '+91 9999922223',
          'role': 'teacher',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
        {
          'id': 'parent_1',
          'name': 'Ramesh Kumar',
          'phone': '+91 9876543210',
          'role': 'parent',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
        {
          'id': 'parent_2',
          'name': 'Kavita Sharma',
          'phone': '+91 9876543211',
          'role': 'parent',
          'schoolId': schoolId,
          'createdAt': DateTime.now(),
        },
      ];

      for (var u in users) {
        final uid = u['id'];
        final data = Map<String, dynamic>.from(u)..remove('id');
        await _db.collection('users').doc(uid).set(data);
      }
      print("DatabaseSeeder: Seeded users successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding users: $e");
      throw Exception("Users seed failed: $e");
    }

    // 3. Seed Students
    try {
      print("DatabaseSeeder: Seeding students...");
      final List<Map<String, dynamic>> students = [
        {
          'id': 'student_1',
          'name': 'Aarav Kumar',
          'class': 'Grade 4',
          'parentId': 'parent_1',
          'schoolId': schoolId,
        },
        {
          'id': 'student_2',
          'name': 'Diya Kumar',
          'class': 'Grade 2',
          'parentId': 'parent_1',
          'schoolId': schoolId,
        },
        {
          'id': 'student_3',
          'name': 'Ira Kumar',
          'class': 'Nursery',
          'parentId': 'parent_1',
          'schoolId': schoolId,
        },
        {
          'id': 'student_4',
          'name': 'Kabir Sharma',
          'class': 'Grade 4',
          'parentId': 'parent_2',
          'schoolId': schoolId,
        },
      ];

      for (var s in students) {
        final sid = s['id'];
        final data = Map<String, dynamic>.from(s)..remove('id');
        await _db.collection('students').doc(sid).set(data);

        // Seed dynamic enrollment for the current year
        final String className = s['class'] ?? 'Grade 4';
        final String section = 'A';
        final int rollNumber = students.indexOf(s) + 1;
        await _db.collection('enrollments').doc("${sid}_2026-2027").set({
          'studentId': sid,
          'schoolId': schoolId,
          'academicYear': '2026-2027',
          'class': className,
          'section': section,
          'rollNumber': rollNumber,
        });
      }
      print("DatabaseSeeder: Seeded students and enrollments successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding students: $e");
      throw Exception("Students seed failed: $e");
    }

    // 4. Seed Fees
    try {
      print("DatabaseSeeder: Seeding fees...");
      final List<Map<String, dynamic>> fees = [
        {
          'id': 'fee_1',
          'studentId': 'student_1',
          'schoolId': schoolId,
          'title': 'Term 1 Tuition Fee',
          'amount': 5000.0,
          'status': 'pending',
          'dueDate': DateTime.now().add(const Duration(days: 30)),
          'paidDate': null,
          'receiptNo': null,
        },
        {
          'id': 'fee_2',
          'studentId': 'student_1',
          'schoolId': schoolId,
          'title': 'Library Annual Membership',
          'amount': 500.0,
          'status': 'paid',
          'dueDate': DateTime.now().subtract(const Duration(days: 15)),
          'paidDate': DateTime.now().subtract(const Duration(days: 20)),
          'receiptNo': 'REC-88012',
        },
        {
          'id': 'fee_3',
          'studentId': 'student_2',
          'schoolId': schoolId,
          'title': 'Term 1 Tuition Fee',
          'amount': 5000.0,
          'status': 'pending',
          'dueDate': DateTime.now().add(const Duration(days: 30)),
          'paidDate': null,
          'receiptNo': null,
        },
        {
          'id': 'fee_4',
          'studentId': 'student_2',
          'schoolId': schoolId,
          'title': 'School Orchestra & Instruments',
          'amount': 1500.0,
          'status': 'paid',
          'dueDate': DateTime.now().subtract(const Duration(days: 15)),
          'paidDate': DateTime.now().subtract(const Duration(days: 18)),
          'receiptNo': 'REC-88013',
        },
        {
          'id': 'fee_5',
          'studentId': 'student_3',
          'schoolId': schoolId,
          'title': 'Daycare Monthly Charges',
          'amount': 3000.0,
          'status': 'pending',
          'dueDate': DateTime.now().subtract(const Duration(days: 2)),
          'paidDate': null,
          'receiptNo': null,
        },
        {
          'id': 'fee_6',
          'studentId': 'student_4',
          'schoolId': schoolId,
          'title': 'Term 1 Tuition Fee',
          'amount': 5000.0,
          'status': 'pending',
          'dueDate': DateTime.now().add(const Duration(days: 30)),
          'paidDate': null,
          'receiptNo': null,
        },
      ];

      for (var f in fees) {
        final fid = f['id'];
        final data = Map<String, dynamic>.from(f)..remove('id');
        await _db.collection('fees').doc(fid).set(data);
      }
      print("DatabaseSeeder: Seeded fees successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding fees: $e");
      throw Exception("Fees seed failed: $e");
    }

    // 5. Seed Attendance
    try {
      print("DatabaseSeeder: Seeding attendance...");
      final List<Map<String, dynamic>> attendance = [
        {'studentId': 'student_1', 'date': '2026-06-08', 'status': 'present'},
        {'studentId': 'student_1', 'date': '2026-06-09', 'status': 'present'},
        {'studentId': 'student_1', 'date': '2026-06-10', 'status': 'absent'},
        {'studentId': 'student_1', 'date': '2026-06-11', 'status': 'present'},
        {'studentId': 'student_1', 'date': '2026-06-12', 'status': 'present'},
        {'studentId': 'student_2', 'date': '2026-06-08', 'status': 'present'},
        {'studentId': 'student_2', 'date': '2026-06-09', 'status': 'present'},
        {'studentId': 'student_2', 'date': '2026-06-10', 'status': 'present'},
        {'studentId': 'student_2', 'date': '2026-06-11', 'status': 'present'},
        {'studentId': 'student_2', 'date': '2026-06-12', 'status': 'present'},
        {'studentId': 'student_4', 'date': '2026-06-08', 'status': 'absent'},
        {'studentId': 'student_4', 'date': '2026-06-09', 'status': 'absent'},
        {'studentId': 'student_4', 'date': '2026-06-10', 'status': 'present'},
        {'studentId': 'student_4', 'date': '2026-06-11', 'status': 'present'},
        {'studentId': 'student_4', 'date': '2026-06-12', 'status': 'absent'},
      ];

      for (var a in attendance) {
        final studentId = a['studentId'];
        final date = a['date'];
        final docId = "${studentId}_$date";
        await _db.collection('attendance').doc(docId).set({
          'studentId': studentId,
          'schoolId': schoolId,
          'date': date,
          'status': a['status'],
          'markedBy': 'teacher_1',
          'markedAt': DateTime.now(),
        });
      }
      print("DatabaseSeeder: Seeded attendance successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding attendance: $e");
      throw Exception("Attendance seed failed: $e");
    }

    // 6. Seed Marks
    try {
      print("DatabaseSeeder: Seeding marks...");
      final List<Map<String, dynamic>> marks = [
        {
          'studentId': 'student_1',
          'schoolId': schoolId,
          'subject': 'Mathematics',
          'examName': 'Quarterly Exam',
          'marksObtained': 42.0,
          'maxMarks': 100.0,
          'grade': 'D',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
        {
          'studentId': 'student_1',
          'schoolId': schoolId,
          'subject': 'Science',
          'examName': 'Quarterly Exam',
          'marksObtained': 58.0,
          'maxMarks': 100.0,
          'grade': 'C',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
        {
          'studentId': 'student_2',
          'schoolId': schoolId,
          'subject': 'Mathematics',
          'examName': 'Quarterly Exam',
          'marksObtained': 99.0,
          'maxMarks': 100.0,
          'grade': 'A+',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
        {
          'studentId': 'student_2',
          'schoolId': schoolId,
          'subject': 'Science',
          'examName': 'Quarterly Exam',
          'marksObtained': 100.0,
          'maxMarks': 100.0,
          'grade': 'A+',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
        {
          'studentId': 'student_4',
          'schoolId': schoolId,
          'subject': 'Mathematics',
          'examName': 'Quarterly Exam',
          'marksObtained': 35.0,
          'maxMarks': 100.0,
          'grade': 'F',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
        {
          'studentId': 'student_4',
          'schoolId': schoolId,
          'subject': 'Science',
          'examName': 'Quarterly Exam',
          'marksObtained': 40.0,
          'maxMarks': 100.0,
          'grade': 'D',
          'teacherId': 'teacher_1',
          'markedAt': DateTime.now(),
        },
      ];

      for (var m in marks) {
        await _db.collection('marks').add(m);
      }
      print("DatabaseSeeder: Seeded marks successfully");
    } catch (e) {
      print("DatabaseSeeder error seeding marks: $e");
      throw Exception("Marks seed failed: $e");
    }

    // 7. Seed Logs
    try {
      print("DatabaseSeeder: Seeding logs...");
      await _db.collection('logs').add({
        'action': 'SYSTEM_INIT_SEED',
        'userId': 'admin_1',
        'schoolId': schoolId,
        'timestamp': DateTime.now(),
        'module': 'schools',
        'status': 'success',
        'errorCode': null,
      });
      print("DatabaseSeeder: Seeded logs successfully");
      print("DatabaseSeeder: Seeding completed successfully!");
    } catch (e) {
      print("DatabaseSeeder error seeding logs: $e");
      throw Exception("Logs seed failed: $e");
    }
  }
}
