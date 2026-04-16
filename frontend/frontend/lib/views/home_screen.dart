import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/storage.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String serverUrl;
  final String token;

  const HomeScreen({
    super.key,
    required this.serverUrl,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔐 Ejemplo de ruta protegida futura
  Future<void> _loadProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _user = jsonDecode(response.body)['user'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error cargando perfil';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // 🚪 LOGOUT LOCAL
  Future<void> _logout() async {
    await Storage.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuario logueado:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text('ID: ${_user?['userId'] ?? ''}'),
                      Text('Email: ${_user?['email'] ?? ''}'),
                      const SizedBox(height: 20),
                      const Text('🎯 Backend conectado correctamente'),
                    ],
                  ),
                ),
    );
  }
}
