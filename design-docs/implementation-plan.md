# Exact Mockup Redesign Plan

We will overhaul the visual layouts, color themes, headers, and navigation of the entire application to exactly match the design in the new mockup image. 

## Refined Color DNA & Design Aesthetics
- **Primary Accent**: Teal (`Color(0xFF0F9F90)`).
- **Background System**: Clean, soft grey-white surface (`Color(0xFFF8FAFC)`).
- **Header Blocks**: No dark gradients! Clean white headers integrated directly into the background, showcasing parent/teacher profile info on white/light backgrounds.
- **Navigation Bar**: Docked full-width bottom bar (no floating margin, sits flat at the bottom, thin top border, active icons in teal).
- **Cards**: Solid white backgrounds, soft drop shadows, border radius `16` to `20`.

---

## Proposed Changes

### 1. [MODIFY] [edu_design_system.dart](file:///d:/Projects/eduassist_app/lib/widgets/edu_design_system.dart)
- Change primary brand teal to `Color(0xFF0F9F90)`.
- Modify `EduFloatingTabBar` (rename or restyle it to `EduDockedTabBar`) to sit flat at the bottom of the screen (remove external margin, remove circular radius 32, make it full width with a top border of `Color(0xFFF1F5F9)`).
- Update `EduStudentHeroCard` to match Screen 1: double-ring photo, name, class info, progress ring showing attendance.
- Update `EduTimelineCard` to support a vertical category icon on the left (blue box for Lessons, green box for Science lessons, purple box for Homework, orange box for Notices) and a footer.

### 2. [MODIFY] [parent_dashboard.dart](file:///d:/Projects/eduassist_app/lib/screens/parent_dashboard.dart)
- Remove the header dark gradient.
- **Home Tab**:
  - Render a clean header with Parent photo (Neha Sharma), "Good morning, 👋 \n Neha Sharma", and a bell notification icon with badge '2'.
  - Render the updated student card with circular attendance indicator and double-ring photo.
  - Add Today's attendance pill row card: "Today • 15 July, 2026", "Present" pill (green bg/text).
  - Add sections:
    - "Today's Update" card: Mathematics Fractions.
    - "Homework" card: 2 Assignments.
    - "Upcoming Test" card: Fractions Assessment with "3 Days Left".
    - "Fees Reminder" card: ₹2,500 Due, Pay Now orange button.
- **Academics Tab**:
  - Center title "Class Updates" on AppBar, Funnel filter icon on right.
  - Filter chips row: All, Lessons, Homework, Notices.
  - List of updates matching Screen 2.

### 3. [MODIFY] [student_details_screen.dart](file:///d:/Projects/eduassist_app/lib/screens/student_details_screen.dart)
- Remove any background color gradients.
- Render double-ring student avatar with camera icon overlay badge.
- Student Name, pills "Class 5A" and "Roll No. 12" in light blue.
- Grid of 4 cards: Class Teacher (Teal), Attendance (Green), Fee Status (Orange), Latest Result (Purple).
- About Aarav card containing Birth Date, Blood Group, Mobile, Address.

### 4. [MODIFY] [teacher_dashboard.dart](file:///d:/Projects/eduassist_app/lib/screens/teacher_dashboard.dart)
- Remove header gradient.
- Render clean header: teacher photo, "Good morning, 👋 \n Mrs. Priya Patel", bell icon with red circle badge '3'.
- Horizontal week calendar strip: "TUE 15" selected in solid teal capsule.
- "Today's Schedule" section:
  - 3 period rows with blue, green, and purple user group icon boxes.
- Quick Actions section:
  - Grid of 4 white cards (Mark Attendance, Post Update, Assignments, More).
- "Pending Tasks" section:
  - Pending task cards (Attendance, Homework Review, Test - Fractions) with orange "Pending" pills.
- Docked bottom tab bar at the bottom: Home, Classes, Students, Profile, More.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure there are no compilation errors.

### Manual Verification
- Verify that colors and layout borders align 100% with the provided image mockups.
