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
  final _apiRouteController = TextEditingController(text: ApiConstants.defaultApiRoute);
  final _keyController = TextEditingController();

  bool _obscureKey = true;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiRouteController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  String? _validateBaseUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'آدرس ورکر را وارد کنید';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'آدرس باید با http:// یا https:// شروع شود';
    }
    return null;
  }

  String? _validateApiRoute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'مسیر API را وارد کنید (مثلاً /sync)';
    }
    if (!value.trim().startsWith('/')) {
      return 'مسیر باید با / شروع شود';
    }
    return null;
  }

  String? _validateKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'کلید را وارد کنید';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    var baseUrl = _baseUrlController.text.trim();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    var apiRoute = _apiRouteController.text.trim();
    if (!apiRoute.startsWith('/')) {
      apiRoute = '/$apiRoute';
    }

    ref.read(authNotifierProvider.notifier).login(
          baseUrl: baseUrl,
          apiRoute: apiRoute,
          key: _keyController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.dns_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ورود به پنل نهان',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اطلاعات ورکر خود را وارد کنید',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _baseUrlController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'آدرس ورکر',
                      hintText: 'https://example.workers.dev',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateBaseUrl,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _apiRouteController,
                    enabled: !isLoading,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'مسیر API',
                      hintText: '/sync',
                      prefixIcon: Icon(Icons.route),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateApiRoute,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _keyController,
                    enabled: !isLoading,
                    obscureText: _obscureKey,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'کلید (Master Key یا Panel Key)',
                      prefixIcon: const Icon(Icons.key),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                    validator: _validateKey,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ورود', style: TextStyle(fontSize: 16)),
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
