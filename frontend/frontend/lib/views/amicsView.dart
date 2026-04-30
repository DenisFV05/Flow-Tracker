import 'package:flutter/material.dart';

import '../widgets/SectionTitle.dart';
import '../widgets/stats/quickStats.dart';
import 'crearHabit.dart';

/// =======================
/// MOCK FRIEND MODEL
/// =======================
class MockFriend {
  final String name;
  final String username;
  final double progress;
  final bool activeToday;

  MockFriend({
    required this.name,
    required this.username,
    required this.progress,
    required this.activeToday,
  });
}

/// =======================
/// MOCK DATA
/// =======================
final List<MockFriend> mockFriends = [
  MockFriend(
    name: "Anna",
    username: "anna_dev",
    progress: 0.7,
    activeToday: true,
  ),
  MockFriend(
    name: "Marc",
    username: "marc_flutter",
    progress: 0.4,
    activeToday: false,
  ),
  MockFriend(
    name: "Laia",
    username: "laia_code",
    progress: 0.9,
    activeToday: true,
  ),
];

class AmicsView extends StatelessWidget {
  const AmicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amics"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                showCrearHabitPopup(context);
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Afegir amic"),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
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

                        ...mockFriends.map((friend) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(friend.name[0]),
                              ),
                              title: Text(friend.name),
                              subtitle: Text("@${friend.username}"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(friend.progress * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: friend.activeToday
                                        ? Colors.green
                                        : Colors.grey,
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// ======================
                  /// 📊 RIGHT PANEL
                  /// ======================
                  const Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(title: "Resum social"),
                        SizedBox(height: 10),
                        QuickStats(),
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

                ...mockFriends.map((friend) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(friend.name[0]),
                      ),
                      title: Text(friend.name),
                      subtitle: Text("@${friend.username}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(friend.progress * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: friend.activeToday
                                ? Colors.green
                                : Colors.grey,
                          )
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                const SectionTitle(title: "Resum social"),
                const SizedBox(height: 10),
                const QuickStats(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// =======================
/// POPUP
/// =======================
void showCrearHabitPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: CrearHabitForm(),
        ),
      );
    },
  );
}
