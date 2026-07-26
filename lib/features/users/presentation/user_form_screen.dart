import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../data/user_model.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final NahanUser? user;
  const UserFormScreen({super.key, this.user});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _traffic;
  late final TextEditingController _daily;
  late final TextEditingController _expiry;
  late final TextEditingController _notes;
  late final TextEditingController _maxConfigs;
  late final TextEditingController _proxyIp;
  late final TextEditingController _cleanIp;
  late final TextEditingController _connLimit;
  late final TextEditingController _userMode;
  late final TextEditingController _userPorts;
  late final TextEditingController _userNodes;
  late final TextEditingController _nat64;
  late final TextEditingController _userPanelUrl;
  String _status = 'active';
  bool _loading = false;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _name = TextEditingController(text: u?.name ?? '');
    _traffic = TextEditingController(
      text: u?.trafficLimitGb?.toStringAsFixed(0) ?? '',
    );
    _daily = TextEditingController(
      text: u?.dailyLimitGb?.toStringAsFixed(0) ?? '',
    );
    _notes = TextEditingController(text: u?.notes ?? '');
    _maxConfigs = TextEditingController(
      text: u?.maxConfigs?.toString() ?? '',
    );
    _proxyIp = TextEditingController(text: u?.proxyIp ?? '');
    _cleanIp = TextEditingController(text: u?.cleanIp ?? '');
    _connLimit = TextEditingController(text: u?.connLimit?.toString() ?? '');
    _userMode = TextEditingController(text: u?.userMode ?? '');
    _userPorts = TextEditingController(text: u?.userPorts ?? '');
    _userNodes = TextEditingController(text: u?.userNodes ?? '');
    _nat64 = TextEditingController(text: u?.nat64 ?? '');
    _userPanelUrl = TextEditingController(text: u?.userPanelUrl ?? '');
    _status = u?.status ?? 'active';

    if (u?.expiryMs != null) {
      final remaining = ((u!.expiryMs! -
                  DateTime.now().millisecondsSinceEpoch) /
              86400000)
          .ceil();
      _expiry = TextEditingController(
        text: remaining > 0 ? remaining.toString() : '',
      );
    } else {
      _expiry = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _traffic,
      _daily,
      _expiry,
      _notes,
      _maxConfigs,
      _proxyIp,
      _cleanIp,
      _connLimit,
      _userMode,
      _userPorts,
      _userNodes,
      _nat64,
      _userPanelUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    final m = <String, dynamic>{'name': _name.text.trim()};
    if (_traffic.text.isNotEmpty) {
      m['trafficLimit'] = double.tryParse(_traffic.text);
    }
    if (_daily.text.isNotEmpty) {
      m['dailyLimit'] = double.tryParse(_daily.text);
    }
    if (_expiry.text.isNotEmpty) {
      m['expiryDays'] = int.tryParse(_expiry.text);
    }
    if (_notes.text.isNotEmpty) m['notes'] = _notes.text.trim();
    if (_maxConfigs.text.isNotEmpty) {
      m['maxConfigs'] = int.tryParse(_maxConfigs.text);
    }
    if (_proxyIp.text.isNotEmpty) m['proxyIp'] = _proxyIp.text.trim();
    if (_cleanIp.text.isNotEmpty) m['cleanIp'] = _cleanIp.text.trim();
    if (_connLimit.text.isNotEmpty) {
      m['connLimit'] = int.tryParse(_connLimit.text);
    }
    if (_userMode.text.isNotEmpty) m['userMode'] = _userMode.text.trim();
    if (_userPorts.text.isNotEmpty) m['userPorts'] = _userPorts.text.trim();
    if (_userNodes.text.isNotEmpty) m['userNodes'] = _userNodes.text.trim();
    if (_nat64.text.isNotEmpty) m['nat64'] = _nat64.text.trim();
    if (_userPanelUrl.text.isNotEmpty) {
      m['userPanelUrl'] = _userPanelUrl.text.trim();
    }
    if (isEdit) m['status'] = _status;
    return m;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final notifier = ref.read(usersNotifierProvider.notifier);
    final ok = isEdit
        ? await notifier.updateUser(widget.user!.id, _buildPayload())
        : await notifier.createUser(_buildPayload());
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در ذخیره‌سازی'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? type,
    String? hint,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: type,
          textDirection: label.contains('IP') ||
                  label.contains('URL') ||
                  label.contains('Port') ||
                  label.contains('Node') ||
                  label.contains('NAT')
              ? TextDirection.ltr
              : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'ویرایش ${widget.user!.name}' : 'کاربر جدید'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'نام کاربر *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'نام الزامی است'
                          : null,
                ),
              ),
              _field(
                _traffic,
                'حجم ترافیک (GB)',
                type: TextInputType.number,
                hint: 'مثلاً 50',
              ),
              _field(
                _daily,
                'محدودیت روزانه (GB)',
                type: TextInputType.number,
                hint: 'مثلاً 5',
              ),
              _field(
                _expiry,
                'تعداد روز انقضا',
                type: TextInputType.number,
                hint: 'مثلاً 30',
              ),
              _field(
                _maxConfigs,
                'حداکثر کانفیگ',
                type: TextInputType.number,
              ),
              _field(
                _connLimit,
                'محدودیت اتصال همزمان',
                type: TextInputType.number,
              ),
              _field(_proxyIp, 'Proxy IP'),
              _field(_cleanIp, 'Clean IP'),
              _field(
                _userMode,
                'User Mode',
                hint: 'حالت کاربر',
              ),
              _field(
                _userPorts,
                'User Ports',
                hint: 'مثلاً 443,8443',
              ),
              _field(
                _userNodes,
                'User Nodes',
                hint: 'نودهای اختصاصی',
              ),
              _field(
                _nat64,
                'NAT64',
                hint: 'پیشوند NAT64',
              ),
              _field(
                _userPanelUrl,
                'User Panel URL',
                hint: 'https://...',
              ),
              _field(_notes, 'یادداشت'),
              if (isEdit) ...[
                const Text(
                  'وضعیت',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'active', label: Text('فعال')),
                    ButtonSegment(value: 'paused', label: Text('متوقف')),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) =>
                      setState(() => _status = s.first),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'ذخیره تغییرات' : 'ایجاد کاربر'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
