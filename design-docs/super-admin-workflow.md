# EduAssist - Super Admin Workflow Specification

# Purpose

This document defines the complete Super Admin Workflow for EduAssist.

The Super Admin role belongs to TBZ Labs.

Unlike Teachers, Parents, and School Admins, the Super Admin operates at the platform level.

The Super Admin manages:

* Schools
* Subscriptions
* Billing
* Support
* Platform Operations
* Data Governance
* Multi-School Management

The Super Admin does not manage individual students, attendance, or academic activities.

The Super Admin manages schools as customers.

---

# Super Admin Role Overview

The Super Admin is responsible for the lifecycle of every school using EduAssist.

Responsibilities include:

* School Onboarding
* Subscription Management
* Revenue Management
* School Support
* School Monitoring
* Data Export
* Platform Health Monitoring

---

# School Lifecycle Workflow

## Purpose

Manage a school from first contact until platform exit.

---

## School Lifecycle States

* Lead
* Demo Scheduled
* Trial
* Active
* Expiring Soon
* Expired
* Suspended
* Archived

---

# Lead Management Workflow

## Purpose

Track prospective schools.

---

## School Inquiry

Example:

Green Valley School

Status:

Lead

---

## Lead Information

Store:

* School Name
* Contact Person
* Mobile Number
* Email
* City
* Student Strength

---

## Lead Status

* New Lead
* Contacted
* Demo Scheduled
* Trial Offered
* Converted
* Lost

---

# Demo Workflow

## Purpose

Manage product demonstrations.

---

## Demo Information

Store:

* Demo Date
* School Name
* Contact Person
* Notes

---

## Demo Outcome

* Interested
* Follow Up Required
* Trial Requested
* Closed

---

# Trial Workflow

## Purpose

Allow schools to evaluate EduAssist.

---

## Trial Setup

Super Admin creates:

Trial School

Example:

Green Valley School

Trial Duration:

30 Days

---

## Trial Status

* Active
* Expired
* Converted

---

# School Creation Workflow

## Purpose

Create a new school account.

---

## School Creation

Create:

* School Profile
* School ID
* Initial Admin Account

---

## School ID

Example:

SCH8K4M2

Permanent

Never Changes

---

## School Information

Store:

* School Name
* Address
* City
* State
* Contact Information
* Student Capacity

---

# School Admin Creation Workflow

## Purpose

Create first school administrator.

---

## Create Admin

Store:

* Name
* Mobile Number
* Email

---

## Access

Generate:

* Username
* Temporary Password

---

# Subscription Workflow

## Purpose

Manage school plans.

---

## Subscription Plans

* Trial
* Starter
* Professional
* Enterprise

---

## Subscription Information

Store:

* Plan Name
* Start Date
* End Date
* Renewal Date

---

## Subscription Status

* Active
* Expiring Soon
* Expired
* Suspended

---

# Student-Based Billing Workflow

## Purpose

Calculate subscription cost.

---

## Billing Model

Based on:

Enrolled Active Students

Current Academic Year

---

## Example

School:

Green Valley School

Active Students:

500

Applicable Plan:

Starter

---

## Billing Rules

Student count determined from active enrollment records.

Not based on:

* App Logins
* Active Users
* Parent Accounts

---

# Renewal Workflow

## Purpose

Handle subscription renewals.

---

## Notification Schedule

30 Days Before Expiry

Reminder Sent

---

15 Days Before Expiry

Reminder Sent

---

7 Days Before Expiry

Reminder Sent

---

Expiry Date

Subscription Expired

---

# School Billing Workflow

## Purpose

Manage invoices and payments.

---

## Invoice Creation

Generate:

Invoice Number

Example:

INV7X2P5

Permanent

---

## Invoice Information

Store:

* School
* Plan
* Amount
* Due Date

---

## Payment Status

* Pending
* Paid
* Overdue

---

# Payment Tracking Workflow

## Purpose

Track subscription payments.

---

## Payment Modes

* Bank Transfer
* UPI
* Online Payment
* Cheque

---

## Payment History

Never Delete

Never Modify

Permanent Audit Trail

---

# Multi-School Dashboard

## Purpose

Provide platform-wide visibility.

---

## Displays

* Total Schools
* Active Schools
* Trial Schools
* Expired Schools
* Suspended Schools

---

## Revenue Metrics

* Monthly Revenue
* Annual Revenue
* Upcoming Renewals

---

## Platform Metrics

* Total Students
* Total Teachers
* Total Parents

---

# School Monitoring Workflow

## Purpose

Monitor customer health.

---

## School Health Indicators

* Last Login Date
* Active Teachers
* Active Parents
* Attendance Activity

---

## Warning Examples

No Attendance Recorded

10 Days

---

No Teacher Activity

15 Days

---

No Parent Activity

30 Days

---

# School Support Workflow

## Purpose

Handle customer issues.

---

## Support Ticket Creation

Ticket ID

Example:

SUP9A7D1

Permanent

---

## Ticket Status

* Open
* Assigned
* In Progress
* Resolved
* Closed

---

## Ticket Information

Store:

* School
* Issue Type
* Priority
* Assigned Agent

---

# Platform Announcements Workflow

## Purpose

Communicate with schools.

---

## Examples

Scheduled Maintenance

---

New Feature Released

---

Planned Downtime

---

## Visibility

School Admins

Only

---

# School Suspension Workflow

## Purpose

Restrict access when required.

---

## Reasons

* Subscription Expired
* Payment Failure
* Policy Violation

---

## Status

Suspended

---

## Effects

School Data Preserved

Access Restricted

No Data Deleted

---

# School Reactivation Workflow

## Purpose

Restore suspended schools.

---

## Trigger

Successful Renewal

or

Manual Approval

---

## Result

School Status:

Active

---

# Data Export Workflow

## Purpose

Provide school data exports.

---

## Export Options

* Students
* Teachers
* Attendance
* Marks
* Fees
* Report Cards

---

## Export Formats

* Excel
* CSV
* PDF

---

# Backup Workflow

## Purpose

Protect customer data.

---

## Super Admin Actions

View Backup Status

Restore School Data

Recover Deleted Records

---

## Access

Super Admin Only

---

# Audit Workflow

## Purpose

Track platform activity.

---

## Examples

School Created

Subscription Changed

Payment Recorded

Support Ticket Closed

---

## Audit Fields

Who

What

When

---

# Feature Flag Workflow

## Purpose

Control feature rollout.

---

## Examples

Homework Module

Enabled For:

Green Valley School

Disabled For:

ABC School

---

## Benefits

Controlled Releases

Beta Testing

Gradual Rollouts

---

# School Offboarding Workflow

## Purpose

Handle school exit.

---

## Offboarding Options

* Data Export
* Archive Data
* Delete After Retention Period

---

## School Status

Archived

---

## Historical Access

Retained Based On Policy

---

# Super Admin Dashboard

Displays:

* Total Schools
* Active Schools
* Trial Schools
* Monthly Revenue
* Annual Revenue
* Renewals Due
* Open Support Tickets
* Platform Health

---

# V1 Super Admin Priorities

Must Have

* School Creation
* School Status Management
* Subscription Management
* Billing
* School Monitoring
* Support Tickets
* Multi-School Dashboard

Should Have

* Data Export
* Audit Logs
* Platform Announcements

Future

* Feature Flags
* White Labeling
* Franchise Management
* AI Insights
* Automated Renewals

---

# Core Principle

The Super Admin should be able to manage hundreds of schools from a single platform while maintaining visibility, control, supportability, and revenue oversight without interacting with individual student records.
