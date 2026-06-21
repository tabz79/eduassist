import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/seeder.dart';
import 'package:eduassist_app/screens/parent_dashboard.dart';
import 'package:eduassist_app/screens/teacher_dashboard.dart';
import 'package:eduassist_app/screens/admin_dashboard.dart';
import 'package:eduassist_app/screens/super_admin_dashboard.dart';
import 'package:eduassist_app/screens/mobile_frame.dart';
import 'package:eduassist_app/widgets/edu_design_system.dart';

class TestLoginScreen extends StatefulWidget {
  const TestLoginScreen({super.key});

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final DbService _dbService = DbService();
  bool _isLoading = false;
  bool _isSeeding = false;
  bool _showOnboarding = true;

  Future<void> _handleTestLogin() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _dbService.getUserByPhone(phone);
      if (mounted) {
        if (user != null) {
          if (user.role == 'parent') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParentDashboard(parent: user),
              ),
            );
          } else if (user.role == 'teacher') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherDashboard(teacher: user),
              ),
            );
          } else if (user.role == 'admin') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(admin: user),
              ),
            );
          } else if (user.role == 'superadmin') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuperAdminDashboard(superAdmin: user),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found. Did you run the database seeder first?'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRunSeeder() async {
    setState(() => _isSeeding = true);
    try {
      await DatabaseSeeder.seedDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Indo English High School Seeder Completed Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seeder Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
        ),
        child: Stack(
          children: [
            // Soft floating color accent meshes
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0F2FE).withValues(alpha: 0.6),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3E8FF).withValues(alpha: 0.6),
                ),
              ),
            ),
            SafeArea(
              child: _showOnboarding ? _buildOnboardingView() : _buildLoginView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(EduTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: EduTheme.space12),
            // Header block with Brand Logo & Security Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: EduTheme.radius12,
                        boxShadow: [EduTheme.shadowLevel1],
                      ),
                      child: const Center(
                        child: Icon(Icons.school, color: EduTheme.colorPrimaryBrandTeal, size: 24),
                      ),
                    ),
                    const SizedBox(width: EduTheme.space8),
                    Text(
                      'EduAssist',
                      style: EduTheme.typographyTitle.copyWith(
                        color: EduTheme.colorTextDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: EduTheme.radius20,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gpp_good, color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Secure & Private',
                        style: EduTheme.typographyMeta.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EduTheme.space40),
            
            // Hero Title
            RichText(
              text: TextSpan(
                style: EduTheme.typographyDisplayL.copyWith(
                  color: EduTheme.colorTextDark,
                  height: 1.15,
                ),
                children: const [
                  TextSpan(text: 'Everything\nabout '),
                  TextSpan(
                    text: 'your child.',
                    style: TextStyle(color: EduTheme.colorPrimaryBrandTeal),
                  ),
                  TextSpan(text: '\nOne place.'),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space16),
            
            // Hero Subtext
            Text(
              "Stay connected with your child's school journey, anytime, anywhere.",
              style: EduTheme.typographyBody.copyWith(
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: EduTheme.space40),

            // Horizontal Scrollable Feature Cards
            SizedBox(
              height: 135,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFeatureCard(
                    icon: Icons.calendar_month,
                    title: 'Attendance',
                    subtitle: 'Stay updated',
                    themeColor: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                  _buildFeatureCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Fees',
                    subtitle: 'Track & pay',
                    themeColor: const Color(0xFFF97316),
                    bgColor: const Color(0xFFFFF7ED),
                  ),
                  _buildFeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Updates',
                    subtitle: 'Never miss out',
                    themeColor: const Color(0xFF8B5CF6),
                    bgColor: const Color(0xFFF5F3FF),
                  ),
                  _buildFeatureCard(
                    icon: Icons.trending_up,
                    title: 'Progress',
                    subtitle: 'Track growth',
                    themeColor: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space40),

            // Premium Gradient Get Started Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [EduTheme.colorPrimaryBrandTeal, EduTheme.colorPrimaryBrandCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: EduTheme.radius16,
                boxShadow: [
                  BoxShadow(
                    color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showOnboarding = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: EduTheme.radius16,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: EduTheme.typographyBody.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: EduTheme.space8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: EduTheme.space24),
            
            // Onboarding Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Trusted by schools. Loved by parents.',
                  style: EduTheme.typographyCaption.copyWith(color: const Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: EduTheme.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color themeColor,
    required Color bgColor,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: EduTheme.space12),
      child: EduCard(
        padding: const EdgeInsets.all(EduTheme.space16),
        color: bgColor,
        borderRadius: EduTheme.radius24,
        border: Border.all(color: Colors.transparent),
        shadow: EduTheme.shadowLevel1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(EduTheme.space8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeColor, size: 18),
            ),
            const Spacer(),
            Text(
              title,
              style: EduTheme.typographyCaption.copyWith(
                fontWeight: FontWeight.bold,
                color: EduTheme.colorTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: EduTheme.typographyMeta.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(EduTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: EduTheme.colorTextDark),
                onPressed: () {
                  setState(() {
                    _showOnboarding = true;
                  });
                },
              ),
            ),
            const SizedBox(height: EduTheme.space8),

            // Concentric Rings Shield illustration
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.15),
                        width: 2.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEFF6FF),
                          EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_open_rounded,
                        size: 32,
                        color: EduTheme.colorPrimaryBrandTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space32),

            // Welcome Text
            Center(
              child: Text(
                'Welcome back!',
                style: EduTheme.typographyHeading.copyWith(
                  color: EduTheme.colorTextDark,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Login to continue to EduAssist',
                style: EduTheme.typographyCaption.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: EduTheme.space32),

            // Mobile Number Input field
            Text(
              'Mobile Number',
              style: EduTheme.typographyCaption.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: EduTheme.space8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: EduTheme.radius16,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [EduTheme.shadowLevel1],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          'https://flagcdn.com/w20/in.png',
                          width: 20,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+91',
                          style: EduTheme.typographyBody.copyWith(
                            fontWeight: FontWeight.bold,
                            color: EduTheme.colorTextDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '98765 43210',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        filled: false,
                      ),
                      style: EduTheme.typographyBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: EduTheme.colorTextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: EduTheme.space24),

            // OTP Send Button (Gradient design)
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EduTheme.colorPrimaryBrandTeal, EduTheme.colorPrimaryBrandCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: EduTheme.radius16,
                      boxShadow: [
                        BoxShadow(
                          color: EduTheme.colorPrimaryBrandTeal.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleTestLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: EduTheme.radius16,
                        ),
                      ),
                      child: Text(
                        'Send OTP',
                        style: EduTheme.typographyBody.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: EduTheme.space32),

            // Social divider
            Row(
              children: [
                Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'or continue with',
                    style: EduTheme.typographyMeta.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: EduTheme.space16),

            // Google & Apple login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', 'Google'),
                const SizedBox(width: 16),
                _buildSocialIcon('https://cdn-icons-png.flaticon.com/512/0/747.png', 'Apple'),
              ],
            ),
            const SizedBox(height: EduTheme.space32),

            // Legal footer
            Text(
              'By continuing, you agree to our\nTerms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: EduTheme.typographyMeta.copyWith(
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: EduTheme.space24),

            // Seeder Block for Testing
            const Divider(),
            _isSeeding
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : TextButton.icon(
                    onPressed: _handleRunSeeder,
                    icon: const Icon(Icons.playlist_add_check, color: Colors.green),
                    label: const Text(
                      'Run Database Seeder (IEHS)',
                      style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String url, String tooltip) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Image.network(
          url,
          width: 22,
          height: 22,
          errorBuilder: (context, error, stackTrace) => Icon(
            tooltip == 'Google' ? Icons.g_mobiledata : Icons.apple,
            size: 24,
            color: EduTheme.colorTextDark,
          ),
        ),
      ),
    );
  }
}
