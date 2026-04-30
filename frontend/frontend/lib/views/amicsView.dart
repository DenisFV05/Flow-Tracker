import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/friends_service.dart';
import '../models/habitsProvider.dart';
import 'inputEstil.dart';

class AmicsView extends StatefulWidget {
  const AmicsView({super.key});

  @override
  State<AmicsView> createState() => _AmicsViewState();
}

class _AmicsViewState extends State<AmicsView> {
  List<dynamic> friends = [];
  List<dynamic> requests = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final friendsApi = FriendsApi("https://flow-tracker.ieti.site");

      final results = await Future.wait([
        friendsApi.getFriends(),
        friendsApi.getRequests(),
      ]);

      setState(() {
        friends = results[0] as List<dynamic>;
        requests = results[1] as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _sendRequest(String username) async {
    try {
      final friendsApi = FriendsApi("https://flow-tracker.ieti.site");
      await friendsApi.sendRequest(username);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _respondRequest(String id, String action) async {
    try {
      final friendsApi = FriendsApi("https://flow-tracker.ieti.site");
      await friendsApi.respondRequest(id, action);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amics"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showSearchDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text("Afegir amic"),
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// ======================
                              /// 👥 FRIENDS LIST
                              /// ======================
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SectionTitle(title: "Els teus amics"),
                                    const SizedBox(height: 10),
                                    if (friends.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text(
                                          "Encara no tens amics 👀",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ...friends.map((friend) {
                                      final user = friend['friend'];
                                      return Card(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Text(user['name']?[0] ?? '?'),
                                          ),
                                          title: Text(user['name'] ?? ''),
                                          subtitle: Text("@${user['username'] ?? ''}"),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              /// ======================
                              /// 📊 RIGHT PANEL - REQUESTS
                              /// ======================
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SectionTitle(title: "Sol·licituds"),
                                    const SizedBox(height: 10),
                                    if (requests.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text(
                                          "No tens sol·licituds pendents",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ...requests.map((req) {
                                      final user = req['user'];
                                      return Card(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Text(user['name']?[0] ?? '?'),
                                          ),
                                          title: Text(user['name'] ?? ''),
                                          subtitle: Text("@${user['username'] ?? ''}"),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                onPressed: () => _respondRequest(req['id'], 'accept'),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.red),
                                                onPressed: () => _respondRequest(req['id'], 'reject'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        /// ======================
                        /// 📱 MOBILE
                        /// ======================
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle(title: "Els teus amics"),
                            const SizedBox(height: 10),
                            if (friends.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  "Encara no tens amics 👀",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ...friends.map((friend) {
                              final user = friend['friend'];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user['name']?[0] ?? '?'),
                                  ),
                                  title: Text(user['name'] ?? ''),
                                  subtitle: Text("@${user['username'] ?? ''}"),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            const SectionTitle(title: "Sol·licituds"),
                            const SizedBox(height: 10),
                            if (requests.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  "No tens sol·licituds pendents",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ...requests.map((req) {
                              final user = req['user'];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user['name']?[0] ?? '?'),
                                  ),
                                  title: Text(user['name'] ?? ''),
                                  subtitle: Text("@${user['username'] ?? ''}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _respondRequest(req['id'], 'accept'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _respondRequest(req['id'], 'reject'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cercar usuari",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: inputEstil.base("Username", "Escriu el username"),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel·lar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          Navigator.pop(context);
                          _sendRequest(controller.text);
                        }
                      },
                      child: const Text("Enviar sol·licitud"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
