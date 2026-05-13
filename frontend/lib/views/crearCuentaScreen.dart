import 'package:flowTracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'inputEstil.dart';
import 'login_screen.dart';

class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key});

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Has d\'acceptar els termes')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = AuthService();

      await authService.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _usernameController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte creat correctament'),
            backgroundColor: AppTheme.primary,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDarker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: 28,
                                color: context.surfaceColor,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Registrar-se",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  "Omple les teves dades per crear un compte",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: inputEstil.base(context, "Nom complet", "El teu nom").copyWith(
                                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
                                ),
                                validator: (v) => v!.isEmpty ? "Requerit" : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: inputEstil.base(context, "Username", "@username").copyWith(
                                  prefixIcon: Icon(Icons.alternate_email, color: AppTheme.primary),
                                ),
                                validator: (v) => v!.isEmpty ? "Requerit" : null,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: inputEstil.base(context, "Correu electrònic", "elteumail@mail.com").copyWith(
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? "Requerit" : null,
                        ),

                        SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: inputEstil
                              .base(context, "Contrasenya", "Mínim 6 caràcters")
                              .copyWith(
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppTheme.primary,
                              ),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                          validator: (v) => v!.length < 6 ? "Mínim 6 caràcters" : null,
                        ),

                        SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          decoration: inputEstil
                              .base(context, "Confirma la contrasenya", "Repeteix la contrasenya")
                              .copyWith(
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppTheme.primary,
                              ),
                              onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                            ),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? "Les contrasenyes no coincideixen"
                              : null,
                        ),

                        SizedBox(height: 16),

                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (value) => setState(() => _acceptedTerms = value!),
                            ),
                            Expanded(
                              child: Text(
                                "Accepto els Termes del servei i la Política de privacitat",
                                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        if (_errorMessage.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: AppTheme.error, fontSize: 13),
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.surfaceColor,
                                    ),
                                  )
                                : Text(
                                    "Crear compte",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Ja tens un compte? Inicia sessió",
                              style: TextStyle(color: AppTheme.primary),
                            ),
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
      ),
    );
  }
}
