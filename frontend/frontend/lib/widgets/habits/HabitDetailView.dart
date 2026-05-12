import 'package:flowTracker/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habitProvider.dart';
import '../../providers/feedProvider.dart';

class HabitDetailView extends StatefulWidget {
  final dynamic habit;

  const HabitDetailView({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<HabitDetailView> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    final stats =
        context.watch<HabitProvider>().habitStats[habit['id']] ?? {};

    final progress =
        ((stats['completionRate'] ?? 0) / 100).toDouble();

    final streak = stats['currentStreak'] ?? 0;

    final tags = habit['tags'] ?? [];

    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        foregroundColor: context.textPrimaryColor,
        title: Text(
          "Detalls de l'hàbit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDarker,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ICON
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  SizedBox(height: 20),

                  /// NAME
                  Text(
                    habit['name'] ?? '',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 10),

                  /// DESCRIPTION
                  Text(
                    habit['description'] ?? 'Sense descripció',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 24),

                  /// STREAK
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),

                      SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Racha actual",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          Text(
                            "$streak dies",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            /// PROGRESS CARD
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.primary,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Progrés",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 14,
                      color: AppTheme.primary,
                      backgroundColor:
                          AppTheme.primary.withOpacity(0.12),
                    ),
                  ),

                  SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            /// TAGS
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(
                        Icons.sell_rounded,
                        color: AppTheme.primary,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Tags",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tags.isNotEmpty
                        ? tags.map<Widget>((tag) {
                            final name = tag is Map
                                ? tag['name']
                                : tag.toString();

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Text("Sense tags"),
                            ),
                          ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 36),

            /// TOGGLE BUTTON
            Builder(builder: (context) {
              final completedToday = stats['completedToday'] == true;
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          try {
                            // Toggle: if done today → unmark, if not → mark
                            await context.read<HabitProvider>().toggleHabit(
                                  habit['id'],
                                  !completedToday,
                                );
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => loading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completedToday
                        ? AppTheme.success
                        : AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: context.surfaceColor,
                          ),
                        )
                      : Icon(
                          completedToday
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                        ),
                  label: loading
                      ? SizedBox.shrink()
                      : Text(
                          completedToday ? "Desmarcar" : "Marcar com feta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),

            SizedBox(height: 12),

            // Share to Feed button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showShareDialog(context, habit),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: Icon(Icons.share_rounded, size: 18),
                label: Text(
                  'Compartir al feed',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, dynamic habit) {
    final controller = TextEditingController(
      text: 'Avui he completat el meu hàbit: ${habit['name']}! 💪',
    );
    bool posting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.share_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Compartir al feed', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 280,
            decoration: InputDecoration(
              hintText: 'Escriu el teu missatge...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: context.backgroundColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel·lar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: posting
                  ? null
                  : () async {
                      setDialogState(() => posting = true);
                      try {
                        await context.read<FeedProvider>().createPost(
                              controller.text.trim(),
                              habitId: habit['id'],
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Publicat al feed! 🎉'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => posting = false);
                      }
                    },
              child: posting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: context.surfaceColor),
                    )
                  : Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}