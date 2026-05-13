class Habit {
  final String id;
  final String title;
  final String subtitle;
  final List<String> tags;
  final double progress;
  final bool completedToday;

  Habit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.progress,
    required this.completedToday,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<String>? tags,
    double? progress,
    bool? completedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tags: tags ?? this.tags,
      progress: progress ?? this.progress,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}
