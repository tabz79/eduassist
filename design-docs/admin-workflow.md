# EduAssist - Admin Workflow Specification

# Purpose

This document defines the complete Admin Workflow for EduAssist.

The Admin App is the operational backbone of the school.

While Teachers handle academics and Parents consume information, Admin manages the entire school ecosystem.

The Admin role controls:

* Academic Setup
* Student Lifecycle
* Teacher Lifecycle
* Parent Linking
* Timetables
* Examinations
* Fees
* Communication
* Academic Monitoring

---

# Admin Role Overview

Admin is responsible for ensuring the school operates smoothly.

Depending on school size, Admin may represent:

* Principal
* Vice Principal
* Office Staff
* Academic Coordinator
* Accounts Staff

For EduAssist V1, all responsibilities are combined under a single Admin role.

---

# Admin Responsibilities

Admin manages:

* Academic Year
* Classes
* Sections
* Subjects
* Students
* Teachers
* Parent Linking
* Timetables
* Exams
* Fees
* Announcements

Admin does NOT teach.

Admin configures and monitors the system.

---

# School Initialization Workflow

## Purpose

Prepare a newly onboarded school for operations.

---

## Step 1: Academic Year Creation

Admin creates:

Academic Year

Example:

2026–2027

Only one active academic year exists at a time.

---

## Step 2: Class Creation

Admin creates:

* Nursery
* LKG
* UKG
* Class 1
* Class 2
* ...
* Class 10

---

## Step 3: Section Creation

Example:

Class 5

Sections:

* 5A
* 5B
* 5C
* 5D

---

## Section Capacity

Admin defines:

Maximum Students

Example:

5A → 30 Students

---

# Subject Management Workflow

## Purpose

Define curriculum structure.

---

## Example

Class 5

Subjects:

* Mathematics
* Science
* English
* Social Studies
* Hindi
* Computer

---

## Rules

Subjects belong to:

* Class
* Academic Year

Changes in future years should not alter historical records.

---

# Teacher Lifecycle Workflow

## Teacher Creation

Admin creates teacher profile.

Fields:

* Name
* Mobile Number
* Employee Code
* Specialization
* Joining Date

---

## Teacher IDs

System ID:

TCH7P9M3

Permanent

Employee Code:

EMP-001

Human Facing

---

## Teacher Status

* Active
* On Leave
* Resigned
* Retired

---

## Subject Assignment

Example:

Mrs. Nesaria

Subjects:

* Mathematics

Classes:

* 5A
* 5B
* 5C
* 5D

---

## Class Teacher Assignment

Example:

Class 5A

Class Teacher:

Mrs. Priya

Only one active class teacher per class.

---

# Student Lifecycle Workflow

## Student Admission

Admin creates student record.

Fields:

* Name
* DOB
* Gender
* Address
* Parent Information

---

## Student IDs

System ID:

STU8K4X2

Permanent

Admission Number:

2026-001

Human Facing

---

## Student Status

* Inquiry
* Applied
* Under Review
* Approved
* Enrolled
* Active
* Transferred
* Graduated
* Dropped

---

## Section Assignment

Example:

Student

Rahul Sharma

Assigned:

Class 5A

Roll Number 12

---

## Roll Number Rules

Roll Numbers:

* Are not permanent
* May change yearly
* Belong to Enrollment Record

Student ID never changes.

---

# Parent Lifecycle Workflow

## Parent Creation

Parent created automatically or manually.

---

## Parent IDs

System ID:

PAR4N8Q1

Permanent

---

## Parent Linking

Parent linked to student.

Supports:

* Mother
* Father
* Guardian

---

## Multiple Children Support

One parent can be linked to multiple students.

---

## Parent Access Control

Admin can:

* Approve Access
* Revoke Access

---

# Enrollment Workflow

## Purpose

Track yearly academic placement.

---

## Example

Student:

Rahul Sharma

Academic Year:

2026–2027

Class:

5A

Roll Number:

12

---

## Importance

Student remains permanent.

Enrollment changes every year.

---

# Timetable Workflow

## Purpose

Manage daily teaching schedule.

---

## Admin Actions

Create:

* Periods
* Subjects
* Teacher Assignments

---

## Example

Period 1

Mathematics

Mrs. Nesaria

Class 5A

---

## Dynamic Changes

Supports:

* Substitutions
* Temporary Replacements
* Leave Coverage

---

# Examination Workflow

## Purpose

Allow school-defined examination structures.

---

## Exam Configuration

Admin creates:

* Unit Test 1
* Unit Test 2
* Quarterly
* Half Yearly
* Annual

or any custom structure.

---

## Exam Status

* Draft
* Active
* Completed
* Published
* Locked

---

## Locking

After publication:

Marks become read-only.

Prevents accidental modifications.

---

# Question Paper Workflow

## Purpose

Store academic papers.

---

## Admin Visibility

Can view:

* Uploaded Papers
* Subjects
* Exam Types

---

## Teacher Uploads

Tagged by:

* Class
* Subject
* Exam

---

# Academic Monitoring Workflow

## Purpose

Monitor syllabus completion.

---

## View

Subject Progress

Example:

Mathematics

Completed:
8 Chapters

Current:
Fractions

Pending:
5 Chapters

---

## Monitoring

Admin can identify:

* Delayed Subjects
* Incomplete Syllabus
* Academic Risks

---

# Marks Monitoring Workflow

## Purpose

Track result readiness.

---

## Example

Quarterly Exam

Mathematics ✓

Science ✓

English ✗

Social ✓

---

## Benefits

Identify pending entries before report card generation.

---

# Report Card Workflow

## Purpose

Publish academic reports.

---

## Flow

Teachers Enter Marks

↓

Class Teacher Reviews

↓

System Generates Report

↓

Admin Reviews

↓

Publish

---

## Status

* Draft
* Published
* Locked

---

# Communication Workflow

## Purpose

School-wide communication.

---

## Admin Announcements

Examples:

* Holiday Notice
* Exam Schedule
* Emergency Notice
* Fee Reminder

---

## Visibility

Parents

Teachers

Both

---

# Teacher Leave Workflow

## Submission

Teacher submits leave request.

---

## Admin Actions

* Approve
* Reject

---

## Substitute Assignment

Admin may assign temporary replacement.

---

# Academic Ownership Transfer Workflow

## Purpose

Handle long-term teacher absences.

---

## Example

From:

Mrs. Nesaria

To:

Mrs. Kavita

Subject:

Mathematics

Class:

5A

---

## Transfer Includes

* Chapters
* Marks
* Tests
* Academic History

No data loss.

---

# Fee Lifecycle Workflow

## Purpose

Manage fee collection.

---

## Fee Structure Creation

Example:

Class 5

Tuition Fee

Annual Fee

Computer Fee

---

## Fee Assignment

Assigned to students.

---

## Payment Modes

* Cash
* UPI
* Online
* Bank Transfer

---

## Fee Status

* Paid
* Partial
* Pending
* Overdue

---

## Receipt Generation

Receipt Number generated.

Permanent.

Never reused.

---

## Fee Ledger

Every transaction recorded.

Never overwritten.

---

# Student Promotion Workflow

## Purpose

Move students to next class.

---

## Example

Class 5A

↓

Class 6A

---

## Preserve

* Attendance
* Marks
* Report Cards
* Academic History

---

# Student Transfer Workflow

## Purpose

Handle school exits.

---

## Example

Student relocates.

Admin:

* Marks Transferred
* Archives Record

History remains available.

---

# Student Graduation Workflow

## Purpose

Handle Class 10 completion.

---

## Status

Graduated

---

## Preserve

All historical records.

---

# Audit Trail Workflow

## Purpose

Track critical actions.

---

## Examples

Marks Changed

Teacher Assignment Changed

Fee Modified

Student Promoted

---

## Log Data

Who

What

When

---

# School Assets & Documents

## Student Documents

* Birth Certificate
* Aadhaar
* Transfer Certificate
* Previous Marks Memo

---

## Teacher Documents

* ID Proof
* Qualification Records

---

# Admin Dashboard

Displays:

* Total Students
* Total Teachers
* Attendance %
* Pending Fees
* Upcoming Exams
* Recent Admissions
* Active Announcements

---

# V1 Admin Priorities

Must Have

* Academic Year Setup
* Classes
* Sections
* Subjects
* Teachers
* Students
* Parent Linking
* Timetable
* Exams
* Fees
* Promotions
* Transfers
* Announcements

Should Have

* Ownership Transfer
* Academic Monitoring
* Audit Logs

Future

* Transport Management
* Inventory Requests
* Advanced Analytics
* AI Insights

---

# Core Principle

Admin should be able to run the entire school from a single system without relying on spreadsheets, registers, WhatsApp groups, or disconnected tools.
