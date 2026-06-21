# EduAssist - Parent App Workflow Specification

# Purpose

This document defines the complete Parent App Workflow for EduAssist.

This document focuses only on workflows that directly impact parents and the data that flows from the Teacher App into the Parent App.

The Parent App is not an administration tool.

The Parent App is a visibility and communication tool that helps parents stay connected with their child's academic journey.

---

# Parent Role Overview

The Parent App answers three fundamental questions:

1. Did my child attend school today?
2. What did my child learn today?
3. How is my child performing?

Everything inside the Parent App should support one of these objectives.

---

# Parent Responsibilities

Unlike teachers and admins, parents do not manage school operations.

Parents primarily:

* View information
* Receive notifications
* Track academic progress
* Submit absence requests
* Download reports

The Parent App should remain simple and non-technical.

---

# Parent Dashboard

## Purpose

Provide a quick overview of the child's school day.

The dashboard should immediately answer:

* Was my child present?
* Any homework?
* Any announcements?
* Any upcoming tests?
* Any new marks?

---

## Dashboard Components

### Student Information Card

Displays:

* Student Name
* Class
* Section (if applicable)
* Roll Number
* Academic Year

---

### Today's Attendance

Displays:

* Present
* Absent
* Reported Absent

Source:

Teacher Attendance Module

---

### Today's Classroom Updates

Displays latest updates posted by teachers.

Examples:

Mathematics

Chapter:
Fractions

Topic:
Equivalent Fractions

---

### Homework Summary

Displays:

* Subject
* Homework Assigned
* Date

---

### Upcoming Tests

Displays:

* Test Name
* Subject
* Test Date

---

### Latest Announcements

Displays:

* School Notices
* Teacher Notices

---

# Attendance Workflow

## Data Source

Teacher Attendance Module

Attendance is controlled entirely by teachers.

Parents cannot modify attendance records.

---

## Parent View

Parents can see:

* Daily Attendance Status
* Monthly Attendance Summary
* Attendance Percentage

---

## Attendance States

* Present
* Absent
* Reported Absent

---

## Attendance History

Parents can view attendance records for previous dates.

---

# Absence Reporting Workflow

## Purpose

Allow parents to notify the school in advance.

---

## Parent Actions

Submit Absence Request

Enter:

* From Date
* To Date
* Reason

Optional:

* Doctor Note Attachment

Submit

---

## Teacher Visibility

Teacher sees:

Reported Absent

during attendance marking.

---

## Parent Status

Parents can view:

* Submitted
* Approved
* Acknowledged

---

# Classroom Updates Workflow

## Purpose

Provide visibility into classroom activities.

---

## Data Source

Teacher Class Updates Module

---

## Teacher Posts

Teacher may submit:

* Subject
* Chapter
* Topic Covered
* Homework
* Blackboard Photo

---

## Parent View

Displays:

Subject

Chapter Covered

Topic Covered

Homework

Photo (if available)

---

## Example

Mathematics

Chapter:
Fractions

Topic:
Addition of Fractions

Homework:
Exercise 4

Photo:
Blackboard Image

---

# Homework Workflow

## Purpose

Help parents understand assigned work.

---

## Data Source

Teacher Class Updates

---

## Parent View

Displays:

* Subject
* Homework Description
* Date Assigned

Optional:

* Blackboard Image

---

## V1 Limitation

No homework submission.

No homework grading.

No homework completion tracking.

Homework remains offline.

---

# Syllabus Progress Workflow

## Purpose

Allow parents to understand academic progress.

---

## Data Source

Teacher Syllabus Tracking

---

## Parent View

Subject-wise progress.

Example:

Mathematics

Completed Chapters:
8

Current Chapter:
Fractions

Pending Chapters:
5

---

## Chapter View

Parents may view:

* Chapter Name
* Status

Status:

* Not Started
* In Progress
* Completed

---

# Test Workflow

## Purpose

Inform parents about upcoming assessments.

---

## Data Source

Teacher Test Module

---

## Parent View

Displays:

* Test Name
* Subject
* Date
* Chapters Included

---

## Example

Fractions Assessment

Date:
15 July

Subject:
Mathematics

Coverage:
Fractions

---

# Marks Workflow

## Purpose

Allow parents to monitor academic performance.

---

## Data Source

Teacher Marks Entry

---

## Parent View

Displays:

* Subject
* Marks Obtained
* Maximum Marks
* Percentage

---

## Example

Mathematics

18 / 20

90%

---

# Academic Performance View

## Purpose

Provide subject-wise performance visibility.

---

## Parent View

Displays:

* Subject Performance
* Test History
* Marks History

---

## Example

Mathematics

Fractions Test:
18/20

Decimals Test:
17/20

Unit Test:
86/100

---

# Report Card Workflow

## Purpose

Provide formal academic reports.

---

## Data Source

Teacher Marks + Exam System

---

## Parent View

View Report Card

Download PDF

Store Historical Report Cards

---

## Historical Access

Parents can access:

* Unit Test Reports
* Quarterly Reports
* Half Yearly Reports
* Annual Reports

Based on school exam structure.

---

# Announcements Workflow

## Purpose

Replace fragmented communication channels.

---

## Data Source

Teacher Announcements

School Administration

---

## Parent View

Displays:

* Announcement Title
* Message
* Date

---

## Examples

Unit Test on Monday

Bring Drawing Book Tomorrow

Science Exhibition This Friday

School Holiday Tomorrow

---

# Teacher Information Workflow

## Purpose

Provide visibility into the child's assigned teachers.

---

## Parent View

Displays:

Class Teacher

Subject Teachers (Optional)

---

## Example

Class Teacher

Mrs. Priya

Mathematics

Mrs. Nesaria

Science

Mr. Ravi

---

# Student Academic Timeline

## Purpose

Provide a chronological view of school activities.

This becomes the central feed of the Parent App.

---

## Timeline Events

Attendance Marked

Class Update Posted

Homework Assigned

Test Scheduled

Marks Published

Report Card Released

Announcement Received

---

## Example Timeline

June 10

Present

---

June 10

Mathematics

Fractions Covered

Homework Assigned

---

June 12

Fractions Assessment Scheduled

---

June 15

Marks Published

18/20

---

# Notifications Workflow

## Purpose

Keep parents informed without opening the app.

---

## Notification Types

Attendance

Homework

Class Updates

Test Reminders

Marks Published

Report Cards Available

Announcements

---

## Examples

Your child is marked Present today.

New homework assigned in Mathematics.

Unit Test begins tomorrow.

Marks published for Fractions Assessment.

---

# Parent Profile

Displays:

* Parent Name
* Mobile Number
* Linked Students

---

# Multiple Children Support

A parent may have:

* One Child
* Two Children
* Multiple Children

---

## Parent View

Switch Between Students

Example:

Child 1

Class 5

Child 2

Class 8

---

# Parent App Navigation

Home

Timeline

Academics

Attendance

Report Cards

Announcements

Profile

---

# Teacher → Parent Data Flow

Teacher Creates:

Attendance

Parent Receives:
Attendance Status

---

Teacher Creates:

Class Update

Parent Receives:
Lesson Summary

---

Teacher Creates:

Homework

Parent Receives:
Homework Notification

---

Teacher Creates:

Test

Parent Receives:
Upcoming Assessment

---

Teacher Creates:

Marks

Parent Receives:
Performance Update

---

Teacher Creates:

Announcement

Parent Receives:
Notification

---

Teacher Creates:

Report Card

Parent Receives:
Academic Report

---

# V1 Parent Priorities

Must Have

* Dashboard
* Attendance
* Classroom Updates
* Homework Visibility
* Syllabus Progress
* Tests
* Marks
* Report Cards
* Announcements
* Absence Reporting
* Notifications

Should Have

* Academic Timeline
* Multiple Children Support

Future

* Parent-Teacher Appointment Requests
* Homework Tracking
* Assignment Submission
* AI Academic Insights
* Learning Recommendations

---

# Core Principle

Parents should never have to ask:

"What happened in school today?"

The Parent App should answer that question automatically through attendance, classroom updates, homework, assessments, and academic progress.

# Admin → Parent Data Flow

Admin Creates:

Student Profile

Parent Receives:
Student Information

---

Admin Creates:

Academic Calendar

Parent Receives:
School Schedule

---

Admin Creates:

School Announcement

Parent Receives:
School Notification

---

Admin Creates:

Fee Structure

Parent Receives:
Fee Information

---

Admin Records:

Fee Payment

Parent Receives:
Payment History

---

Admin Generates:

Receipt

Parent Receives:
Downloadable Receipt

---

Admin Processes:

Promotion

Parent Receives:
Updated Class Assignment

---

Admin Processes:

Transfer

Parent Receives:
Transfer Status

---

Admin Uploads:

Student Documents

Parent Receives:
Document Access

---

Admin Creates:

Emergency Notice

Parent Receives:
Urgent Alert

---

# Child Profile Workflow

## Purpose

Provide a complete snapshot of the child.

This becomes the primary identity screen of the Parent App.

Parents think in terms of:

"My Child"

rather than

"Attendance"

or

"Fees"

or

"Marks"

---

## Data Source

Student Management

Teacher Assignment

Attendance System

Academic System

Fee System

---

## Parent View

Displays:

### Student Information

* Student Photo
* Student Name
* Admission Number
* Class
* Section
* Roll Number
* Academic Year

---

### Academic Information

* Class Teacher
* Attendance Percentage
* Current Academic Status

---

### Fee Information

* Fee Status
* Outstanding Amount
* Next Due Date

---

### Latest Academic Performance

* Latest Test Marks
* Latest Report Card Status

---

## Example

Student:
Rahul Sharma

Admission Number:
2026-001

Class:
5A

Roll Number:
12

Class Teacher:
Mrs. Priya

Attendance:
94%

Fee Status:
Paid

Latest Result:
18/20 Mathematics

---

# Student Information Workflow

## Purpose

Provide official student information.

---

## Data Source

Admin Student Management

---

## Parent View

Displays:

* Admission Number
* Class
* Section
* Roll Number
* Academic Year
* Student Photo

Read Only

---

# Academic Calendar Workflow

## Purpose

Provide visibility into important school dates.

---

## Data Source

Admin Academic Calendar

---

## Parent View

Displays:

* Holidays
* Exam Dates
* Parent Teacher Meetings
* Annual Day
* Sports Day
* School Events

---

## Examples

15 August

Independence Day Holiday

---

20 September

Quarterly Exams Begin

---

15 December

Parent Teacher Meeting

---

# School Announcements Workflow

## Purpose

Provide school-wide communication.

---

## Data Source

Admin Communication Module

---

## Parent View

Displays:

* Title
* Message
* Date

---

## Examples

School Holiday Tomorrow

---

Fee Payment Reminder

---

Annual Day Registration Open

---

New Uniform Policy

---

# Fee Management Workflow

## Purpose

Provide fee visibility.

---

## Data Source

Admin Fee Management

---

## Parent View

Displays:

* Total Fees
* Paid Amount
* Pending Amount
* Due Date

---

## Example

Total Fees:
₹30,000

Paid:
₹20,000

Pending:
₹10,000

Due Date:
15 August

---

# Fee Payment History Workflow

## Purpose

Provide complete fee payment transparency.

---

## Parent View

Displays:

* Payment Date
* Amount Paid
* Payment Mode
* Receipt Number

---

## Example

12 July

₹2,500

UPI

Receipt:
RCP-1025

---

# Digital Receipt Workflow

## Purpose

Provide downloadable fee receipts.

---

## Parent Actions

View Receipt

Download PDF

Share Receipt

---

# Fee Reminder Workflow

## Purpose

Notify parents about fee dues.

---

## Notification Types

* Upcoming Due
* Overdue Fee
* Outstanding Balance
* Payment Success
* Receipt Generated

---

## Examples

Fee Due In 5 Days

---

Outstanding Amount:
₹2,500

---

# Admission Status Workflow

## Purpose

Track admission progress.

Applicable during admission process.

---

## Parent View

Displays:

* Applied
* Under Review
* Approved
* Rejected
* Enrolled

---

# Student Promotion Workflow

## Purpose

Inform parents about class promotion.

---

## Data Source

Admin Promotion Process

---

## Parent View

Displays:

Previous Class:
5A

Current Class:
6A

Academic Year:
2027-2028

---

# Student Transfer Workflow

## Purpose

Track transfer processing.

---

## Parent View

Displays:

* Transfer Requested
* Under Processing
* Completed

---

# Student Documents Workflow

## Purpose

Provide access to student records.

---

## Data Source

Admin Document Repository

---

## Parent View

Displays:

* Birth Certificate
* Aadhaar
* Transfer Certificate
* Previous Report Cards
* Admission Documents

---

## Parent Actions

View

Download

---

# Emergency Notification Workflow

## Purpose

Deliver urgent school communications.

---

## Examples

School Closed Due To Weather

---

Transport Service Delayed

---

Emergency School Closure

---

## Delivery

Push Notification

In-App Notification

Priority Alert
