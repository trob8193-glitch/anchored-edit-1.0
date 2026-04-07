import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'verification_provider.dart';

class _VerifMeta {
  const _VerifMeta({
    required this.title,
    required this.description,
    required this.hint,
    required this.icon,
    this.sensitive = false,
  });

  final String title;
  final String description;
  final String hint;
  final IconData icon;
  final bool sensitive;
}

const Map<VerifType, _VerifMeta> _meta = {
  VerifType.govtId: _VerifMeta(
    title: 'Government ID',
    description: 'Validate legal identity for trust and account protection.',
    hint: 'Enter ID or license number',
    icon: Icons.badge_outlined,
    sensitive: true,
  ),
  VerifType.phone: _VerifMeta(
    title: 'Phone Number',
    description: 'Used for secure login checks and urgent account alerts.',
    hint: 'Enter mobile phone number',
    icon: Icons.phone_outlined,
  ),
  VerifType.email: _VerifMeta(
    title: 'Email Address',
    description: 'Required for account recovery and booking updates.',
    hint: 'Enter primary email',
    icon: Icons.email_outlined,
  ),
  VerifType.address: _VerifMeta(
    title: 'Address',
    description: 'Confirms your service area and identity consistency.',
    hint: 'Enter street address',
    icon: Icons.home_outlined,
  ),
  VerifType.backgroundCheck: _VerifMeta(
    title: 'Background Check',
    description: 'Required before accepting paid walker jobs.',
    hint: 'Enter verification reference code',
    icon: Icons.security_outlined,
    sensitive: true,
  ),
  VerifType.insurance: _VerifMeta(
    title: 'Liability Insurance',
    description: 'Protects clients, pets, and service providers.',
    hint: 'Enter policy number',
    icon: Icons.health_and_safety_outlined,
  ),
  VerifType.walkerCert: _VerifMeta(
    title: 'Walker Certification',
    description: 'Shows professional training credentials.',
    hint: 'Enter certificate number',
    icon: Icons.workspace_premium_outlined,
  ),
  VerifType.businessLicense: _VerifMeta(
    title: 'Business License',
    description: 'Confirms legal business operation status.',
    hint: 'Enter business license number',
    icon: Icons.storefront_outlined,
  ),
  VerifType.businessInsurance: _VerifMeta(
    title: 'Business Insurance',
    description: 'Coverage for commercial service operations.',
    hint: 'Enter policy number',
    icon: Icons.shield_outlined,
  ),
  VerifType.taxId: _VerifMeta(
    title: 'Tax ID / EIN',
    description: 'Needed for payouts and tax reporting.',
    hint: 'Enter EIN (XX-XXXXXXX)',
    icon: Icons.receipt_long_outlined,
    sensitive: true,
  ),
  VerifType.healthCert: _VerifMeta(
    title: 'Health and Safety Certificate',
    description: 'Supports compliance for higher-risk services.',
    hint: 'Enter certificate details',
    icon: Icons.medical_services_outlined,
  ),
  VerifType.vaccination: _VerifMeta(
    title: 'Vaccination Records',
    description: 'Required for boarding, daycare, and group activities.',
    hint: 'Enter vet reference number',
    icon: Icons.vaccines_outlined,
  ),
  VerifType.microchip: _VerifMeta(
    title: 'Microchip ID',
    description: 'Helps prove pet ownership and identity.',
    hint: 'Enter microchip number',
    icon: Icons.memory_outlined,
  ),
  VerifType.breedRegistration: _VerifMeta(
    title: 'Breed Registration',
    description: 'Optional but useful for breeding services.',
    hint: 'Enter registration number',
    icon: Icons.description_outlined,
  ),
  VerifType.dogLicense: _VerifMeta(
    title: 'Dog License',
    description: 'Validates local legal registration requirements.',
    hint: 'Enter tag/license number',
    icon: Icons.local_police_outlined,
  ),
};

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key, this.role = 'owner'});

  final String role;

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0F1218);
  static const _card = Color(0xFF1A1F2A);
  static const _accent = Color(0xFF2E7D32);

  late final TabController _tabController;

  List<Tab> get _tabs => switch (widget.role) {
        'walker' => const [
            Tab(text: 'Identity'),
            Tab(text: 'Safety'),
            Tab(text: 'Credentials'),
          ],
        'business' => const [
            Tab(text: 'Identity'),
            Tab(text: 'Business'),
            Tab(text: 'Compliance'),
          ],
        _ => const [
            Tab(text: 'Identity'),
            Tab(text: 'Dog Records'),
          ],
      };

  List<VerifType> get _requiredTypes => switch (widget.role) {
        'walker' => const [
            VerifType.govtId,
            VerifType.phone,
            VerifType.email,
            VerifType.address,
            VerifType.backgroundCheck,
            VerifType.insurance,
            VerifType.walkerCert,
          ],
        'business' => const [
            VerifType.govtId,
            VerifType.phone,
            VerifType.email,
            VerifType.address,
            VerifType.businessLicense,
            VerifType.businessInsurance,
            VerifType.taxId,
            VerifType.healthCert,
          ],
        _ => const [
            VerifType.govtId,
            VerifType.phone,
            VerifType.email,
            VerifType.address,
            VerifType.vaccination,
            VerifType.microchip,
            VerifType.breedRegistration,
            VerifType.dogLicense,
          ],
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submitType(BuildContext context, VerifType type) async {
    final m = _meta[type]!;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(m.title),
        content: TextField(
          controller: controller,
          obscureText: m.sensitive,
          decoration: InputDecoration(hintText: m.hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    await ref.read(verifProvider.notifier).submit(type, value);
  }

  Widget _progress(VerifState state) {
    final approved = _requiredTypes
        .where((t) => state.itemOf(t).status == VerifStatus.approved)
        .length;
    final ratio = _requiredTypes.isEmpty ? 0.0 : approved / _requiredTypes.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Progress: $approved/${_requiredTypes.length}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(_accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, VerifType type, VerifState state) {
    final item = state.itemOf(type);
    final m = _meta[type]!;
    final Color statusColor;
    final String statusText;
    switch (item.status) {
      case VerifStatus.approved:
        statusColor = _accent;
        statusText = 'Approved';
        break;
      case VerifStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending Review';
        break;
      case VerifStatus.rejected:
        statusColor = Colors.redAccent;
        statusText = 'Rejected';
        break;
      case VerifStatus.notSubmitted:
        statusColor = Colors.white54;
        statusText = 'Not Submitted';
        break;
    }

    return Card(
      color: _card,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withAlpha(120)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(m.icon, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(m.description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            if (item.submittedValue != null) ...[
              const SizedBox(height: 8),
              Text(
                'Submitted: ${m.sensitive ? 'Hidden' : item.submittedValue!}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
            if (item.status != VerifStatus.approved) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => _submitType(context, type),
                  child: Text(item.status == VerifStatus.rejected ? 'Resubmit' : 'Submit'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _list(List<VerifType> types, VerifState state) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: types.map((t) => _itemCard(context, t, state)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifProvider);
    final views = switch (widget.role) {
      'walker' => [
          _list(const [VerifType.govtId, VerifType.phone, VerifType.email, VerifType.address], state),
          _list(const [VerifType.backgroundCheck, VerifType.insurance], state),
          _list(const [VerifType.walkerCert], state),
        ],
      'business' => [
          _list(const [VerifType.govtId, VerifType.phone, VerifType.email, VerifType.address], state),
          _list(const [VerifType.businessLicense, VerifType.businessInsurance, VerifType.taxId], state),
          _list(const [VerifType.healthCert], state),
        ],
      _ => [
          _list(const [VerifType.govtId, VerifType.phone, VerifType.email, VerifType.address], state),
          _list(const [VerifType.vaccination, VerifType.microchip, VerifType.breedRegistration, VerifType.dogLicense], state),
        ],
    };

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Verification Center', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white54,
          tabs: _tabs,
        ),
      ),
      body: Column(
        children: [
          _progress(state),
          Expanded(
            child: TabBarView(controller: _tabController, children: views),
          ),
        ],
      ),
    );
  }
}
