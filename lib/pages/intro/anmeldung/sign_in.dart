import 'package:flutter/material.dart';
import 'package:studyproject/pages/intro/auth/auth_service.dart';
import 'package:studyproject/pages/intro/widgets/fancy_login_background.dart';
import 'package:studyproject/pages/intro/widgets/party_sheep_captcha.dart';
import 'package:studyproject/pages/intro/widgets/brand_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _loading = false;
  int _captchaAnswer = 0; // richtige Anzahl 🐑

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final answer = int.tryParse(_captchaController.text.trim());

    if (answer != _captchaAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captcha falsch – bitte Schafe neu zählen 🐑')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await AuthMethod().loginUser(email: email, password: password);
      if (!mounted) return;
      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login erfolgreich!")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login fehlgeschlagen: $res')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Zurück',
          onPressed: () => Navigator.pushReplacementNamed(context, '/auth_choice'),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: FancyLoginBackground(tint: Color(0xFF60BFA0)),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Card(
                    elevation: 12,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                            ),
                            child: const Icon(Icons.lock, size: 28, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Willkommen zurück 👋',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Melde dich mit deinem Konto an.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.80),
                            ),
                          ),

                          const SizedBox(height: 22),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'E-Mail',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Passwort',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          PartySheepCaptcha(
                            minCount: 1,
                            maxCount: 8,
                            onNewAnswer: (ans) => _captchaAnswer = ans,
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: _captchaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Anzahl eingeben',
                              hintText: 'z. B. 5',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10, right: 6),
                                child: Text('🐑', style: TextStyle(fontSize: 18)),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 56),
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: const BorderSide(color: Colors.black, width: 1.6),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          BrandButton(
                            label: 'Einloggen',
                            loading: _loading,
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            onPressed: _loading ? null : _login,
                          ),

                          const SizedBox(height: 10),
                          Opacity(
                            opacity: 0.7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.https_outlined, size: 16, color: theme.colorScheme.outline),
                                const SizedBox(width: 6),
                                Text(
                                  'Deine Daten bleiben geschützt.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
