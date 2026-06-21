import 'package:flutter/material.dart';

class EduTheme {
  // --- Typography Tokens ---
  static const TextStyle typographyDisplayXL = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
  );

  static const TextStyle typographyDisplayL = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle typographyHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle typographyTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
  );

  static const TextStyle typographyBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle typographyCaption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle typographyMeta = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // --- Spacing Tokens ---
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // --- Border Radius Tokens ---
  static final BorderRadius radius12 = BorderRadius.circular(12.0);
  static final BorderRadius radius16 = BorderRadius.circular(16.0);
  static final BorderRadius radius20 = BorderRadius.circular(20.0);
  static final BorderRadius radius24 = BorderRadius.circular(24.0);
  static final BorderRadius radius32 = BorderRadius.circular(32.0);

  // --- Elevation & Shadows ---
  static final BoxShadow shadowLevel1 = BoxShadow(
    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  static final BoxShadow shadowLevel2 = BoxShadow(
    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
    blurRadius: 40,
    offset: const Offset(0, 16),
  );

  static final BoxShadow shadowLevel3 = BoxShadow(
    color: const Color(0xFF0F172A).withValues(alpha: 0.12),
    blurRadius: 60,
    offset: const Offset(0, 24),
  );

  // --- Primary Colors ---
  static const Color colorTextDark = Color(0xFF1E293B);
  static const Color colorPrimaryBrandTeal = Color(0xFF0F9F90);
  static const Color colorPrimaryBrandCyan = Color(0xFF0F9F90);
}

// --- 1. EDU CARD WITH SCALE TAP ANIMATION ---
class EduCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const EduCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderRadius,
    this.shadow,
    this.border,
    this.padding,
  });

  @override
  State<EduCard> createState() => _EduCardState();
}

class _EduCardState extends State<EduCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: widget.padding ?? const EdgeInsets.all(EduTheme.space16),
      decoration: BoxDecoration(
        color: widget.color ?? Colors.white,
        borderRadius: widget.borderRadius ?? EduTheme.radius24,
        border: widget.border ?? Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: widget.shadow != null ? [widget.shadow!] : [EduTheme.shadowLevel1],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: card,
      ),
    );
  }
}

// --- 2. EDU STUDENT HERO CARD ---
class EduStudentHeroCard extends StatelessWidget {
  final String studentName;
  final String className;
  final String rollNo;
  final String schoolName;
  final double attendanceRate;
  final VoidCallback? onTap;

  const EduStudentHeroCard({
    super.key,
    required this.studentName,
    required this.className,
    required this.rollNo,
    required this.schoolName,
    required this.attendanceRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EduCard(
      onTap: onTap,
      shadow: EduTheme.shadowLevel1,
      child: Row(
        children: [
          // Double-ring stacked photo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEFF6FF), width: 2),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F9F90).withValues(alpha: 0.15), width: 1.5),
                ),
              ),
              EduAvatar(
                name: studentName,
                size: 44,
              ),
            ],
          ),
          const SizedBox(width: EduTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      studentName,
                      style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark, fontSize: 16),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: EduTheme.space4),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF64748B)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Class $className  •  Roll No. $rollNo',
                  style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  schoolName,
                  style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          // Circular Progress ring (Teal accent matching mockup)
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: attendanceRate / 100,
                    strokeWidth: 4,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F9F90)),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${attendanceRate.toInt()}%',
                      style: EduTheme.typographyCaption.copyWith(
                        fontWeight: FontWeight.w900,
                        color: EduTheme.colorTextDark,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Attendance',
                      style: EduTheme.typographyMeta.copyWith(
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. EDU STATUS PILL ---
class EduStatusPill extends StatelessWidget {
  final String dateText;
  final String status; // 'present', 'absent', 'reported_absent'

  const EduStatusPill({
    super.key,
    required this.dateText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFECFDF5);
    Color border = const Color(0xFFA7F3D0);
    Color text = const Color(0xFF047857);
    String statusStr = 'Present';

    if (status == 'reported_absent') {
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      statusStr = 'Reported';
    } else if (status == 'absent') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFCA5A5);
      text = const Color(0xFFB91C1C);
      statusStr = 'Absent';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EduTheme.space16, vertical: EduTheme.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: EduTheme.radius16,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [EduTheme.shadowLevel1],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF0F9F90), size: 20),
          const SizedBox(width: EduTheme.space12),
          Text(
            dateText,
            style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: border),
            ),
            child: Text(
              statusStr,
              style: EduTheme.typographyCaption.copyWith(color: text, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. EDU TIMELINE CARD ---
class EduTimelineCard extends StatelessWidget {
  final String title;
  final String category; // 'homework', 'lesson', 'notice', 'fee', 'test'
  final String time;
  final String detailLine1;
  final String detailLine2;
  final String? footerLeft;
  final String? footerRight;
  final VoidCallback? onTap;

  const EduTimelineCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.detailLine1,
    required this.detailLine2,
    this.footerLeft,
    this.footerRight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color iconColor = const Color(0xFF3B82F6);
    Color iconBg = const Color(0xFFEFF6FF);
    IconData iconData = Icons.menu_book;

    final isScience = title.toLowerCase().contains('science') || 
                     detailLine1.toLowerCase().contains('science') ||
                     detailLine2.toLowerCase().contains('science');

    switch (category) {
      case 'homework':
        iconColor = const Color(0xFF8B5CF6);
        iconBg = const Color(0xFFF5F3FF);
        iconData = Icons.assignment_outlined;
        break;
      case 'lesson':
        if (isScience) {
          iconColor = const Color(0xFF10B981);
          iconBg = const Color(0xFFECFDF5);
          iconData = Icons.science_outlined;
        } else {
          iconColor = const Color(0xFF3B82F6);
          iconBg = const Color(0xFFEFF6FF);
          iconData = Icons.menu_book;
        }
        break;
      case 'notice':
        iconColor = const Color(0xFFF97316);
        iconBg = const Color(0xFFFFF7ED);
        iconData = Icons.notifications_none_outlined;
        break;
      case 'fee':
        iconColor = const Color(0xFFF97316);
        iconBg = const Color(0xFFFFF7ED);
        iconData = Icons.account_balance_wallet_outlined;
        break;
      case 'test':
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFEFF6FF);
        iconData = Icons.calendar_today_outlined;
        break;
    }

    // Right-side widget based on dashboard context vs list details
    Widget rightWidget = Text(
      time,
      style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
    );

    if (footerLeft == null && footerRight == null) {
      if (category == 'homework') {
        rightWidget = const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20);
      } else if (category == 'test') {
        rightWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '3',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6), height: 1.0),
            ),
            Text(
              'Days Left',
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        );
      } else if (category == 'fee') {
        rightWidget = ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFA5A15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
          child: Text(
            'Pay Now',
            style: EduTheme.typographyCaption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return EduCard(
      onTap: onTap,
      color: bg,
      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: EduTheme.radius16,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: EduTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: EduTheme.typographyTitle.copyWith(color: EduTheme.colorTextDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    rightWidget,
                  ],
                ),
                const SizedBox(height: EduTheme.space4),
                Text(
                  detailLine1,
                  style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  detailLine2,
                  style: EduTheme.typographyBody.copyWith(color: const Color(0xFF475569), height: 1.3, fontSize: 14),
                ),
                if (footerLeft != null || footerRight != null) ...[
                  const SizedBox(height: EduTheme.space12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: EduTheme.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (footerLeft != null)
                        Text(
                          footerLeft!,
                          style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF64748B)),
                        ),
                      if (footerRight != null)
                        Text(
                          footerRight!,
                          style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. EDU ACTION CHIP (FILTER CHIPS) ---
class EduActionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const EduActionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F9F90) : Colors.white,
          borderRadius: EduTheme.radius20,
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F9F90).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: EduTheme.typographyCaption.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// --- 6. EDU ACTION CIRCLE (QUICK ACTION CIRCULAR BUTTONS) ---
class EduActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const EduActionCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
        ),
        const SizedBox(height: EduTheme.space8),
        Text(
          label,
          style: EduTheme.typographyMeta.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// --- 7. EDU INFO TILE ---
class EduInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const EduInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        const SizedBox(width: EduTheme.space12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: EduTheme.typographyMeta.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: EduTheme.typographyCaption.copyWith(color: EduTheme.colorTextDark, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

// --- 8. FLOATING iOS TAB BAR ---
class EduFloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final List<IconData>? activeIcons;

  const EduFloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.activeIcons,
  });  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 64,
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected 
                        ? (activeIcons != null && activeIcons!.length > index 
                            ? activeIcons![index] 
                            : _getActiveIcon(index))
                        : (item.icon is Icon ? (item.icon as Icon).icon : Icons.home),
                    color: isSelected ? const Color(0xFF0F9F90) : const Color(0xFF94A3B8),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label ?? '',
                    style: EduTheme.typographyMeta.copyWith(
                      color: isSelected ? const Color(0xFF0F9F90) : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getActiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.school;
      case 2:
        return Icons.timeline;
      case 3:
        return Icons.notifications;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }
}

// --- 9. EDU EMPTY STATE ---
class EduEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EduEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EduTheme.space24, vertical: EduTheme.space40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(EduTheme.space24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 48),
            ),
            const SizedBox(height: EduTheme.space24),
            Text(
              title,
              style: EduTheme.typographyHeading.copyWith(color: EduTheme.colorTextDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: EduTheme.space8),
            Text(
              description,
              style: EduTheme.typographyBody.copyWith(color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EduAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const EduAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a consistent premium gradient based on the seed name
    final int hash = name.hashCode;
    final List<Color> gradients = _getGradients(hash);

    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: textStyle ?? TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  List<Color> _getGradients(int hash) {
    final palettes = [
      [const Color(0xFF0F9F90), const Color(0xFF0D9488)], // Teal
      [const Color(0xFF0EA5E9), const Color(0xFF0284C7)], // Sky Blue
      [const Color(0xFF6366F1), const Color(0xFF4F46E5)], // Indigo
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // Purple
      [const Color(0xFFF97316), const Color(0xFFEA580C)], // Orange
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald Green
    ];
    return palettes[hash.abs() % palettes.length];
  }
}
