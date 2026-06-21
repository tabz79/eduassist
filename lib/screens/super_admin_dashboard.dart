import 'package:flutter/material.dart';
import 'package:eduassist_app/services/db_service.dart';
import 'package:eduassist_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatefulWidget {
  final UserModel superAdmin;

  const SuperAdminDashboard({super.key, required this.superAdmin});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final DbService _dbService = DbService();
  int _selectedIndex = 0; // 0 = Overview, 1 = Onboard School, 2 = CRM Pipeline, 3 = Support Tickets
  bool _isLoading = false;

  // Platform statistics
  int _totalSchools = 0;
  int _totalStudents = 0;
  int _totalRevenue = 0;

  // Lead CRM Pipeline lists
  List<LeadRecord> _leads = [];

  // Support Tickets list
  List<SupportTicket> _tickets = [];

  // School Onboarding Form fields
  final _schoolNameController = TextEditingController();
  final _principalNameController = TextEditingController();
  final _principalPhoneController = TextEditingController();

  // Lead creation Form fields
  final _leadSchoolNameController = TextEditingController();
  final _leadContactNameController = TextEditingController();
  final _leadPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuperAdminData();
  }

  Future<void> _loadSuperAdminData() async {
    setState(() => _isLoading = true);
    try {
      final schoolsQuery = await FirebaseFirestore.instance.collection('schools').get();
      _totalSchools = schoolsQuery.docs.length;

      final studentsQuery = await FirebaseFirestore.instance.collection('students').get();
      _totalStudents = studentsQuery.docs.length;

      final leadsQuery = await FirebaseFirestore.instance.collection('leads').get();
      _leads = leadsQuery.docs.map((doc) => LeadRecord.fromMap(doc.data(), doc.id)).toList();

      final ticketsQuery = await FirebaseFirestore.instance.collection('tickets').get();
      _tickets = ticketsQuery.docs.map((doc) => SupportTicket.fromMap(doc.data(), doc.id)).toList();

      _totalRevenue = _totalStudents * 100;

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error loading super admin data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onboardNewSchool() async {
    final schoolName = _schoolNameController.text.trim();
    final pName = _principalNameController.text.trim();
    final pPhone = _principalPhoneController.text.trim();

    if (schoolName.isEmpty || pName.isEmpty || pPhone.isEmpty) {
      _showSnackBar('All fields are required.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final schoolId = _dbService.generateCustomId('SCH');
    await FirebaseFirestore.instance.collection('schools').doc(schoolId).set({
      'name': schoolName,
      'ownerId': 'admin_$schoolId',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final adminId = 'admin_$schoolId';
    await FirebaseFirestore.instance.collection('users').doc(adminId).set({
      'name': pName,
      'phone': pPhone,
      'role': 'admin',
      'schoolId': schoolId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('subscriptions').doc(schoolId).set({
      'plan': 'Starter',
      'startDate': DateTime.now(),
      'endDate': DateTime.now().add(const Duration(days: 365)),
      'status': 'active',
    });

    _schoolNameController.clear();
    _principalNameController.clear();
    _principalPhoneController.clear();

    await _loadSuperAdminData();
    _showSnackBar('School onboarded successfully!', Colors.green);
  }

  Future<void> _createLead() async {
    final school = _leadSchoolNameController.text.trim();
    final name = _leadContactNameController.text.trim();
    final phone = _leadPhoneController.text.trim();

    if (school.isEmpty || name.isEmpty || phone.isEmpty) {
      _showSnackBar('All lead fields are required.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('leads').add({
      'schoolName': school,
      'contactName': name,
      'phone': phone,
      'status': 'lead',
    });

    _leadSchoolNameController.clear();
    _leadContactNameController.clear();
    _leadPhoneController.clear();

    await _loadSuperAdminData();
    _showSnackBar('New lead added to CRM Pipeline!', Colors.green);
  }

  Future<void> _updateLeadStatus(LeadRecord lead, String newStatus) async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('leads').doc(lead.id).update({
      'status': newStatus,
    });
    await _loadSuperAdminData();
    _showSnackBar('Lead status updated to ${newStatus.toUpperCase()}', Colors.blue);
  }

  Future<void> _updateTicketStatus(SupportTicket ticket, String newStatus) async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('tickets').doc(ticket.id).update({
      'status': newStatus,
    });
    await _loadSuperAdminData();
    _showSnackBar('Ticket status updated to ${newStatus.toUpperCase()}', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EduAssist',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'Super Admin Panel',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _buildSidebarItem(Icons.dashboard_outlined, 'Overview', 0),
                _buildSidebarItem(Icons.school_outlined, 'Onboard School', 1),
                _buildSidebarItem(Icons.trending_up_outlined, 'CRM Pipeline', 2),
                _buildSidebarItem(Icons.support_agent_outlined, 'Support Tickets', 3),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Main Body
          Expanded(
            child: Column(
              children: [
                // Top Search & Title Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Welcome back, Super Admin! 🌟',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
                          const SizedBox(width: 18),
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Text('SA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : IndexedStack(
                          index: _selectedIndex,
                          children: [
                            _buildOverviewTab(),
                            _buildOnboardTab(),
                            _buildCrmTab(),
                            _buildTicketsTab(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final active = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
        title: Text(
          title,
          style: TextStyle(
            color: active ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMetricCard(Icons.school, 'Total Schools', _totalSchools.toString(), '+18 this month', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              const SizedBox(width: 20),
              _buildMetricCard(Icons.verified_user, 'Active Schools', '198', '+14 this month', const Color(0xFFECFDF5), const Color(0xFF10B981)),
              const SizedBox(width: 20),
              _buildMetricCard(Icons.hourglass_empty, 'Trial Schools', '28', '-3 this month', const Color(0xFFFFF7ED), const Color(0xFFF97316)),
              const SizedBox(width: 20),
              _buildMetricCard(Icons.currency_rupee, 'Monthly Revenue', '₹28,74,230', '+21.4% vs last month', const Color(0xFFFDF2F8), const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 32),
          // Charts & Analytics Simulators
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Chart simulator (Revenue Overview)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Revenue Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Text('This Month', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Revenue Line Chart (₹28,74,230)', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Pie Chart simulator (Subscription Status)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subscription Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2563EB), width: 14),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('248', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text('Total', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Bottom Grid: Recent schools & tickets
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRecentSchoolsSection(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTicketsDeskSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String val, String subtitle, Color bgColor, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Text(subtitle, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSchoolsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Customer Schools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              return const ListTile(
                title: Text('Green Valley High School', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('ID: SCH8K4M2  •  Plan: Enterprise'),
                trailing: Text('Active', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsDeskSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Support Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          if (_tickets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No active tickets')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tickets.length > 4 ? 4 : _tickets.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final ticket = _tickets[index];
                return ListTile(
                  title: Text(ticket.issueType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(ticket.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(ticket.status.toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Onboard School', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _schoolNameController,
              decoration: const InputDecoration(labelText: 'School Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _principalNameController,
              decoration: const InputDecoration(labelText: 'Principal / Admin Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _principalPhoneController,
              decoration: const InputDecoration(labelText: 'Principal Contact Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _onboardNewSchool, child: const Text('Provision School Account')),
          ],
        ),
      ),
    );
  }

  Widget _buildCrmTab() {
    final leadStages = ['lead', 'contacted', 'demo', 'trial', 'converted'];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales CRM Pipeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Add Lead Prospect'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(controller: _leadSchoolNameController, decoration: const InputDecoration(labelText: 'School Name')),
                          TextField(controller: _leadContactNameController, decoration: const InputDecoration(labelText: 'Contact Person')),
                          TextField(controller: _leadPhoneController, decoration: const InputDecoration(labelText: 'Phone')),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _createLead();
                          },
                          child: const Text('Add Lead'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Prospect'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: leadStages.map((stage) {
                final stageLeads = _leads.where((l) => l.status == stage).toList();
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${stage.toUpperCase()} (${stageLeads.length})',
                            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: stageLeads.length,
                            itemBuilder: (context, index) {
                              final lead = stageLeads[index];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  title: Text(lead.schoolName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  subtitle: Text(lead.contactName, style: const TextStyle(fontSize: 10)),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (val) => _updateLeadStatus(lead, val),
                                    itemBuilder: (context) => leadStages
                                        .map((s) => PopupMenuItem(value: s, child: Text('Move to ${s.toUpperCase()}')))
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Support Desk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: _tickets.isEmpty
                ? const Center(child: Text('No active support tickets.'))
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFEFF6FF),
                            child: Icon(Icons.help_center_outlined, color: Color(0xFF2563EB)),
                          ),
                          title: Text(ticket.issueType, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(ticket.description),
                          trailing: DropdownButton<String>(
                            value: ticket.status,
                            items: const [
                              DropdownMenuItem(value: 'open', child: Text('Open')),
                              DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                              DropdownMenuItem(value: 'closed', child: Text('Closed')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                _updateTicketStatus(ticket, val);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
