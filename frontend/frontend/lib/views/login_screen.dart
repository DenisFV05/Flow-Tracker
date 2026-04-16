  import 'package:exercici09/views/dashboardView.dart';
import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'dart:io';
  import '../utils/settings_manager.dart';
  import 'home_screen.dart';
  import 'package:exercici09/services/auth_service.dart';
  import 'mainScreen.dart';

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
    bool _passwordVisible=false;
    String _errorMessage = '';

    @override
    void initState() {
      super.initState();
      _loadSettings();
    }

    // Cargar URL del servidor desde settings.xml
    Future<void> _loadSettings() async {
      final settings = await SettingsManager.loadSettings();
      final serverUrl = settings['serverUrl'];
      if (serverUrl != null && serverUrl.isNotEmpty) {
        _serverUrlController.text = serverUrl;
      } else {
        _serverUrlController.text = 'http://localhost:3000';
      }
    }

    // Función para realizar el login
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
        ),
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
        appBar: AppBar(title: const Text('UXIA Admin - Acceso')),
        body: Center(
          child: Container(
            width: 400, // Limitamos el ancho para que se vea bien en Desktop
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo URL Servidor
                  TextFormField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(labelText: 'URL del Servidor'),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo Usuario (Email)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Email / Usuario'),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo Contraseña
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),

                  const SizedBox(height: 24),
                  // Mensaje de Error
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                  // Botón de Login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading 
                          ? const CircularProgressIndicator(strokeWidth: 2) 
                          : const Text('Iniciar Sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
