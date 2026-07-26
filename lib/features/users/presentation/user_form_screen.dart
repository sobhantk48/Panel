import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late final TextEditingController _nameCtrl;
  late final TextEditingController _trafficLimitCtrl;
  late final TextEditingController _dailyLimitCtrl;
  late final TextEditingController _expiryDaysCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _maxConfigsCtrl;
  late final TextEditingController _proxyIpCtrl;
  late final TextEditingController _cleanIpCtrl;
  late final TextEditingController _userModeCtrl;
  late final TextEditingController _userPortsCtrl;
  late final TextEditingController _userNodesCtrl;
  late final TextEditingController _nat64Ctrl;
  late final TextEditingController _connLimitCtrl;
  late final TextEditingController _userPanelUrlCtrl;

  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _trafficLimitCtrl =
        TextEditingController(text: _fmt(u?.trafficLimitGb));
    _dailyLimitCtrl = TextEditingController(text: _fmt(u?.dailyLimitGb));
    _expiryDaysCtrl = TextEditingController(
      text: u?.expiryMs != null
          ? ((u!.expiryMs! - DateTime.now().millisecondsSinceEpoch) / 86400000)
              .ceil()
              .clamp(0, 100000)
              .toString()
          : '',
    );
    _notesCtrl = TextEditingController(text: u?.notes ?? '');
    _maxConfigsCtrl =
        TextEditingController(text: u?.maxConfigs?.toString() ?? '');
    _proxyIpCtrl = TextEditingController(text: u?.proxyIp ?? '');
    _cleanIpCtrl = TextEditingController(text: u?.cleanIp ?? '');
    _userModeCtrl = TextEditingController(text: u?.userMode ?? '');
    _userPortsCtrl = TextEditingController(text: u?.userPorts ?? '');
    _userNodesCtrl = TextEditingController(text: u?.userNodes ?? '');
    _nat64Ctrl = TextEditingController(text: u?.nat64 ?? '');
    _connLimitCtrl =
        TextEditingController(text: u?.connLimit?.toString() ?? '');
    _userPanelUrlCtrl = TextEditingController(text: u?.userPanelUrl ?? '');
    _status = u?.status ?? 'active';
  }

  String _fmt(double? v) {
    if (v == null || v == 0) return '';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _trafficLimitCtrl.dispose();
    _dailyLimitCtrl.dispose();
    _expiryDaysCtrl.dispose();
    _notesCtrl.dispose();
    _maxConfigsCtrl.dispose();
    _proxyIpCtrl.dispose();
    _cleanIpCtrl.dispose();
    _userModeCtrl.dispose();
    _userPortsCtrl.dispose();
    _userNodesCtrl.dispose();
    _nat64Ctrl.dispose();
    _connLimitCtrl.dispose();
    _userPanelUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{'name': _nameCtrl.text.trim()};

    void putNum(String key, TextEditingController c, {bool decimal = false}) {
      final t = c.text.trim();
      if (t.isEmpty) return;
      data[key] = decimal ? double.tryParse(t) : int.tryParse(t);
    }

    void putStr(String key, TextEditingController c) {
      final t = c.text.trim();
      if (t.isNotEmpty) data[key] = t;
    }

    putNum('trafficLimit', _trafficLimitCtrl, decimal: true);
    putNum('dailyLimit', _dailyLimitCtrl, decimal: true);
    putNum('expiryDays', _expiryDaysCtrl);
    putNum('maxConfigs', _maxConfigsCtrl);
    putNum('connLimit', _connLimitCtrl);

    putStr('notes', _notesCtrl);
    putStr('proxyIp', _proxyIpCtrl);
    putStr('cleanIp', _cleanIpCtrl);
    putStr('userMode', _userModeCtrl);
    putStr('userPorts', _userPortsCtrl);
    putStr('userNodes', _userNodesCtrl);
    putStr('nat64', _nat64Ctrl);
    putStr('userPanelUrl', _userPanelUrlCtrl);

    if (widget.user != null) data['status'] = _status;

    final notifier = ref.read(usersNotifierProvider.notifier);
    final ok = widget.user == null
        ? await notifier.createUser(data)
        : await notifier.updateUser(widget.user!.id, data);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final err = ref.read(usersNotifierProvider).error ?? 'خطای ناشناخته';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    }
  }

  Widget _text(
    String label,
    TextEditingController c, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final decimals = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'ویرایش کاربر' : 'کاربر جدید')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _text(
                    'نام کاربر *',
                    _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'نام الزامی است'
                        : null,
                  ),
                  _text('حجم کل (GB)', _trafficLimitCtrl,
                      hint: 'مثال: 50',
                      keyboard:
                          const TextInputType.numberWithOptions(decimal: true),
                      formatters: decimals),
                  _text('حجم روزانه (GB)', _dailyLimitCtrl,
                      hint: 'مثال: 5',
                      keyboard:
                          const TextInputType.numberWithOptions(decimal: true),
                      formatters: decimals),
                  _text('تعداد روز اعتبار', _expiryDaysCtrl,
                      hint: 'مثال: 30',
                      keyboard: TextInputType.number,
                      formatters: digits),
                  _text('حداکثر تعداد کانفیگ', _maxConfigsCtrl,
                      hint: 'مثال: 2',
                      keyboard: TextInputType.number,
                      formatters: digits),
                  _text('محدودیت اتصال همزمان', _connLimitCtrl,
                      hint: 'مثال: 5',
                      keyboard: TextInputType.number,
                      formatters: digits),
                  _text('Proxy IP', _proxyIpCtrl, hint: '1.2.3.4'),
                  _text('Clean IP', _cleanIpCtrl),
                  _text('User Mode', _userModeCtrl, hint: 'best-ping'),
                  _text('User Ports', _userPortsCtrl, hint: '443,8443'),
                  _text('User Nodes', _userNodesCtrl, hint: 'node1,node2'),
                  _text('NAT64', _nat64Ctrl),
                  _text('User Panel URL', _userPanelUrlCtrl,
                      hint: 'https://panel.example.com'),
                  _text('یادداشت', _notesCtrl, maxLines: 3),
                  if (isEdit) ...[
                    const Text('وضعیت:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'active', label: Text('فعال')),
                        ButtonSegment(value: 'paused', label: Text('توقف')),
                      ],
                      selected: {_status},
                      onSelectionChanged: (v) =>
                          setState(() => _status = v.first),
                    ),
                    const SizedBox(height: 24),
                  ],
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'ذخیره تغییرات' : 'ایجاد کاربر'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
