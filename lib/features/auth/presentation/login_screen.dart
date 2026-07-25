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
  final _baseUrlController = TextEditingController();
  final _apiRouteController = TextEditingController(
    text: ApiConstants.defaultApiRoute,
  );
  final _keyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiRouteController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    var baseUrl = _baseUrlController.text.trim();
    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    var apiRoute = _apiRouteController.text.trim();
    if (!apiRoute.startsWith('/')) apiRoute = '/$apiRoute';
    ref.read(authNotifierProvider.notifier).login(
      baseUrl: baseUrl,
      apiRoute: apiRoute,
      key: _keyController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ));
      }
    });

    final isLoading = ref.watch(authNotifierProvider).status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.dns_rounded, size: 64, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text('ورود به پنل نهان',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('اطلاعات ورکر خود را وارد کنید',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _baseUrlController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'آدرس ورکر',
                      hintText: 'https://example.workers.dev',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'آدرس الزامی است';
                      final uri = Uri.tryParse(v.trim());
                      if (uri == null || !uri.isAbsolute) return 'آدرس معتبر نیست';
                      if (!['http', 'https'].contains(uri.scheme)) return 'فقط http یا https';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiRouteController,
                    enabled: !isLoading,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'مسیر API',
                      hintText: '/sync',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'مسیر الزامی است';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _keyController,
                    enabled: !isLoading,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'کلید (Master Key یا Panel Key)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'کلید الزامی است';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('ورود'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
