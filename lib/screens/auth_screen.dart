import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';

/// Simple sign-in screen: anonymous play or email/password account.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isRegistering = false;
  bool _loading = false;
  String? _error;

  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(authServiceProvider);
      if (_isRegistering) {
        await service.registerWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
      } else {
        await service.signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '⚓ ANCHORED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dominate the map.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),

              // Email / password fields
              if (_isRegistering)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_isRegistering) const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(
                  onPressed: _submitEmail,
                  child: Text(_isRegistering ? 'Create Account' : 'Sign In'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign in'
                        : 'No account? Register',
                    style: const TextStyle(color: AppTheme.primary),
                  ),
                ),
                const Divider(height: 32),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white30),
                  ),
                  onPressed: _signInAnonymously,
                  child: const Text('Play as Guest'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
