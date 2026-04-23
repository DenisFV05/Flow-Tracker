import 'package:flutter/material.dart';
import '../utils/settings_manager.dart';
import 'package:flowTracker/services/auth_service.dart';
import 'mainScreen.dart';
import 'crearCuentaScreen.dart';
import 'package:flowTracker/utils.dart';
import 'inputEstil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsManager.loadSettings();
    final serverUrl = settings['serverUrl'];

    if (serverUrl != null && serverUrl.isNotEmpty) {
      _serverUrlController.text = serverUrl;
    } else {
      _serverUrlController.text = 'http://localhost:3000';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = AuthService(_serverUrlController.text);

      final token = await authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      await SettingsManager.saveSettings(
        serverUrl: _serverUrlController.text,
        token: token,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => MainScreen(
            //serverUrl: _serverUrlController.text,
            //token: token,
          ),
          )
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
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // URL servidor
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del servidor',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Requerit' : null,
                    ),

                    const SizedBox(height: 16),

                    // Usuari
                    TextFormField(
                      controller: _usernameController,
                      decoration: inputEstil.base(
                        "Correu / Usuari",
                        "Introdueix el teu correu o nom d'usuari",
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Requerit' : null,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          print('Recuperar contrasenya');
                        },
                        child: const Text('Has oblidat la contrasenya?'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contrasenya
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: inputEstil
                          .base("Contrasenya", "Introdueix la teva contrasenya")
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Requerit' : null,
                    ),

                    const SizedBox(height: 24),

                    // Error
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Botó login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgIcons,
                          foregroundColor: white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text('Iniciar sessió'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CrearCuentaScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'No tens un compte? Crea’n un de gratuït',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
