# EduAssist - Product Brain Summary (June 2026)

## Current Status

### Repository & Project Setup

* Git repository initialized successfully.
* GitHub repository created and connected:

  * https://github.com/tabz79/eduassist
* Initial commit pushed.
* ChatGPT Project "EduAssist" created.
* Workflow documents uploaded:

  * parent-workflow.md
  * teacher-workflow.md
  * admin-workflow.md
  * super-admin-workflow.md
  * parent-app mockup image

---

# Product Vision

EduAssist is a modern school management platform targeting Indian schools with approximately 500–2000 students.

Modules:

1. Parent App (Flutter)
2. Teacher App (Flutter)
3. Admin Portal (Web/Desktop)
4. Super Admin Portal (Web/Desktop)

Core philosophy:

* Workflow first
* Mobile first
* Real school operations
* Minimal administrative burden
* Affordable pricing
* Premium user experience

---

# Workflow Mapping Completed

## Teacher Workflow

Defined end-to-end:

* Attendance
* Classroom updates
* Homework posting
* Chapter tracking
* Syllabus progress
* Weekly tests
* Exam marks entry
* Parent communication
* Substitute teacher handling
* Report card responsibilities

Important decision:

Teacher can be:

* Class Teacher
* Subject Teacher
* Both

Homework model:

* Teacher can post text
* Teacher can upload blackboard image
* Parents receive updates automatically

---

## Parent Workflow

Defined end-to-end:

Parent can view:

* Attendance
* Daily classroom updates
* Homework
* Upcoming tests
* Marks
* Report cards
* Fee reminders
* Announcements
* Child profile

Important decision:

Parent app is primarily a consumption app, not an operational app.

---

## Admin Workflow

Defined end-to-end:

Admin onboarding order:

1. Academic Year
2. Classes
3. Sections
4. Subjects
5. Teachers
6. Students
7. Parent Linking
8. Timetables
9. Exams
10. Fees

Important architectural decisions:

* Permanent Student ID
* Permanent Parent ID
* Permanent Teacher ID
* Permanent School ID

Yearly changes handled through Enrollment records.

---

## Super Admin Workflow

Defined end-to-end:

Responsibilities:

* School onboarding
* Subscription management
* Lead CRM
* Billing
* Platform management

Lead stages:

Lead
→ Contacted
→ Demo Scheduled
→ Trial
→ Converted

Pricing direction:

Per Active Student model preferred for Indian market.

---

# Architecture Decisions

## ID Structure

Schools:
SCHxxxxx

Students:
STUxxxxx

Teachers:
TCHxxxxx

Parents:
PARxxxxx

Short alphanumeric IDs.

Permanent.

Never recycled.

---

## Enrollment Model

Important architectural decision:

Student profile and yearly enrollment are separated.

Student:

Permanent identity.

Enrollment:

* Academic Year
* Class
* Section
* Roll Number

This prevents future promotion/history problems.

---

## Firestore Direction

Current architecture includes:

* Students
* Parents
* Teachers
* Schools
* Enrollments

Important rule:

Do not rely permanently on in-memory sorting.

Design queries to migrate easily to Firestore indexes.

---

# Development Phases

## Phase 0

Foundation Layer

Completed / Planned:

* Custom ID generation
* Permission structure
* Enrollment architecture

---

## Phase 1A

Teacher ↔ Parent Sync

Includes:

* Attendance
* Classroom Updates
* Homework
* Parent Feed

---

## Phase 1B

Assessment Module

Includes:

* Tests
* Marks Entry
* Exams
* Report Cards

Not yet considered production-ready.

---

# UI & Design Direction

Major design review performed.

Important findings:

Current UI feels:

* Generic
* Android-like
* ERP-like
* Inconsistent

Desired direction:

* iOS quality
* Premium
* Typography-first
* Spacing-first
* Strong visual hierarchy

Inspired by:

* Apple Wallet
* Apple Fitness
* Apple Journal
* Things 3
* Linear
* Craft

Avoid:

* Generic school ERP layouts
* Heavy gradients
* Heavy glassmorphism
* Card clutter

---

# Design System Decisions

## Brand Colors

Primary Accent:

Teal → Cyan

Examples:

* Teal #14B8A6
* Cyan #06B6D4

Used sparingly.

---

## Functional Colors

Attendance:
Green

Homework:
Violet

Fees:
Amber

Tests:
Blue

Notices:
Orange

Results:
Indigo

---

## Design System Components

Planned:

* EduCard
* EduStudentHeroCard
* EduStatusPill
* EduTimelineCard
* EduActionChip
* EduActionCircle
* EduMetricRing
* EduInfoTile
* EduFloatingTabBar
* EduEmptyState
* EduScreenScaffold

---

# Project Organization

ChatGPT Project Structure:

* Product Brain
* Architecture
* Parent App
* Teacher App
* Admin Portal
* Super Admin
* UI Design System
* Architecture Reviews

Recommended additional chat:

* Development Log

---

# Testing Strategy

Do NOT start with 30 students.

First validate workflows using a mini-school.

Test Dataset:

Class 5A

Students:

* Aarav
* Anaya
* Vivaan

Parents:

* 3 parents

Teachers:

* Mathematics teacher
* Science teacher

Subjects:

* Mathematics
* Science

Test order:

1. Admin creates data
2. Teacher logs in
3. Teacher marks attendance
4. Parent sees attendance
5. Teacher posts homework
6. Parent sees homework
7. Teacher posts updates
8. Parent sees updates

Only after this works:

Move to:

* Syllabus tracking
* Tests
* Marks
* Exams
* Report Cards

Only after all of that:

Create larger datasets (30+ students).

---

# Immediate Next Steps

1. Create docs folder in repository.
2. Create design-system.md.
3. Upload architecture/design docs to ChatGPT Project.
4. Build Design System before building more screens.
5. Build component library.
6. Rebuild Parent Dashboard using design system.
7. Validate Teacher ↔ Parent workflow with mini-school dataset.
8. Begin Phase 1B (Tests, Marks, Exams) only after workflow validation succeeds.
