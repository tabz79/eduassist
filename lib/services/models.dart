import 'package:cloud_firestore/cloud_firestore.dart';

// Backwards compatibility typedefs to keep existing screens compiling
typedef TestConfig = TestModel;
typedef FeeRecord = FeeAssignment;
typedef AttendanceRecord = AttendanceModel;
typedef ClassroomUpdate = ClassroomUpdateModel;
typedef SupportTicket = SupportTicketModel;
typedef LogEntry = AuditLog;
typedef MarkRecord = MarkModel;

class School {
  final String schoolId;
  final String name;
  final String board;
  final String address;
  final DateTime createdAt;
  final bool isSetupComplete;

  String get id => schoolId;

  School({
    String? id,
    required this.schoolId,
    required this.name,
    required this.board,
    required this.address,
    required this.createdAt,
    this.isSetupComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'board': board,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSetupComplete': isSetupComplete,
    };
  }

  factory School.fromMap(Map<String, dynamic> map, String documentId) {
    return School(
      schoolId: map['schoolId'] ?? documentId,
      name: map['name'] ?? '',
      board: map['board'] ?? '',
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSetupComplete: map['isSetupComplete'] ?? false,
    );
  }
}

class UserModel {
  final String userId;
  final String schoolId;
  final String phone;
  final String email;
  final String name;
  final String role; // 'parent', 'teacher', 'admin', 'superadmin'
  final String? specialization;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;

  String get id => userId;

  UserModel({
    String? id,
    required this.userId,
    required this.schoolId,
    required this.phone,
    required this.email,
    required this.name,
    required this.role,
    this.specialization,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'schoolId': schoolId,
      'phone': phone,
      'email': email,
      'name': name,
      'role': role,
      'specialization': specialization,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      userId: map['userId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      specialization: map['specialization'],
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ParentStudentLink {
  final String linkId;
  final String schoolId;
  final String parentId;
  final String studentId;
  final String relationship;
  final bool isEmergencyContact;

  String get id => linkId;

  ParentStudentLink({
    String? id,
    required this.linkId,
    required this.schoolId,
    required this.parentId,
    required this.studentId,
    required this.relationship,
    required this.isEmergencyContact,
  });

  Map<String, dynamic> toMap() {
    return {
      'linkId': linkId,
      'schoolId': schoolId,
      'parentId': parentId,
      'studentId': studentId,
      'relationship': relationship,
      'isEmergencyContact': isEmergencyContact,
    };
  }

  factory ParentStudentLink.fromMap(Map<String, dynamic> map, String documentId) {
    return ParentStudentLink(
      linkId: map['linkId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      parentId: map['parentId'] ?? '',
      studentId: map['studentId'] ?? '',
      relationship: map['relationship'] ?? '',
      isEmergencyContact: map['isEmergencyContact'] ?? false,
    );
  }
}

class Student {
  final String studentId;
  final String schoolId;
  final String name;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String address;
  final String globalStatus; // 'inquiry', 'applied', 'under_review', 'approved', 'active', 'transferred', 'graduated', 'dropped'
  final DateTime createdAt;

  String get id => studentId;
  String get className => 'Grade 5'; // Backward compatibility fallback
  String get parentId => ''; // Backward compatibility fallback

  Student({
    String? id,
    required this.studentId,
    required this.schoolId,
    required this.name,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.globalStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'name': name,
      'dob': dob,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'globalStatus': globalStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String documentId) {
    return Student(
      studentId: map['studentId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      globalStatus: map['globalStatus'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AcademicYear {
  final String academicYearId;
  final String schoolId;
  final String year; // e.g. "2026-2027"
  final String startDate;
  final String endDate;
  final String status; // 'active', 'inactive'

  String get id => academicYearId;

  AcademicYear({
    String? id,
    required this.academicYearId,
    required this.schoolId,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'academicYearId': academicYearId,
      'schoolId': schoolId,
      'year': year,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    };
  }

  factory AcademicYear.fromMap(Map<String, dynamic> map, String documentId) {
    return AcademicYear(
      academicYearId: map['academicYearId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      year: map['year'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}

class ClassModel {
  final String classId;
  final String schoolId;
  final String name;
  final DateTime createdAt;

  String get id => classId;

  ClassModel({
    String? id,
    required this.classId,
    required this.schoolId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'schoolId': schoolId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClassModel(
      classId: map['classId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SectionModel {
  final String sectionId;
  final String schoolId;
  final String classId;
  final String name;
  final int capacity;
  final DateTime createdAt;

  String get id => sectionId;

  SectionModel({
    String? id,
    required this.sectionId,
    required this.schoolId,
    required this.classId,
    required this.name,
    required this.capacity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sectionId': sectionId,
      'schoolId': schoolId,
      'classId': classId,
      'name': name,
      'capacity': capacity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SectionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SectionModel(
      sectionId: map['sectionId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] is int ? map['capacity'] : int.tryParse(map['capacity']?.toString() ?? '') ?? 30,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Enrollment {
  final String enrollmentId;
  final String studentId;
  final String schoolId;
  final String academicYearId;
  final String classId;
  final String sectionId;
  final int rollNumber;
  final String enrollmentStatus; // 'enrolled', 'suspended', 'active', 'promoted'
  final DateTime updatedAt;

  String get id => enrollmentId;
  String get className => 'Grade 5'; // Backward compatibility

  Enrollment({
    String? id,
    required this.enrollmentId,
    required this.studentId,
    required this.schoolId,
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    required this.rollNumber,
    required this.enrollmentStatus,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'enrollmentId': enrollmentId,
      'studentId': studentId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'classId': classId,
      'sectionId': sectionId,
      'rollNumber': rollNumber,
      'enrollmentStatus': enrollmentStatus,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map, String documentId) {
    return Enrollment(
      enrollmentId: map['enrollmentId'] ?? documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      classId: map['classId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      rollNumber: map['rollNumber'] is int ? map['rollNumber'] : int.tryParse(map['rollNumber']?.toString() ?? '') ?? 0,
      enrollmentStatus: map['enrollmentStatus'] ?? 'active',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SubjectModel {
  final String subjectId;
  final String schoolId;
  final String academicYearId;
  final String classId;
  final String name;
  final String code;
  final DateTime createdAt;

  String get id => subjectId;

  SubjectModel({
    String? id,
    required this.subjectId,
    required this.schoolId,
    required this.academicYearId,
    required this.classId,
    required this.name,
    required this.code,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'classId': classId,
      'name': name,
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubjectModel(
      subjectId: map['subjectId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TeacherAssignment {
  final String assignmentId;
  final String schoolId;
  final String teacherId;
  final String academicYearId;
  final String classId;
  final String sectionId;
  final String subjectId;
  final String assignmentType; // 'class_teacher', 'subject_teacher'

  String get id => assignmentId;

  TeacherAssignment({
    String? id,
    required this.assignmentId,
    required this.schoolId,
    required this.teacherId,
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.assignmentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'schoolId': schoolId,
      'teacherId': teacherId,
      'academicYearId': academicYearId,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'assignmentType': assignmentType,
    };
  }

  factory TeacherAssignment.fromMap(Map<String, dynamic> map, String documentId) {
    return TeacherAssignment(
      assignmentId: map['assignmentId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      classId: map['classId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      assignmentType: map['assignmentType'] ?? 'subject_teacher',
    );
  }
}

class Timetable {
  final String timetableId;
  final String schoolId;
  final String academicYearId;
  final String classId;
  final String sectionId;
  final String dayOfWeek;
  final int periodNumber;
  final String subjectId;
  final String teacherId;
  final String startTime;
  final String endTime;

  String get id => timetableId;

  Timetable({
    String? id,
    required this.timetableId,
    required this.schoolId,
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    required this.dayOfWeek,
    required this.periodNumber,
    required this.subjectId,
    required this.teacherId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'timetableId': timetableId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'classId': classId,
      'sectionId': sectionId,
      'dayOfWeek': dayOfWeek,
      'periodNumber': periodNumber,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Timetable.fromMap(Map<String, dynamic> map, String documentId) {
    return Timetable(
      timetableId: map['timetableId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      classId: map['classId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      periodNumber: map['periodNumber'] is int ? map['periodNumber'] : int.tryParse(map['periodNumber']?.toString() ?? '') ?? 1,
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }
}

class TimetableSubstitution {
  final String substitutionId;
  final String schoolId;
  final String timetableId;
  final String date;
  final String originalTeacherId;
  final String substituteTeacherId;
  final String reason;
  final String status;
  final DateTime createdAt;

  String get id => substitutionId;

  TimetableSubstitution({
    String? id,
    required this.substitutionId,
    required this.schoolId,
    required this.timetableId,
    required this.date,
    required this.originalTeacherId,
    required this.substituteTeacherId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'substitutionId': substitutionId,
      'schoolId': schoolId,
      'timetableId': timetableId,
      'date': date,
      'originalTeacherId': originalTeacherId,
      'substituteTeacherId': substituteTeacherId,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TimetableSubstitution.fromMap(Map<String, dynamic> map, String documentId) {
    return TimetableSubstitution(
      substitutionId: map['substitutionId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      timetableId: map['timetableId'] ?? '',
      date: map['date'] ?? '',
      originalTeacherId: map['originalTeacherId'] ?? '',
      substituteTeacherId: map['substituteTeacherId'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'approved',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SyllabusChapter {
  final String chapterId;
  final String schoolId;
  final String subjectId;
  final int chapterNumber;
  final String title;
  final String description;
  final List<String> topics;

  String get id => chapterId;

  SyllabusChapter({
    String? id,
    required this.chapterId,
    required this.schoolId,
    required this.subjectId,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.topics,
  });

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'schoolId': schoolId,
      'subjectId': subjectId,
      'chapterNumber': chapterNumber,
      'title': title,
      'description': description,
      'topics': topics,
    };
  }

  factory SyllabusChapter.fromMap(Map<String, dynamic> map, String documentId) {
    return SyllabusChapter(
      chapterId: map['chapterId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      chapterNumber: map['chapterNumber'] is int ? map['chapterNumber'] : int.tryParse(map['chapterNumber']?.toString() ?? '') ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      topics: List<String>.from(map['topics'] ?? []),
    );
  }
}

class SyllabusProgress {
  final String progressId;
  final String schoolId;
  final String academicYearId;
  final String sectionId;
  final String subjectId;
  final String chapterId;
  final String topicName;
  final String status; // 'completed', 'in_progress', 'pending'
  final String completedBy;
  final DateTime completedAt;

  String get id => progressId;

  SyllabusProgress({
    String? id,
    required this.progressId,
    required this.schoolId,
    required this.academicYearId,
    required this.sectionId,
    required this.subjectId,
    required this.chapterId,
    required this.topicName,
    required this.status,
    required this.completedBy,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'progressId': progressId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'topicName': topicName,
      'status': status,
      'completedBy': completedBy,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory SyllabusProgress.fromMap(Map<String, dynamic> map, String documentId) {
    return SyllabusProgress(
      progressId: map['progressId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      topicName: map['topicName'] ?? '',
      status: map['status'] ?? 'pending',
      completedBy: map['completedBy'] ?? '',
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ExamModel {
  final String examId;
  final String schoolId;
  final String academicYearId;
  final String name;
  final String term;
  final double weightage;
  final DateTime createdAt;

  String get id => examId;

  ExamModel({
    String? id,
    required this.examId,
    required this.schoolId,
    required this.academicYearId,
    required this.name,
    required this.term,
    required this.weightage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'name': name,
      'term': term,
      'weightage': weightage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExamModel(
      examId: map['examId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      name: map['name'] ?? '',
      term: map['term'] ?? '',
      weightage: (map['weightage'] as num?)?.toDouble() ?? 10.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TestModel {
  final String testId;
  final String schoolId;
  final String academicYearId;
  final String examId;
  final String classId;
  final String sectionId;
  final String subjectId;
  final String testName;
  final double maxMarks;
  final String date;
  final String createdBy;

  String get id => testId;
  String get subject => 'Science'; // Backward compatibility

  TestModel({
    String? id,
    required this.testId,
    required this.schoolId,
    required this.academicYearId,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.testName,
    required this.maxMarks,
    required this.date,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'examId': examId,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'testName': testName,
      'maxMarks': maxMarks,
      'date': date,
      'createdBy': createdBy,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TestModel(
      testId: map['testId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      examId: map['examId'] ?? '',
      classId: map['classId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      testName: map['testName'] ?? '',
      maxMarks: (map['maxMarks'] as num?)?.toDouble() ?? 100.0,
      date: map['date'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}

class MarkModel {
  final String markId;
  final String schoolId;
  final String studentId;
  final String academicYearId;
  final String testId;
  final String subjectId;
  final double marksObtained;
  final double maxMarks;
  final String status; // 'present', 'absent', 'exempted'
  final String grade;
  final String teacherId;
  final DateTime markedAt;

  String get id => markId;
  String get examName => 'Unit Test 1'; // Backward compatibility
  String get subject => 'Mathematics'; // Backward compatibility

  MarkModel({
    String? id,
    required this.markId,
    required this.schoolId,
    required this.studentId,
    required this.academicYearId,
    required this.testId,
    required this.subjectId,
    required this.marksObtained,
    required this.maxMarks,
    required this.status,
    required this.grade,
    required this.teacherId,
    required this.markedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'markId': markId,
      'schoolId': schoolId,
      'studentId': studentId,
      'academicYearId': academicYearId,
      'testId': testId,
      'subjectId': subjectId,
      'marksObtained': marksObtained,
      'maxMarks': maxMarks,
      'status': status,
      'grade': grade,
      'teacherId': teacherId,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }

  factory MarkModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MarkModel(
      markId: map['markId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      testId: map['testId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      marksObtained: (map['marksObtained'] as num?)?.toDouble() ?? 0.0,
      maxMarks: (map['maxMarks'] as num?)?.toDouble() ?? 100.0,
      status: map['status'] ?? 'present',
      grade: map['grade'] ?? '',
      teacherId: map['teacherId'] ?? '',
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SubjectSummary {
  final String subjectId;
  final String subjectName;
  final double marksObtained;
  final double maxMarks;
  final String grade;
  final String? remarks;

  SubjectSummary({
    required this.subjectId,
    required this.subjectName,
    required this.marksObtained,
    required this.maxMarks,
    required this.grade,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'marksObtained': marksObtained,
      'maxMarks': maxMarks,
      'grade': grade,
      'remarks': remarks,
    };
  }

  factory SubjectSummary.fromMap(Map<String, dynamic> map) {
    return SubjectSummary(
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      marksObtained: (map['marksObtained'] as num?)?.toDouble() ?? 0.0,
      maxMarks: (map['maxMarks'] as num?)?.toDouble() ?? 100.0,
      grade: map['grade'] ?? '',
      remarks: map['remarks'],
    );
  }
}

class ReportCardModel {
  final String reportCardId;
  final String studentId;
  final String schoolId;
  final String academicYearId;
  final String term;
  final List<SubjectSummary> subjectSummaries;
  final double overallPercentage;
  final String status; // 'draft', 'locked'
  final int version;
  final String generatedBy;
  final DateTime createdAt;

  String get id => reportCardId;

  ReportCardModel({
    String? id,
    required this.reportCardId,
    required this.studentId,
    required this.schoolId,
    required this.academicYearId,
    required this.term,
    required this.subjectSummaries,
    required this.overallPercentage,
    required this.status,
    required this.version,
    required this.generatedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportCardId': reportCardId,
      'studentId': studentId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'term': term,
      'subjectSummaries': subjectSummaries.map((s) => s.toMap()).toList(),
      'overallPercentage': overallPercentage,
      'status': status,
      'version': version,
      'generatedBy': generatedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReportCardModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReportCardModel(
      reportCardId: map['reportCardId'] ?? documentId,
      studentId: map['studentId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      term: map['term'] ?? '',
      subjectSummaries: (map['subjectSummaries'] as List?)
              ?.map((s) => SubjectSummary.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      overallPercentage: (map['overallPercentage'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'draft',
      version: map['version'] is int ? map['version'] : int.tryParse(map['version']?.toString() ?? '') ?? 1,
      generatedBy: map['generatedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AttendanceModel {
  final String attendanceId;
  final String schoolId;
  final String studentId;
  final String academicYearId;
  final String date;
  final String status; // 'present', 'absent', 'reported_absent'
  final String markedBy;
  final DateTime markedAt;

  String get id => attendanceId;

  AttendanceModel({
    String? id,
    String? attendanceId,
    String? schoolId,
    required this.studentId,
    String? academicYearId,
    required this.date,
    required this.status,
    required this.markedBy,
    required this.markedAt,
  })  : attendanceId = attendanceId ?? id ?? '',
        schoolId = schoolId ?? '',
        academicYearId = academicYearId ?? 'AY2026';

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'schoolId': schoolId,
      'studentId': studentId,
      'academicYearId': academicYearId,
      'date': date,
      'status': status,
      'markedBy': markedBy,
      'markedAt': Timestamp.fromDate(markedAt),
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AttendanceModel(
      attendanceId: map['attendanceId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'absent',
      markedBy: map['markedBy'] ?? '',
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ClassroomUpdateModel {
  final String updateId;
  final String schoolId;
  final String academicYearId;
  final String teacherId;
  final String classId;
  final String sectionId;
  final String subjectId;
  final String? chapterId;
  final String topicCovered;
  final String homework;
  final String? photoUrl;
  final String date;
  final DateTime timestamp;

  String get id => updateId;
  String get subject => 'Science'; // Backward compatibility
  String get chapter => 'Fractions'; // Backward compatibility

  ClassroomUpdateModel({
    String? id,
    required this.updateId,
    required this.schoolId,
    required this.academicYearId,
    required this.teacherId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    this.chapterId,
    required this.topicCovered,
    required this.homework,
    this.photoUrl,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'updateId': updateId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'teacherId': teacherId,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'topicCovered': topicCovered,
      'homework': homework,
      'photoUrl': photoUrl,
      'date': date,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ClassroomUpdateModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClassroomUpdateModel(
      updateId: map['updateId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      classId: map['classId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      chapterId: map['chapterId'],
      topicCovered: map['topicCovered'] ?? '',
      homework: map['homework'] ?? '',
      photoUrl: map['photoUrl'],
      date: map['date'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AbsenceRequest {
  final String requestId;
  final String schoolId;
  final String studentId;
  final String parentId;
  final String startDate;
  final String endDate;
  final String reason;
  final String? attachmentUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? teacherRemarks;

  String get id => requestId;

  AbsenceRequest({
    String? id,
    required this.requestId,
    required this.schoolId,
    required this.studentId,
    required this.parentId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.teacherRemarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'schoolId': schoolId,
      'studentId': studentId,
      'parentId': parentId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'teacherRemarks': teacherRemarks,
    };
  }

  factory AbsenceRequest.fromMap(Map<String, dynamic> map, String documentId) {
    return AbsenceRequest(
      requestId: map['requestId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      parentId: map['parentId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      reason: map['reason'] ?? '',
      attachmentUrl: map['attachmentUrl'],
      status: map['status'] ?? 'pending',
      reviewedBy: map['reviewedBy'],
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      teacherRemarks: map['teacherRemarks'],
    );
  }
}

class Announcement {
  final String announcementId;
  final String schoolId;
  final String senderId;
  final String title;
  final String body;
  final String scope; // 'school', 'class', 'section'
  final String? targetClassId;
  final String? targetSectionId;
  final DateTime createdAt;

  String get id => announcementId;

  Announcement({
    String? id,
    required this.announcementId,
    required this.schoolId,
    required this.senderId,
    required this.title,
    required this.body,
    required this.scope,
    this.targetClassId,
    this.targetSectionId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'schoolId': schoolId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'scope': scope,
      'targetClassId': targetClassId,
      'targetSectionId': targetSectionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map, String documentId) {
    return Announcement(
      announcementId: map['announcementId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      senderId: map['senderId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      scope: map['scope'] ?? 'school',
      targetClassId: map['targetClassId'],
      targetSectionId: map['targetSectionId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FeeStructure {
  final String feeStructureId;
  final String schoolId;
  final String academicYearId;
  final String title;
  final double amount;
  final DateTime dueDate;

  String get id => feeStructureId;

  FeeStructure({
    String? id,
    required this.feeStructureId,
    required this.schoolId,
    required this.academicYearId,
    required this.title,
    required this.amount,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'feeStructureId': feeStructureId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }

  factory FeeStructure.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    final rawDueDate = map['dueDate'];
    if (rawDueDate is Timestamp) {
      parsedDate = rawDueDate.toDate();
    } else if (rawDueDate is String) {
      parsedDate = DateTime.tryParse(rawDueDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FeeStructure(
      feeStructureId: map['feeStructureId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: parsedDate,
    );
  }
}

class FeeAssignment {
  final String feeAssignmentId;
  final String schoolId;
  final String studentId;
  final String academicYearId;
  final String feeStructureId;
  final String title;
  final double amount;
  final double discount;
  final double netAmount;
  final String status; // 'pending', 'paid', 'partially_paid'
  final double amountPaid;
  final DateTime dueDate;

  String get id => feeAssignmentId;
  DateTime get dueDateParsed => dueDate; // Backward compatibility helper
  DateTime? get paidDate => null; // Backward compatibility
  String? get receiptNo => null; // Backward compatibility

  FeeAssignment({
    String? id,
    required this.feeAssignmentId,
    required this.schoolId,
    required this.studentId,
    required this.academicYearId,
    required this.feeStructureId,
    required this.title,
    required this.amount,
    required this.discount,
    required this.netAmount,
    required this.status,
    required this.amountPaid,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'feeAssignmentId': feeAssignmentId,
      'schoolId': schoolId,
      'studentId': studentId,
      'academicYearId': academicYearId,
      'feeStructureId': feeStructureId,
      'title': title,
      'amount': amount,
      'discount': discount,
      'netAmount': netAmount,
      'status': status,
      'amountPaid': amountPaid,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }

  factory FeeAssignment.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    final rawDueDate = map['dueDate'];
    if (rawDueDate is Timestamp) {
      parsedDate = rawDueDate.toDate();
    } else if (rawDueDate is String) {
      parsedDate = DateTime.tryParse(rawDueDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FeeAssignment(
      feeAssignmentId: map['feeAssignmentId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      feeStructureId: map['feeStructureId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (map['netAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      dueDate: parsedDate,
    );
  }
}

class FeePayment {
  final String paymentId;
  final String schoolId;
  final String feeAssignmentId;
  final String studentId;
  final double amountPaid;
  final String paymentMethod; // 'upi', 'card', 'net_banking', 'cash'
  final String gatewayTxnId;
  final String status; // 'success', 'failed'
  final DateTime timestamp;

  String get id => paymentId;

  FeePayment({
    String? id,
    required this.paymentId,
    required this.schoolId,
    required this.feeAssignmentId,
    required this.studentId,
    required this.amountPaid,
    required this.paymentMethod,
    required this.gatewayTxnId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'schoolId': schoolId,
      'feeAssignmentId': feeAssignmentId,
      'studentId': studentId,
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod,
      'gatewayTxnId': gatewayTxnId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory FeePayment.fromMap(Map<String, dynamic> map, String documentId) {
    return FeePayment(
      paymentId: map['paymentId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      feeAssignmentId: map['feeAssignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'upi',
      gatewayTxnId: map['gatewayTxnId'] ?? '',
      status: map['status'] ?? 'success',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Receipt {
  final String receiptId;
  final String schoolId;
  final String paymentId;
  final String studentId;
  final double amount;
  final String receiptNo;
  final DateTime createdAt;

  String get id => receiptId;

  Receipt({
    String? id,
    required this.receiptId,
    required this.schoolId,
    required this.paymentId,
    required this.studentId,
    required this.amount,
    required this.receiptNo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiptId': receiptId,
      'schoolId': schoolId,
      'paymentId': paymentId,
      'studentId': studentId,
      'amount': amount,
      'receiptNo': receiptNo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map, String documentId) {
    return Receipt(
      receiptId: map['receiptId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      paymentId: map['paymentId'] ?? '',
      studentId: map['studentId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      receiptNo: map['receiptNo'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Subscription {
  final String subscriptionId;
  final String schoolId;
  final String planName;
  final int studentLimit;
  final String status; // 'active', 'lapsed'
  final DateTime expiresAt;
  final DateTime createdAt;

  String get id => subscriptionId;

  Subscription({
    String? id,
    required this.subscriptionId,
    required this.schoolId,
    required this.planName,
    required this.studentLimit,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subscriptionId': subscriptionId,
      'schoolId': schoolId,
      'planName': planName,
      'studentLimit': studentLimit,
      'status': status,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map, String documentId) {
    return Subscription(
      subscriptionId: map['subscriptionId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      planName: map['planName'] ?? '',
      studentLimit: map['studentLimit'] is int ? map['studentLimit'] : int.tryParse(map['studentLimit']?.toString() ?? '') ?? 0,
      status: map['status'] ?? 'active',
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class SupportTicketModel {
  final String ticketId;
  final String schoolId;
  final String userId;
  final String issueType;
  final String description;
  final String status; // 'open', 'resolved'
  final DateTime createdAt;

  String get id => ticketId;

  SupportTicketModel({
    String? id,
    required this.ticketId,
    required this.schoolId,
    required this.userId,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'schoolId': schoolId,
      'userId': userId,
      'issueType': issueType,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SupportTicketModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SupportTicketModel(
      ticketId: map['ticketId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      userId: map['userId'] ?? '',
      issueType: map['issueType'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'open',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AuditLog {
  final String logId;
  final String schoolId;
  final String userId;
  final DateTime timestamp;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> beforeState;
  final Map<String, dynamic> afterState;

  String get id => logId;

  AuditLog({
    String? id,
    required this.logId,
    required this.schoolId,
    required this.userId,
    required this.timestamp,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.beforeState,
    required this.afterState,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'schoolId': schoolId,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'beforeState': beforeState,
      'afterState': afterState,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map, String documentId) {
    return AuditLog(
      logId: map['logId'] ?? documentId,
      schoolId: map['schoolId'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      action: map['action'] ?? '',
      entityType: map['entityType'] ?? '',
      entityId: map['entityId'] ?? '',
      beforeState: map['beforeState'] ?? {},
      afterState: map['afterState'] ?? {},
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
