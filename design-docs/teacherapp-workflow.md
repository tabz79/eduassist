# EduAssist - Teacher Workflow Specification

## Purpose

This document defines the complete Teacher Workflow for EduAssist.

The objective is not to create a feature-rich app.

The objective is to create a practical system that teachers will actually use every day.

All workflows must minimize teacher effort and administrative burden.

---

# Teacher Role Overview

A teacher may act in one or both of the following capacities:

## Class Teacher

Responsible for:

* Daily attendance
* Parent communication
* Student welfare
* Class announcements
* Report card review
* General ownership of a class

Example:

Class 5A → Mrs. Priya

---

## Subject Teacher

Responsible for:

* Teaching assigned subjects
* Posting class updates
* Assigning homework
* Conducting tests
* Entering marks
* Maintaining syllabus progress

Example:

Mathematics Teacher

Assigned Classes:

* Class 5
* Class 6
* Class 7

A teacher may simultaneously be:

* Class Teacher
* Subject Teacher

---

# Teacher Dashboard

## Purpose

Provide immediate visibility into pending work.

Teachers are task-driven.

Dashboard should focus on tasks, not analytics.

---

## Dashboard Components

### Today's Classes

Displays:

* Period
* Class
* Subject

Example:

Period 1 → Class 5 Maths

Period 2 → Class 6 Maths

---

### Attendance Status

Displays:

* Pending
* Completed

For assigned class teacher only.

---

### Pending Tasks

Examples:

* Marks Entry Pending
* Upcoming Exam
* Class Update Pending

---

### School Announcements

Administrative notices from school management.

---

# Attendance Workflow

## Attendance Ownership

Attendance is taken by the Class Teacher during the first period.

Only one attendance record exists per student per day.

---

## Attendance States

* Present
* Absent
* Reported Absent

---

## Reported Absent

Generated when parent submits absence request.

Example:

Student Sick

Parent submits:

* From Date
* To Date
* Reason

Teacher sees:

Reported Absent

during attendance process.

---

## Attendance Process

Class Teacher:

1. Opens Class
2. Views Student List
3. Marks Attendance
4. Submits

Completion Time Goal:

Less than 1 minute.

---

# Class Updates Workflow

## Purpose

Document what happened during class.

Provides visibility to:

* Parents
* Admin
* School Management

---

## Teacher Actions

Select:

* Class
* Subject
* Chapter

Enter:

* Topic Covered (Free Text)
* Homework (Optional)
* Notes (Optional)

Upload:

* Blackboard Photo (Optional)

Publish

---

## Example

Class: 5

Subject: Mathematics

Chapter: Fractions

Topic Covered:

Addition of Fractions

Homework:

Exercise 4

Photo:

Blackboard Image

---

# Homework Workflow

## Purpose

Digitally communicate homework.

Homework checking remains offline.

System only records assigned homework.

---

## Teacher Actions

Homework may be entered through:

* Class Update
* Free Text
* Blackboard Photo

No homework completion tracking in V1.

No notebook tracking in V1.

---

# Syllabus Tracking Workflow

## Purpose

Track chapter-level syllabus progress.

Not topic-level.

Not textbook-level.

---

## Initial Setup

At beginning of academic year:

Teacher or Admin creates chapters.

Example:

Class 5

Subject: Mathematics

Chapters:

* Numbers
* Fractions
* Decimals
* Geometry
* Measurement

---

## Daily Usage

Teacher selects chapter while posting Class Update.

Example:

Chapter:

Fractions

Topic:

Equivalent Fractions

---

## Progress States

* Not Started
* In Progress
* Completed

---

## Benefits

Allows:

* Teacher Progress Tracking
* Parent Visibility
* Admin Monitoring

without additional reporting effort.

---

# Test Workflow

## Purpose

Support informal classroom assessments.

Examples:

* Weekly Test
* Surprise Test
* Oral Test
* Chapter Test

---

## Teacher Actions

Create Test

Select:

* Class
* Subject
* Chapter(s)
* Maximum Marks

Enter:

* Test Name

Example:

Fractions Assessment

---

## Marks Entry

Teacher enters:

Student A → 18

Student B → 15

Student C → Absent

Submit

---

# Examination Workflow

## Principle

Exam structure is configurable by school.

EduAssist must not enforce a fixed pattern.

---

## Examples

School A

* Unit Test 1
* Unit Test 2
* Quarterly
* Half Yearly
* Annual

School B

* Assessment 1
* Assessment 2
* Term 1
* Term 2

System supports all models.

---

# Exam Lifecycle

## Step 1

Admin creates exam.

---

## Step 2

Teacher receives exam schedule.

---

## Step 3

Teacher completes syllabus.

---

## Step 4

Teacher prepares question paper.

Outside EduAssist in V1.

---

## Step 5

Teacher conducts exam.

---

## Step 6

Teacher evaluates answer sheets.

---

## Step 7

Teacher enters marks.

---

## Step 8

Class Teacher reviews completion status.

---

## Step 9

Report Card generated.

---

## Step 10

Parents view results.

---

# Marks Entry Workflow

## Purpose

Capture academic performance.

---

## Teacher Actions

Select:

* Exam
* Subject
* Class

Enter:

Marks for each student.

---

## Student Status

* Present
* Absent
* Exempted

---

## Validation

Marks cannot exceed maximum marks.

---

# Report Card Workflow

## Principle

Teachers should not manually create report cards.

System generates them automatically.

---

## Data Sources

* Exam Marks
* Subject Marks
* Teacher Remarks

---

## Class Teacher Responsibilities

Review

Approve

Publish

---

# Question Paper Repository

## Purpose

Store previous papers for future use.

---

## Teacher Actions

Upload:

* PDF
* DOCX

Tag:

* Class
* Subject
* Exam

---

## Example

Class 5

Mathematics

Unit Test 1

2026

Upload

---

## Benefits

Future teachers can access historical papers.

---

# Announcements Workflow

## Purpose

Broadcast information.

Not chat.

---

## Teacher Actions

Create Announcement

Select:

* Class
* Subject (Optional)

Enter Message

Publish

---

## Examples

* Unit Test on Monday
* Bring Drawing Book Tomorrow
* Science Project Submission Friday

---

# Leave Management Workflow

## Teacher Actions

Submit Leave Request

Enter:

* Start Date
* End Date
* Reason

Submit

---

## Admin Actions

* Approve
* Reject

---

# Academic Ownership Workflow

## Purpose

Handle teacher transfers and long absences.

---

## Example

Mrs. Nesaria

Class 5 Mathematics

Completed:

* Numbers
* Fractions

Current:

* Decimals

---

## Long-Term Leave

Admin transfers ownership.

From:

Mrs. Nesaria

To:

Mrs. Priya

Effective Date:

July 1

---

## Transfer Includes

* Chapters Covered
* Marks History
* Tests
* Class Updates
* Academic Records

No data loss.

---

# Substitute Teacher Workflow

## Short-Term Absence

Example:

One Day Leave

Admin assigns substitute.

Ownership remains unchanged.

After absence:

Original teacher resumes.

---

# Timetable Workflow

## Teacher View

Displays:

* Period
* Class
* Subject

---

## Dynamic Adjustments

Supports:

* Substitutions
* Temporary Assignments
* Teacher Leave Coverage

---

# Student Profile View

Teacher can view:

* Student Information
* Attendance Summary
* Marks Summary
* Parent Information
* Academic History

Read-only in V1.

---

# Teacher App Navigation

Home

My Classes

Exams

Question Papers

Announcements

Profile

---

# V1 Teacher Priorities

Must Have

* Dashboard
* Attendance
* Class Updates
* Homework Posting
* Syllabus Tracking
* Tests
* Marks Entry
* Exams
* Report Cards
* Announcements

Should Have

* Question Paper Repository
* Leave Requests

Future

* AI Question Paper Generation
* Detailed Behavior Tracking
* Homework Completion Tracking
* Topic-Level Curriculum Mapping
* Learning Outcome Tracking

---

# Core Principle

Every teacher feature must answer:

"Will a busy teacher realistically use this every week?"

If the answer is no, it does not belong in V1.

# Admin → Teacher Data Flow

Admin Creates:

Academic Year

Teacher Receives:
Active Academic Session

---

Admin Creates:

Classes

Teacher Receives:
Assigned Classes

---

Admin Creates:

Subjects

Teacher Receives:
Assigned Subjects

---

Admin Assigns:

Class Teacher

Teacher Receives:
Class Ownership

---

Admin Assigns:

Subject Teacher

Teacher Receives:
Teaching Responsibility

---

Admin Creates:

Timetable

Teacher Receives:
Daily Schedule

---

Admin Creates:

Exam Structure

Teacher Receives:
Exam Schedule

---

Admin Activates:

Exam

Teacher Receives:
Marks Entry Access

---

Admin Publishes:

School Announcement

Teacher Receives:
Administrative Notice

---

Admin Approves:

Leave Request

Teacher Receives:
Leave Status

---

Admin Assigns:

Substitute Duty

Teacher Receives:
Temporary Class Assignment

---

Admin Transfers:

Academic Ownership

Teacher Receives:
New Subject Ownership

---

# My Assignments Workflow

## Purpose

Provide visibility into all teacher responsibilities.

---

## Data Source

Admin Teacher Assignment Module

---

## Teacher View

Displays:

* Assigned Classes
* Assigned Subjects
* Class Teacher Assignments
* Additional Responsibilities

---

## Example

Mrs. Priya

Class Teacher:
5A

Subjects:

* Science (5A)
* Science (5B)
* Science (6A)

---

# School Announcements Workflow

## Purpose

Provide administrative communication to teachers.

---

## Data Source

Admin Communication Module

---

## Teacher View

Displays:

* Title
* Message
* Date
* Priority

---

## Examples

Quarterly Exams Begin Next Week

---

School Closed Tomorrow

---

Staff Meeting At 4 PM

---

# Academic Calendar Workflow

## Purpose

Provide visibility into important academic events.

---

## Data Source

Admin Academic Calendar

---

## Teacher View

Displays:

* School Holidays
* Exam Dates
* Parent Teacher Meetings
* Annual Day
* Sports Day
* School Events

---

# Timetable Assignment Workflow

## Purpose

Provide daily teaching schedule.

---

## Data Source

Admin Timetable Module

---

## Teacher View

Displays:

* Period
* Class
* Subject
* Room (Optional)

---

## Example

Period 1

Mathematics

Class 5A

---

Period 2

Mathematics

Class 5B

---

# Examination Assignment Workflow

## Purpose

Inform teachers about upcoming assessments.

---

## Data Source

Admin Examination Module

---

## Teacher View

Displays:

* Exam Name
* Applicable Classes
* Schedule
* Marks Entry Deadlines

---

## Example

Unit Test 1

Classes:
5A, 5B

Marks Submission Deadline:
20 July

---

# Leave Approval Workflow

## Purpose

Allow teachers to track leave requests.

---

## Teacher View

Displays:

* Pending
* Approved
* Rejected

---

## Example

Leave Request

10 July – 12 July

Status:
Approved

---

# Substitute Assignment Workflow

## Purpose

Handle short-term teacher absences.

---

## Data Source

Admin Leave Management

---

## Teacher View

Displays:

Original Teacher:
Mrs. Nesaria

Assigned Class:
5A

Subject:
Mathematics

Date:
15 July

---

# Academic Ownership Transfer Workflow

## Purpose

Handle long-term teacher replacements.

---

## Data Source

Admin Academic Ownership Module

---

## Teacher View

Displays:

Transferred From:
Mrs. Nesaria

Subject:
Mathematics

Class:
5A

Effective Date:
1 October

---

## Teacher Receives

* Chapter Progress
* Test History
* Marks History
* Class Updates
* Academic Records

---

# Student Admission Notification Workflow

## Purpose

Notify teachers about newly admitted students.

---

## Data Source

Admin Student Management

---

## Teacher View

Displays:

New Student Added

Student:
Rahul Sharma

Class:
5A

Roll Number:
12

---

# Student Transfer Notification Workflow

## Purpose

Notify teachers when students leave the class.

---

## Data Source

Admin Student Management

---

## Teacher View

Displays:

Student Transfer Completed

Student:
Rahul Sharma

Class:
5A

---

# Student Promotion Workflow

## Purpose

Inform teachers about new academic year assignments.

---

## Teacher View

Displays:

Previous Class:
5A

Current Class:
6A

Academic Year:
2027–2028

Updated Student Roster Available
