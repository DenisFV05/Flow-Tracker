import 'package:flutter/material.dart';

import '../services/friends_service.dart';
import 'inputEstil.dart';
import '../widgets/SectionTitle.dart';

class AmicsView extends StatefulWidget {
  const AmicsView({super.key});

  @override
  State<AmicsView> createState() => _AmicsViewState();
}

class _AmicsViewState extends State<AmicsView> {
  final FriendsApi _friendsApi = FriendsApi();
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

      final results = await Future.wait([
        _friendsApi.getFriends(),
        _friendsApi.getRequests(),
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
      await _friendsApi.sendRequest(username);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sol·licitud enviada!'),
            duration: Duration(seconds: 2),
          ),
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
      await _friendsApi.respondRequest(id, action);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeFriend(String id) async {
    try {
      await _friendsApi.removeFriend(id);
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
    return Container(
      color: const Color(0xFFF5F7FA),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'No s\'han pogut carregar les dades',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SectionTitle(title: "Els teus amics"),
                                        TextButton.icon(
                                          onPressed: () => _showSearchDialog(),
                                          icon: const Icon(Icons.person_add, size: 20),
                                          label: const Text('Afegir'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(0xFF00B089),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (friends.isEmpty)
                                      _emptyFriends()
                                    else
                                      ...friends.map((friend) {
                                        final user = friend['friend'];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Colors.grey[200]!),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(0xFF00B089).withOpacity(0.15),
                                              child: Text(
                                                user['name']?[0] ?? '?',
                                                style: const TextStyle(
                                                  color: Color(0xFF00B089),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              user['name'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text("@${user['username'] ?? ''}"),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.person_remove, color: Colors.grey),
                                              tooltip: 'Eliminar amic',
                                              onPressed: () => _removeFriend(friend['friendshipId']),
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SectionTitle(title: "Sol·licituds pendents"),
                                    const SizedBox(height: 12),
                                    if (requests.isEmpty)
                                      _emptyRequests()
                                    else
                                      ...requests.map((req) {
                                        final user = req['user'];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Colors.grey[200]!),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(0xFF00B089).withOpacity(0.15),
                                              child: Text(
                                                user['name']?[0] ?? '?',
                                                style: const TextStyle(
                                                  color: Color(0xFF00B089),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              user['name'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text("@${user['username'] ?? ''}"),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                                  tooltip: 'Acceptar',
                                                  onPressed: () => _respondRequest(req['id'], 'accept'),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                                  tooltip: 'Rebutjar',
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SectionTitle(title: "Els teus amics"),
                                TextButton.icon(
                                  onPressed: () => _showSearchDialog(),
                                  icon: const Icon(Icons.person_add, size: 20),
                                  label: const Text('Afegir'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF00B089),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (friends.isEmpty)
                              _emptyFriends()
                            else
                              ...friends.map((friend) {
                                final user = friend['friend'];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF00B089).withOpacity(0.15),
                                      child: Text(
                                        user['name']?[0] ?? '?',
                                        style: const TextStyle(
                                          color: Color(0xFF00B089),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text("@${user['username'] ?? ''}"),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.person_remove, color: Colors.grey),
                                      tooltip: 'Eliminar amic',
                                      onPressed: () => _removeFriend(friend['friendshipId']),
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 24),
                            const SectionTitle(title: "Sol·licituds pendents"),
                            const SizedBox(height: 12),
                            if (requests.isEmpty)
                              _emptyRequests()
                            else
                              ...requests.map((req) {
                                final user = req['user'];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF00B089).withOpacity(0.15),
                                      child: Text(
                                        user['name']?[0] ?? '?',
                                        style: const TextStyle(
                                          color: Color(0xFF00B089),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text("@${user['username'] ?? ''}"),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                          tooltip: 'Acceptar',
                                          onPressed: () => _respondRequest(req['id'], 'accept'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                          tooltip: 'Rebutjar',
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

  Widget _emptyFriends() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Encara no tens amics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Cerca usuaris per connectar',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Cercar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B089),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRequests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.mail_outline, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No tens sol·licituds',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Les sol·licituds pendents apareixeran aquí',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    List<dynamic> searchResults = [];
    bool searching = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                      onChanged: (value) async {
                        if (value.length >= 2) {
                          setDialogState(() => searching = true);
                          try {
                            final results = await _friendsApi.searchUsers(value);
                            setDialogState(() {
                              searchResults = results;
                              searching = false;
                            });
                          } catch (e) {
                            setDialogState(() => searching = false);
                          }
                        } else {
                          setDialogState(() {
                            searchResults = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (searching)
                      const SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            final isFriend = user['isFriend'] ?? false;
                            final requestSent = user['requestSent'] ?? false;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF00B089).withOpacity(0.15),
                                child: Text(
                                  user['name']?[0] ?? '?',
                                  style: const TextStyle(
                                    color: Color(0xFF00B089),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user['name'] ?? ''),
                              subtitle: Text("@${user['username'] ?? ''}"),
                              trailing: isFriend
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : requestSent
                                      ? const Text('Enviat', style: TextStyle(color: Colors.grey))
                                      : ElevatedButton(
                                          onPressed: () {
                                            _sendRequest(user['username']);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00B089),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Afegir'),
                                        ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Tancar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
