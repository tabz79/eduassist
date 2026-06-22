import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static WriteBatch _currentBatch = _db.batch();
  static int _batchCount = 0;
  static int _totalWrites = 0;

  static Future<void> _safeSet(DocumentReference ref, Map<String, dynamic> data) async {
    _currentBatch.set(ref, data);
    _batchCount++;
    _totalWrites++;
    if (_batchCount >= 400) {
      await _currentBatch.commit();
      _currentBatch = _db.batch();
      _batchCount = 0;
    }
  }

  static Future<void> _safeDelete(DocumentReference ref) async {
    _currentBatch.delete(ref);
    _batchCount++;
    _totalWrites++;
    if (_batchCount >= 400) {
      await _currentBatch.commit();
      _currentBatch = _db.batch();
      _batchCount = 0;
    }
  }

  static Future<void> _flushBatch() async {
    if (_batchCount > 0) {
      await _currentBatch.commit();
      _currentBatch = _db.batch();
      _batchCount = 0;
    }
  }

  static Future<void> seedDatabase() async {
    print("DatabaseSeeder: Starting comprehensive seeding for Vidyalaya Primary School...");
    _totalWrites = 0;
    _batchCount = 0;
    _currentBatch = _db.batch();

    final schoolId = "SCH8K4M2";
    final academicYearId = "AY2026-27";

    // 1. Safe purge of pre-existing records for schoolId SCH8K4M2 to make the run idempotent
    final collectionsToPurge = [
      'schools',
      'academic_years',
      'classes',
      'sections',
      'users',
      'students',
      'enrollments',
      'parent_student_links',
      'subjects',
      'teacher_assignments',
      'timetables',
      'syllabus_chapters',
      'exams',
      'tests',
      'marks',
      'attendance',
      'fee_structures',
      'fee_assignments',
      'announcements',
      'classroom_updates',
      'audit_logs'
    ];

    for (var colName in collectionsToPurge) {
      try {
        final snapshots = await _db.collection(colName).where('schoolId', isEqualTo: schoolId).get();
        for (var doc in snapshots.docs) {
          await _safeDelete(doc.reference);
        }
      } catch (e) {
        print("Warning: Purging collection $colName failed: $e");
      }
    }
    await _flushBatch();
    print("DatabaseSeeder: Old school records purged successfully.");

    // 2. Seed School Document
    final schoolRef = _db.collection('schools').doc(schoolId);
    await _safeSet(schoolRef, {
      'schoolId': schoolId,
      'name': 'Vidyalaya Primary School',
      'board': 'CBSE',
      'address': 'Vijay Nagar, Indore, Madhya Pradesh',
      'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      'isSetupComplete': true,
    });

    // 3. Seed Academic Year
    final ayRef = _db.collection('academic_years').doc(academicYearId);
    await _safeSet(ayRef, {
      'academicYearId': academicYearId,
      'schoolId': schoolId,
      'year': '2026-2027',
      'startDate': '2026-06-01',
      'endDate': '2027-04-30',
      'status': 'active',
    });

    // 4. Seed Classes
    final classes = [
      {'id': 'CLS_NUR', 'name': 'Nursery', 'tier': 'foundation'},
      {'id': 'CLS_LKG', 'name': 'LKG', 'tier': 'foundation'},
      {'id': 'CLS_UKG', 'name': 'UKG', 'tier': 'foundation'},
      {'id': 'CLS_C01', 'name': 'Class 1', 'tier': 'primary'},
      {'id': 'CLS_C02', 'name': 'Class 2', 'tier': 'primary'},
      {'id': 'CLS_C03', 'name': 'Class 3', 'tier': 'primary'},
      {'id': 'CLS_C04', 'name': 'Class 4', 'tier': 'primary'},
      {'id': 'CLS_C05', 'name': 'Class 5', 'tier': 'primary'},
    ];

    for (var c in classes) {
      await _safeSet(_db.collection('classes').doc(c['id']), {
        'classId': c['id'],
        'schoolId': schoolId,
        'name': c['name'],
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });
    }

    // 5. Seed Sections
    final sections = <Map<String, String>>[];
    for (var c in classes) {
      for (var secName in ['A', 'B']) {
        final secId = "SEC_${c['id']!.substring(4)}_${secName}";
        sections.add({
          'sectionId': secId,
          'classId': c['id']!,
          'name': secName,
        });

        await _safeSet(_db.collection('sections').doc(secId), {
          'sectionId': secId,
          'schoolId': schoolId,
          'classId': c['id'],
          'name': secName,
          'capacity': 30,
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
        });
      }
    }

    // 6. Define Realistic Indian Names Lists
    final boysNames = [
      "Aarav", "Vihaan", "Vivaan", "Kabir", "Arjun", "Aryan", "Reyansh", "Krishna", 
      "Ishaan", "Shaurya", "Atharv", "Rudra", "Dev", "Advik", "Kian", "Dhruv", 
      "Rahul", "Amit", "Vijay", "Sandeep", "Suresh", "Ramesh", "Anil", "Sanjay", 
      "Venkat", "Rajesh", "Srinivas", "Madhav", "Karthik", "Hari", "Nikhil", 
      "Pranav", "Rohan", "Aditya", "Sai", "Vikram", "Ganesh", "Abhishek", "Deepak"
    ];

    final girlsNames = [
      "Diya", "Ira", "Myra", "Ananya", "Prisha", "Ahana", "Anika", "Kiara", 
      "Pari", "Navya", "Angel", "Samaira", "Siya", "Shreya", "Kavya", "Pooja", 
      "Sneha", "Priya", "Sunita", "Anita", "Lakshmi", "Sarala", "Radha", "Shanti", 
      "Anjali", "Vijaya", "Lalitha", "Neha", "Divya", "Swati", "Ritu", "Meera", 
      "Jyoti", "Kiran", "Chitra", "Uma", "Vimala", "Geetha", "Sujatha", "Sandhya"
    ];

    final lastNames = [
      "Kumar", "Sharma", "Gupta", "Verma", "Rao", "Patel", "Deshmukh", "Malhotra", 
      "Reddy", "Devi", "Krishnan", "Swaroop", "Prasad", "Nair", "Joshi", "Pillai", 
      "Bhat", "Iyer", "Iyengar", "Das", "Banerjee", "Mukherjee", "Sen", "Roy", 
      "Singh", "Mehta", "Shah", "Choudhury", "Narayanan", "Shetty", "Gowda", 
      "Naidu", "Menon", "Kulkarni", "Deshpande", "Pande", "Misra"
    ];

    // 7. Seed Staff Users (23 Members)
    final staffList = <Map<String, dynamic>>[
      {
        'userId': 'USR_ADMIN_01',
        'schoolId': schoolId,
        'phone': '+91 9999911111',
        'email': 'rajesh.admin@eduassist.com',
        'name': 'Principal Rajesh Sharma',
        'role': 'admin',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      },
      {
        'userId': 'USR_ADMIN_02',
        'schoolId': schoolId,
        'phone': '+91 9999911112',
        'email': 'sanjay.admin@eduassist.com',
        'name': 'Mr. Sanjay Rao',
        'role': 'admin',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      },
      {
        'userId': 'USR_ADMIN_03',
        'schoolId': schoolId,
        'phone': '+91 9999911113',
        'email': 'meera.admin@eduassist.com',
        'name': 'Mrs. Meera Nair',
        'role': 'admin',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      },
    ];

    final teacherNames = [
      "Mrs. Sunita Rao", "Mrs. Anita Deshmukh", "Mrs. Priya Patel", "Mrs. Kavita Sharma",
      "Mrs. Lakshmi Reddy", "Mrs. Sarala Devi", "Mr. Amit Verma", "Mrs. Radha Krishnan",
      "Mr. Venkat Rao", "Mrs. Shanti Swaroop", "Mr. K. Prasad", "Mrs. T. Anjali",
      "Mr. Rajesh Kumar", "Mrs. P. Vijaya", "Mr. M. Srinivas", "Mrs. G. Lalitha",
      "Mr. B. Rama Rao", "Mrs. S. Mishra", "Mr. J. Mathews", "Mrs. K. Chawla"
    ];

    for (int tIdx = 0; tIdx < teacherNames.length; tIdx++) {
      final spec = (tIdx == 16) ? 'Telugu' : (tIdx == 17) ? 'Hindi' : (tIdx == 18) ? 'Social' : (tIdx == 19) ? 'Science' : 'Primary Core';
      final userId = "USR_TCH_${(tIdx + 1).toString().padLeft(2, '0')}";
      staffList.add({
        'userId': userId,
        'schoolId': schoolId,
        'phone': '+91 99999222${(tIdx + 1).toString().padLeft(2, '0')}',
        'email': '${userId.toLowerCase()}@eduassist.com',
        'name': teacherNames[tIdx],
        'role': 'teacher',
        'specialization': spec,
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });
    }

    for (var staff in staffList) {
      await _safeSet(_db.collection('users').doc(staff['userId']), staff);
    }

    // 8. Seed Parents (440 Parents)
    for (int pIdx = 1; pIdx <= 440; pIdx++) {
      final pId = "USR_PAR_${pIdx.toString().padLeft(3, '0')}";
      final name = pIdx % 2 == 0 
          ? "Mr. ${boysNames[pIdx % boysNames.length]} ${lastNames[(pIdx * 3) % lastNames.length]}"
          : "Mrs. ${girlsNames[pIdx % girlsNames.length]} ${lastNames[(pIdx * 3) % lastNames.length]}";
      
      await _safeSet(_db.collection('users').doc(pId), {
        'userId': pId,
        'schoolId': schoolId,
        'phone': '+91 98765${(10000 + pIdx).toString()}',
        'email': 'parent_${pIdx}@eduassist.com',
        'name': name,
        'role': 'parent',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });
    }

    // 9. Seed Students, Enrollments, and Parent Links (480 Students)
    for (int sIdx = 0; sIdx < 480; sIdx++) {
      final classIdx = sIdx ~/ 60; // 0 to 7
      final secIdx = (sIdx % 60) ~/ 30; // 0 (A) or 1 (B)
      final rollNo = (sIdx % 30) + 1;
      
      final cId = classes[classIdx]['id']!;
      final sId = sections[classIdx * 2 + secIdx]['sectionId']!;
      
      final studentId = "STU_2026_${cId.substring(4)}_${sId.substring(8)}_${rollNo.toString().padLeft(2, '0')}";
      final isBoy = sIdx % 2 == 0;
      final firstName = isBoy 
          ? boysNames[(sIdx * 11) % boysNames.length] 
          : girlsNames[(sIdx * 11) % girlsNames.length];
      final lastName = lastNames[(sIdx * 7) % lastNames.length];
      final studentName = "$firstName $lastName";
      
      await _safeSet(_db.collection('students').doc(studentId), {
        'studentId': studentId,
        'schoolId': schoolId,
        'name': studentName,
        'dob': '2016-${(rollNo % 12 + 1).toString().padLeft(2, '0')}-${(rollNo % 28 + 1).toString().padLeft(2, '0')}',
        'gender': isBoy ? 'male' : 'female',
        'bloodGroup': ['O+', 'A+', 'B+', 'AB+', 'O-'][(sIdx * 3) % 5],
        'address': '${100 + rollNo} Colony, Indore',
        'globalStatus': 'active',
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });

      // Enrollment
      final enrollmentId = "${studentId}_$academicYearId";
      await _safeSet(_db.collection('enrollments').doc(enrollmentId), {
        'enrollmentId': enrollmentId,
        'studentId': studentId,
        'schoolId': schoolId,
        'academicYearId': academicYearId,
        'classId': cId,
        'sectionId': sId,
        'rollNumber': rollNo,
        'enrollmentStatus': 'active',
        'updatedAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });

      // Sibling parent link model
      final parentNum = (sIdx % 440) + 1;
      final parentId = "USR_PAR_${parentNum.toString().padLeft(3, '0')}";
      final linkId = "LNK_${parentId}_$studentId";
      await _safeSet(_db.collection('parent_student_links').doc(linkId), {
        'linkId': linkId,
        'schoolId': schoolId,
        'parentId': parentId,
        'studentId': studentId,
        'relationship': isBoy ? 'father' : 'mother',
        'isEmergencyContact': true,
      });
    }

    // 10. Seed Subjects (Primary Tier: Classes 1-5 only. 5 classes * 6 subjects = 30 subjects)
    final subjectNames = ['English', 'Mathematics', 'Telugu', 'Hindi', 'Science', 'Social'];
    final subjectCodes = ['ENG', 'MATH', 'TEL', 'HIN', 'SCI', 'SOC'];
    final subjectIdMap = <String, List<String>>{}; // classId -> list of subjectIds

    for (int cIdx = 3; cIdx < classes.length; cIdx++) {
      final cId = classes[cIdx]['id']!;
      subjectIdMap[cId] = [];
      
      for (int subIdx = 0; subIdx < subjectNames.length; subIdx++) {
        final subId = "SUB_${cId.substring(4)}_${subjectCodes[subIdx]}";
        subjectIdMap[cId]!.add(subId);

        await _safeSet(_db.collection('subjects').doc(subId), {
          'subjectId': subId,
          'schoolId': schoolId,
          'academicYearId': academicYearId,
          'classId': cId,
          'name': subjectNames[subIdx],
          'code': "${subjectCodes[subIdx]}${cIdx - 2}",
          'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
        });

        // 11. Seed Syllabus Chapters (3 Chapters per Subject)
        for (int chNum = 1; chNum <= 3; chNum++) {
          final chId = "CHP_${subId}_0$chNum";
          await _safeSet(_db.collection('syllabus_chapters').doc(chId), {
            'chapterId': chId,
            'schoolId': schoolId,
            'subjectId': subId,
            'chapterNumber': chNum,
            'title': 'Chapter $chNum of ${subjectNames[subIdx]}',
            'description': 'Description for Chapter $chNum covering core foundations.',
            'topics': ['Topic $chNum.A', 'Topic $chNum.B'],
          });
        }
      }
    }

    // 12. Seed Teacher Assignments (Class + Subjects)
    // 16 Class Teacher assignments
    for (int tIdx = 0; tIdx < 16; tIdx++) {
      final s = sections[tIdx];
      await _safeSet(_db.collection('teacher_assignments').doc("ASN_CT_${s['sectionId']}"), {
        'assignmentId': "ASN_CT_${s['sectionId']}",
        'schoolId': schoolId,
        'teacherId': "USR_TCH_${(tIdx + 1).toString().padLeft(2, '0')}",
        'academicYearId': academicYearId,
        'classId': s['classId'],
        'sectionId': s['sectionId'],
        'subjectId': '',
        'assignmentType': 'class_teacher',
      });
    }

    // Subject Specialist Assignments for Classes 1 to 5
    for (int cIdx = 3; cIdx < classes.length; cIdx++) {
      final cId = classes[cIdx]['id']!;
      for (var secName in ['A', 'B']) {
        final sId = "SEC_${cId.substring(4)}_$secName";
        final ctIndex = (cIdx * 2) + (secName == 'A' ? 0 : 1);
        final ctId = "USR_TCH_${(ctIndex + 1).toString().padLeft(2, '0')}";

        final classSubjects = subjectIdMap[cId]!;
        for (int sIdx = 0; sIdx < classSubjects.length; sIdx++) {
          final subId = classSubjects[sIdx];
          final subCode = subjectCodes[sIdx];
          
          String assTeacherId = ctId; // Default is Class Teacher (English, Math, Core Science/Social)
          
          if (subCode == 'TEL') {
            assTeacherId = "USR_TCH_17"; // Telugu specialist
          } else if (subCode == 'HIN') {
            assTeacherId = "USR_TCH_18"; // Hindi specialist
          } else if (subCode == 'SOC' && cIdx < 6) {
            assTeacherId = "USR_TCH_19"; // Social specialist for Classes 1-3
          } else if (subCode == 'SCI' && cIdx >= 6) {
            assTeacherId = "USR_TCH_20"; // Science specialist for Classes 4-5
          }

          final assId = "ASN_SUB_${sId}_$subCode";
          await _safeSet(_db.collection('teacher_assignments').doc(assId), {
            'assignmentId': assId,
            'schoolId': schoolId,
            'teacherId': assTeacherId,
            'academicYearId': academicYearId,
            'classId': cId,
            'sectionId': sId,
            'subjectId': subId,
            'assignmentType': 'subject_teacher',
          });
        }
      }
    }

    // 13. Seed Timetables (Primary Classes: 10 sections * 5 days * 6 periods = 300 entries)
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final timeSlots = [
      {'start': '08:30', 'end': '09:10'},
      {'start': '09:10', 'end': '09:50'},
      {'start': '09:50', 'end': '10:30'},
      {'start': '10:30', 'end': '11:10'},
      {'start': '11:40', 'end': '12:20'},
      {'start': '12:20', 'end': '13:00'},
    ];

    for (int cIdx = 3; cIdx < classes.length; cIdx++) {
      final cId = classes[cIdx]['id']!;
      for (var secName in ['A', 'B']) {
        final sId = "SEC_${cId.substring(4)}_$secName";
        final classSubjects = subjectIdMap[cId]!;

        for (var day in daysOfWeek) {
          for (int pNum = 1; pNum <= 6; pNum++) {
            final subId = classSubjects[pNum - 1];
            final subCode = subjectCodes[pNum - 1];
            final ctIndex = (cIdx * 2) + (secName == 'A' ? 0 : 1);
            final ctId = "USR_TCH_${(ctIndex + 1).toString().padLeft(2, '0')}";

            String tId = ctId;
            if (subCode == 'TEL') {
              tId = "USR_TCH_17";
            } else if (subCode == 'HIN') {
              tId = "USR_TCH_18";
            } else if (subCode == 'SOC' && cIdx < 6) {
              tId = "USR_TCH_19";
            } else if (subCode == 'SCI' && cIdx >= 6) {
              tId = "USR_TCH_20";
            }

            final ttId = "TT_${sId}_${day.substring(0, 3)}_${pNum}";
            await _safeSet(_db.collection('timetables').doc(ttId), {
              'timetableId': ttId,
              'schoolId': schoolId,
              'academicYearId': academicYearId,
              'classId': cId,
              'sectionId': sId,
              'dayOfWeek': day,
              'periodNumber': pNum,
              'subjectId': subId,
              'teacherId': tId,
              'startTime': timeSlots[pNum - 1]['start']!,
              'endTime': timeSlots[pNum - 1]['end']!,
            });
          }
        }
      }
    }

    // 14. Seed Exams (4 Assessment cycles)
    final examsList = [
      {'id': 'EXM_UT1', 'name': 'Unit Test 1', 'term': 'Term 1', 'weight': 10.0},
      {'id': 'EXM_HY', 'name': 'Half-Yearly Exam', 'term': 'Term 1', 'weight': 30.0},
      {'id': 'EXM_UT2', 'name': 'Unit Test 2', 'term': 'Term 2', 'weight': 10.0},
      {'id': 'EXM_AN', 'name': 'Annual Exam', 'term': 'Term 2', 'weight': 50.0},
    ];

    for (var ex in examsList) {
      await _safeSet(_db.collection('exams').doc(ex['id'] as String), {
        'examId': ex['id'],
        'schoolId': schoolId,
        'academicYearId': academicYearId,
        'name': ex['name'],
        'term': ex['term'],
        'weightage': ex['weight'],
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-01T00:00:00Z')),
      });
    }

    // 15. Seed Tests & Marks (Primary UT-1 Exam Marks. 30 tests, 1,800 marks records)
    for (int cIdx = 3; cIdx < classes.length; cIdx++) {
      final cId = classes[cIdx]['id']!;
      for (var secName in ['A', 'B']) {
        final sId = "SEC_${cId.substring(4)}_$secName";
        final classSubjects = subjectIdMap[cId]!;

        for (int subIdx = 0; subIdx < classSubjects.length; subIdx++) {
          final subId = classSubjects[subIdx];
          final subCode = subjectCodes[subIdx];
          final testId = "TST_${sId}_UT1_$subCode";
          
          await _safeSet(_db.collection('tests').doc(testId), {
            'testId': testId,
            'schoolId': schoolId,
            'academicYearId': academicYearId,
            'examId': 'EXM_UT1',
            'classId': cId,
            'sectionId': sId,
            'subjectId': subId,
            'testName': 'UT-1 ${subjectNames[subIdx]} Test',
            'maxMarks': 20.0,
            'date': '2026-07-20',
            'createdBy': 'USR_TCH_07',
          });

          // Generate marks for all 30 students in this section
          for (int roll = 1; roll <= 30; roll++) {
            final studentId = "STU_2026_${cId.substring(4)}_${sId.substring(8)}_${roll.toString().padLeft(2, '0')}";
            // Deterministic score generation (between 12 and 20)
            final mathVal = (roll * 17 + subIdx * 7) % 9;
            final obtained = 12.0 + mathVal;
            final grade = obtained >= 19.0 ? 'A+' : obtained >= 17.0 ? 'A' : obtained >= 15.0 ? 'B' : obtained >= 13.0 ? 'C' : 'D';
            
            final markId = "MRK_${testId}_${studentId}";
            await _safeSet(_db.collection('marks').doc(markId), {
              'markId': markId,
              'schoolId': schoolId,
              'studentId': studentId,
              'academicYearId': academicYearId,
              'testId': testId,
              'subjectId': subId,
              'marksObtained': obtained,
              'maxMarks': 20.0,
              'status': 'present',
              'grade': grade,
              'teacherId': 'USR_TCH_07',
              'markedAt': Timestamp.fromDate(DateTime.parse('2026-07-21T10:00:00Z')),
            });
          }
        }
      }
    }

    // 16. Seed Attendance (5 working days of history * 480 students = 2,400 documents)
    final workingDays = ['2026-06-15', '2026-06-16', '2026-06-17', '2026-06-18', '2026-06-19'];
    for (int sIdx = 0; sIdx < 480; sIdx++) {
      final classIdx = sIdx ~/ 60;
      final secIdx = (sIdx % 60) ~/ 30;
      final rollNo = (sIdx % 30) + 1;
      
      final cId = classes[classIdx]['id']!;
      final sId = sections[classIdx * 2 + secIdx]['sectionId']!;
      final studentId = "STU_2026_${cId.substring(4)}_${sId.substring(8)}_${rollNo.toString().padLeft(2, '0')}";

      for (int dIdx = 0; dIdx < workingDays.length; dIdx++) {
        // ~2% absence rate logic
        final isAbsent = (sIdx * 31 + dIdx * 19) % 47 == 0;
        final docId = "ATT_${studentId}_${workingDays[dIdx]}";
        await _safeSet(_db.collection('attendance').doc(docId), {
          'attendanceId': docId,
          'schoolId': schoolId,
          'academicYearId': academicYearId,
          'studentId': studentId,
          'classId': cId,
          'sectionId': sId,
          'date': workingDays[dIdx],
          'status': isAbsent ? 'absent' : 'present',
          'markedBy': 'USR_TCH_01',
          'markedAt': Timestamp.fromDate(DateTime.parse('${workingDays[dIdx]}T08:45:00Z')),
        });
      }
    }

    // 17. Seed Fee Structures (4 structures) & Assignments (960 docs)
    final tuitionFeeId = "FST_TUTION_26";
    final activityFeeId = "FST_ACTIVITY_26";
    
    // Correctly using Timestamp for dueDate in Firestore
    final tutionDueDate = Timestamp.fromDate(DateTime.parse('2026-06-30T23:59:59Z'));
    final activityDueDate = Timestamp.fromDate(DateTime.parse('2026-06-15T23:59:59Z'));

    await _safeSet(_db.collection('fee_structures').doc(tuitionFeeId), {
      'feeStructureId': tuitionFeeId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'title': 'Quarter 1 Tuition Fee',
      'amount': 12000.0,
      'dueDate': tutionDueDate,
    });

    await _safeSet(_db.collection('fee_structures').doc(activityFeeId), {
      'feeStructureId': activityFeeId,
      'schoolId': schoolId,
      'academicYearId': academicYearId,
      'title': 'Annual School Activities Fee',
      'amount': 3000.0,
      'dueDate': activityDueDate,
    });

    for (int sIdx = 0; sIdx < 480; sIdx++) {
      final classIdx = sIdx ~/ 60;
      final secIdx = (sIdx % 60) ~/ 30;
      final rollNo = (sIdx % 30) + 1;
      
      final cId = classes[classIdx]['id']!;
      final sId = sections[classIdx * 2 + secIdx]['sectionId']!;
      final studentId = "STU_2026_${cId.substring(4)}_${sId.substring(8)}_${rollNo.toString().padLeft(2, '0')}";

      // Tuition Fee Assignment (Section A = Paid, Section B = Pending for metrics demonstration)
      final status = (secIdx == 0) ? 'paid' : 'pending';
      final paidAmtTuition = (secIdx == 0) ? 12000.0 : 0.0;
      final paidAmtActivity = (secIdx == 0) ? 3000.0 : 0.0;

      final asnTutionId = "FAS_TUTION_${studentId}";
      await _safeSet(_db.collection('fee_assignments').doc(asnTutionId), {
        'feeAssignmentId': asnTutionId,
        'schoolId': schoolId,
        'studentId': studentId,
        'academicYearId': academicYearId,
        'feeStructureId': tuitionFeeId,
        'title': 'Quarter 1 Tuition Fee',
        'amount': 12000.0,
        'discount': 0.0,
        'netAmount': 12000.0,
        'status': status,
        'amountPaid': paidAmtTuition,
        'dueDate': tutionDueDate,
      });

      final asnActivityId = "FAS_ACTIVITY_${studentId}";
      await _safeSet(_db.collection('fee_assignments').doc(asnActivityId), {
        'feeAssignmentId': asnActivityId,
        'schoolId': schoolId,
        'studentId': studentId,
        'academicYearId': academicYearId,
        'feeStructureId': activityFeeId,
        'title': 'Annual School Activities Fee',
        'amount': 3000.0,
        'discount': 0.0,
        'netAmount': 3000.0,
        'status': status,
        'amountPaid': paidAmtActivity,
        'dueDate': activityDueDate,
      });
    }

    // 18. Seed Classroom Updates & Homework (32 updates)
    for (int sIdx = 0; sIdx < 16; sIdx++) {
      final s = sections[sIdx];
      final isFoundation = s['classId']!.contains('NUR') || s['classId']!.contains('LKG') || s['classId']!.contains('UKG');

      for (int updIdx = 1; updIdx <= 2; updIdx++) {
        final updId = "UPD_${s['sectionId']}_0$updIdx";
        
        final topic = isFoundation 
            ? "Milestone Block $updIdx: Learning social habits & motor coordinates."
            : "Chapter 1 Focus: Core basics and initial assignment review.";
        final hw = isFoundation
            ? "Encourage tracing circle shapes at home."
            : "Complete all textbook exercises from Chapter 1 Section $updIdx.";

        await _safeSet(_db.collection('classroom_updates').doc(updId), {
          'updateId': updId,
          'schoolId': schoolId,
          'academicYearId': academicYearId,
          'teacherId': "USR_TCH_${(sIdx + 1).toString().padLeft(2, '0')}",
          'classId': s['classId'],
          'sectionId': s['sectionId'],
          'subjectId': isFoundation ? '' : "SUB_${s['classId']!.substring(4)}_ENG",
          'chapterId': isFoundation ? null : "CHP_SUB_${s['classId']!.substring(4)}_ENG_01",
          'topicCovered': topic,
          'homework': hw,
          'photoUrl': 'https://images.unsplash.com/photo-1577896851231-70ef18881754',
          'date': '2026-06-18',
          'timestamp': Timestamp.fromDate(DateTime.parse('2026-06-18T14:30:00Z')),
        });
      }
    }

    // 19. Seed School and Class Announcements (12 Docs)
    final announcements = [
      {
        'id': 'ANC_SCH_01',
        'title': 'Annual Sports Day Celebrations 2026',
        'body': 'Vidyalaya School is hosting the annual track celebrations starting next Friday. Parents are welcome!',
        'scope': 'school',
        'targetClassId': null,
      },
      {
        'id': 'ANC_SCH_02',
        'title': 'School Holiday Notice',
        'body': 'School remains closed on Monday, 22nd June in observance of the local festival.',
        'scope': 'school',
        'targetClassId': null,
      },
    ];

    // Seed 10 Class-specific notices
    for (int cIdx = 3; cIdx < classes.length; cIdx++) {
      final cId = classes[cIdx]['id']!;
      final cName = classes[cIdx]['name']!;
      announcements.add({
        'id': 'ANC_CLS_${cId}_A',
        'title': '$cName Section A Science Project Submit',
        'body': 'All students of $cName-A must submit their science models by this Friday morning.',
        'scope': 'class',
        'targetClassId': cId,
      });
      announcements.add({
        'id': 'ANC_CLS_${cId}_B',
        'title': '$cName Section B Telugu Oral Quiz',
        'body': 'We will host a Telugu reading quiz on Thursday. Bring reader books.',
        'scope': 'class',
        'targetClassId': cId,
      });
    }

    for (var anc in announcements) {
      await _safeSet(_db.collection('announcements').doc(anc['id'] as String), {
        'announcementId': anc['id'],
        'schoolId': schoolId,
        'title': anc['title'],
        'body': anc['body'],
        'scope': anc['scope'],
        'targetClassId': anc['targetClassId'],
        'createdAt': Timestamp.fromDate(DateTime.parse('2026-06-15T09:00:00Z')),
      });
    }

    // 20. Log System Initialization
    final logId = "LOG_SYSTEM_SEED_2026";
    await _safeSet(_db.collection('audit_logs').doc(logId), {
      'logId': logId,
      'schoolId': schoolId,
      'userId': 'USR_ADMIN_01',
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'action': 'COMPREHENSIVE_SCHOOL_INIT_SEED',
      'entityType': 'schools',
      'entityId': schoolId,
      'beforeState': {},
      'afterState': {'seeded': true, 'totalWrites': _totalWrites},
    });

    await _flushBatch();
    print("DatabaseSeeder: Seeding completed successfully with $_totalWrites document writes.");
  }
}
