# EduAssist System Gospel (Living Document)

## Purpose

This document is the single source of truth for building, running, and debugging the EduAssist system.

This is NOT a static document.
It will evolve as development progresses.
Every new feature, module, or decision must be reflected here.

---

# 1. Core Philosophy

## 1.1 What We Are Building

EduAssist is a **Digital Operating System for Schools**.

It replaces:

* Registers (attendance)
* Fee books (payments)
* Report cards (marks)
* Manual communication

---

## 1.2 System Mindset

We are NOT building apps.
We are building a **system of relationships**.

Everything revolves around:
👉 STUDENT

* Fees → tied to student
* Attendance → tied to student
* Marks → tied to student
* Parent → linked to student

---

## 1.3 Build Philosophy

Follow this strictly:

1. Function First
2. Structure Second
3. Optimization Later
4. Polish Last

---

# 2. System Architecture (High Level)

## 2.1 Roles (Users)

* Parent
* Teacher
* Admin
* Super Admin

Only these have login access.

---

## 2.2 Entities (Data)

* School
* User
* Student
* Fee
* Attendance
* Marks

---

## 2.3 Golden Rule

Every document MUST contain:
👉 schoolId

This ensures:

* Data isolation
* Multi-school support
* Security

---

# 3. Tech Stack

* Flutter → Mobile App (Parent + Teacher)
* React → Admin + Super Admin
* Firebase:

  * Auth (OTP)
  * Firestore (database)
  * Storage (files)

---

# 4. Core Data Model (Phase 1)

## 4.1 Schools

```
{
  id,
  name,
  createdAt
}
```

## 4.2 Users

```
{
  id,
  name,
  phone,
  role,
  schoolId
}
```

## 4.3 Students

```
{
  id,
  name,
  class,
  schoolId,
  parentId
}
```

---

# 5. Authentication Model

* Login via mobile number (OTP)
* If user does not exist → create as parent
* Admin/Teacher created by Admin
* Super Admin manually controlled

---

# 6. Logging System (CRITICAL)

Every important action must log minimal structured data.

Example:

```
{
  action: "MARK_ATTENDANCE",
  userId: "t1",
  studentId: "s22",
  schoolId: "school_1",
  timestamp: "..."
}
```

---

## 6.1 Log Rules

* Keep logs lightweight
* No large objects
* Always include:

  * action
  * userId
  * schoolId
  * timestamp

---

## 6.2 Log Levels

* INFO → normal operations
* ERROR → failures
* DEBUG → optional deep logs

---

# 7. Error System

Errors must be specific and readable.

Bad:
"Something went wrong"

Good:
"ATTENDANCE_SAVE_FAILED: Missing studentId"

---

# 8. Module Structure

System must be divided into:

* Auth Module
* Student Module
* Fee Module
* Attendance Module
* Marks Module

No giant functions.

---

# 9. Performance Rules

* Fetch only required data
* Avoid full collection reads
* Use filters (schoolId, class, etc.)

---

# 10. Storage Rules

* Firestore → structured data
* Firebase Storage → files (PDFs, images)

---

# 11. UI Philosophy

Premium ≠ heavy

Premium =

* Clean layout
* Consistent spacing
* Readable typography

Avoid:

* Heavy animations
* Overdesign

---

# 12. Development Phases

## Phase 1: Foundation

* Auth
* Roles
* schoolId system

## Phase 2: Admin Core

* Add students
* Add teachers
* Assign roles

## Phase 3: Fees

* Assign fees
* Mark paid
* Generate receipt

## Phase 4: Attendance

* Teacher marks
* Parent views

## Phase 5: Marks

## Phase 6: Super Admin

---

# 13. Debugging Philosophy

System must always be debuggable using AI.

When something breaks, provide:

* Error message
* Logs
* Module context

---

# 14. Future Additions (To Be Expanded)

This document will grow with:

* New collections
* API patterns
* Query structures
* Security rules
* Edge cases

---

# FINAL RULE

Clarity > Complexity

A simple system that is understood can be fixed.
A complex system without clarity will collapse.
