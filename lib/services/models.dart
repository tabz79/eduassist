import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;

  School({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory School.fromMap(Map<String, dynamic> map, String documentId) {
    return School(
      id: documentId,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; // 'parent', 'teacher', 'admin', 'superadmin'
  final String schoolId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.schoolId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'schoolId': schoolId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      schoolId: map['schoolId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Student {
  final String id;
  final String name;
  final String className; // 'class' in DB, using className in Dart to avoid keyword clash
  final String schoolId;
  final String parentId;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.schoolId,
    required this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'class': className,
      'schoolId': schoolId,
      'parentId': parentId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String documentId) {
    return Student(
      id: documentId,
      name: map['name'] ?? '',
      className: map['class'] ?? '',
      schoolId: map['schoolId'] ?? '',
      parentId: map['parentId'] ?? '',
    );
  }
}

class FeeRecord {
  final String id;
  final String studentId;
  final String schoolId;
  final String title;
  final double amount;
  final String status; // 'pending', 'paid'
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? receiptNo;

  FeeRecord({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.title,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
    this.receiptNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'title': title,
      'amount': amount,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'receiptNo': receiptNo,
    };
  }

  factory FeeRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return FeeRecord(
      id: documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate: (map['paidDate'] as Timestamp?)?.toDate(),
      receiptNo: map['receiptNo'],
    );
  }
}

class AttendanceRecord {
  final String id; // studentId_YYYY-MM-DD
  final String studentId;
  final String schoolId;
  final String date; // YYYY-MM-DD
  final String status; // 'present', 'absent'
  final String markedBy;
  final DateTime markedAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.date,
    required this.status,
    required this.markedBy,
    required this.markedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'date': date,
      'status': status,
      'markedBy': markedBy,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return AttendanceRecord(
      id: documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'absent',
      markedBy: map['markedBy'] ?? '',
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class MarkRecord {
  final String id;
  final String studentId;
  final String schoolId;
  final String subject;
  final String examName;
  final double marksObtained;
  final double maxMarks;
  final String grade;
  final String teacherId;
  final DateTime markedAt;

  MarkRecord({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.subject,
    required this.examName,
    required this.marksObtained,
    required this.maxMarks,
    required this.grade,
    required this.teacherId,
    required this.markedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'subject': subject,
      'examName': examName,
      'marksObtained': marksObtained,
      'maxMarks': maxMarks,
      'grade': grade,
      'teacherId': teacherId,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }

  factory MarkRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return MarkRecord(
      id: documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      subject: map['subject'] ?? '',
      examName: map['examName'] ?? '',
      marksObtained: (map['marksObtained'] as num?)?.toDouble() ?? 0.0,
      maxMarks: (map['maxMarks'] as num?)?.toDouble() ?? 100.0,
      grade: map['grade'] ?? '',
      teacherId: map['teacherId'] ?? '',
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class LogEntry {
  final String id;
  final String action;
  final String userId;
  final String? studentId;
  final String schoolId;
  final DateTime timestamp;
  final String module; // 'auth', 'fees', 'attendance', 'marks', 'schools'
  final String status; // 'success', 'error', 'info'
  final String? errorCode;

  LogEntry({
    required this.id,
    required this.action,
    required this.userId,
    this.studentId,
    required this.schoolId,
    required this.timestamp,
    required this.module,
    required this.status,
    this.errorCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'userId': userId,
      'studentId': studentId,
      'schoolId': schoolId,
      'timestamp': Timestamp.fromDate(timestamp),
      'module': module,
      'status': status,
      'errorCode': errorCode,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return LogEntry(
      id: documentId,
      action: map['action'] ?? '',
      userId: map['userId'] ?? '',
      studentId: map['studentId'],
      schoolId: map['schoolId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      module: map['module'] ?? 'general',
      status: map['status'] ?? 'info',
      errorCode: map['errorCode'],
    );
  }
}

class Enrollment {
  final String id;
  final String studentId;
  final String schoolId;
  final String academicYear;
  final String className;
  final String section;
  final int rollNumber;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.academicYear,
    required this.className,
    required this.section,
    required this.rollNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'academicYear': academicYear,
      'class': className,
      'section': section,
      'rollNumber': rollNumber,
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map, String documentId) {
    return Enrollment(
      id: documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      academicYear: map['academicYear'] ?? '',
      className: map['class'] ?? '',
      section: map['section'] ?? '',
      rollNumber: map['rollNumber'] is int ? map['rollNumber'] : int.tryParse(map['rollNumber']?.toString() ?? '') ?? 0,
    );
  }
}

class ClassroomUpdate {
  final String id;
  final String schoolId;
  final String teacherId;
  final String className;
  final String section;
  final String subject;
  final String chapter;
  final String topicCovered;
  final String homework;
  final String? photoUrl;
  final String date; // YYYY-MM-DD
  final DateTime timestamp;

  ClassroomUpdate({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.className,
    required this.section,
    required this.subject,
    required this.chapter,
    required this.topicCovered,
    required this.homework,
    this.photoUrl,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'teacherId': teacherId,
      'class': className,
      'section': section,
      'subject': subject,
      'chapter': chapter,
      'topicCovered': topicCovered,
      'homework': homework,
      'photoUrl': photoUrl,
      'date': date,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ClassroomUpdate.fromMap(Map<String, dynamic> map, String documentId) {
    return ClassroomUpdate(
      id: documentId,
      schoolId: map['schoolId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      className: map['class'] ?? '',
      section: map['section'] ?? '',
      subject: map['subject'] ?? '',
      chapter: map['chapter'] ?? '',
      topicCovered: map['topicCovered'] ?? '',
      homework: map['homework'] ?? '',
      photoUrl: map['photoUrl'],
      date: map['date'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TestConfig {
  final String id;
  final String schoolId;
  final String className;
  final String subject;
  final String testName;
  final double maxMarks;
  final String date;

  TestConfig({
    required this.id,
    required this.schoolId,
    required this.className,
    required this.subject,
    required this.testName,
    required this.maxMarks,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'class': className,
      'subject': subject,
      'testName': testName,
      'maxMarks': maxMarks,
      'date': date,
    };
  }

  factory TestConfig.fromMap(Map<String, dynamic> map, String documentId) {
    return TestConfig(
      id: documentId,
      schoolId: map['schoolId'] ?? '',
      className: map['class'] ?? '',
      subject: map['subject'] ?? '',
      testName: map['testName'] ?? '',
      maxMarks: (map['maxMarks'] as num?)?.toDouble() ?? 100.0,
      date: map['date'] ?? '',
    );
  }
}

class SupportTicket {
  final String id;
  final String schoolId;
  final String issueType;
  final String description;
  final String status; // 'open' | 'assigned' | 'in_progress' | 'resolved' | 'closed'
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.schoolId,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'issueType': issueType,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map, String documentId) {
    return SupportTicket(
      id: documentId,
      schoolId: map['schoolId'] ?? '',
      issueType: map['issueType'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'open',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class LeadRecord {
  final String id;
  final String schoolName;
  final String contactName;
  final String phone;
  final String status; // 'lead' | 'contacted' | 'demo' | 'trial' | 'converted'

  LeadRecord({
    required this.id,
    required this.schoolName,
    required this.contactName,
    required this.phone,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'contactName': contactName,
      'phone': phone,
      'status': status,
    };
  }

  factory LeadRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return LeadRecord(
      id: documentId,
      schoolName: map['schoolName'] ?? '',
      contactName: map['contactName'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'lead',
    );
  }
}
