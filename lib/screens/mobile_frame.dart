import 'package:flutter/material.dart';

class MobileFrame extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const MobileFrame({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobileWidth = size.width < 500;

    if (isMobileWidth) {
      return Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          width: 412,
          height: 844,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFF1E293B), width: 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Scaffold(
              appBar: appBar != null ? _buildCustomAppBar(appBar!) : null,
              floatingActionButton: floatingActionButton,
              body: Column(
                children: [
                  Container(
                    height: 24,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "9:41",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, size: 12, color: Color(0xFF1E293B)),
                            SizedBox(width: 4),
                            Icon(Icons.wifi, size: 12, color: Color(0xFF1E293B)),
                            SizedBox(width: 4),
                            Icon(Icons.battery_std, size: 12, color: Color(0xFF1E293B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                  if (bottomNavigationBar != null) bottomNavigationBar!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(PreferredSizeWidget original) {
    return PreferredSize(
      preferredSize: original.preferredSize,
      child: Container(
        color: Colors.white,
        child: original,
      ),
    );
  }
}
