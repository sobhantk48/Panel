import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/providers/providers.dart';
import '../application/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlCtrl = TextEditingController();
  final _routeCtrl = TextEditingController(text: ApiConstants.defaultApiRoute);
  final _keyCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _routeCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    var url = _baseUrlCtrl.text.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    var route = _routeCtrl.text.trim();
    if (!route.startsWith('/')) route = '/$route';
    ref.read(authNotifierProvider.notifier).login(
      baseUrl: url,
      apiRoute: route,
      key: _keyCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (_, s) {
      if (s.status == AuthStatus.error && s.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    final loading = ref.watch(authNotifierProvider).status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.dns_rounded, size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text('ورود به پنل نهان',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('اطلاعات ورکر خود را وارد کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _baseUrlCtrl,
                  enabled: !loading,
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'آدرس ورکر',
                    hintText: 'https://example.workers.dev',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'الزامی است';
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.isAbsolute) return 'آدرس معتبر نیست';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeCtrl,
                  enabled: !loading,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'مسیر API',
                    hintText: '/sync',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الزامی است' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _keyCtrl,
                  enabled: !loading,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'کلید',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الزامی است' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ورود'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
