class HabitStats {
  final String habitId;
  final int currentStreak;
  final int maxStreak;
  final int totalDays;
  final int completedDays;
  final double completionRate;
  final String? lastCompletedDate;

  HabitStats({
    required this.habitId,
    required this.currentStreak,
    required this.maxStreak,
    required this.totalDays,
    required this.completedDays,
    required this.completionRate,
    this.lastCompletedDate,
  });

  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      habitId: json['habitId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      completedDays: json['completedDays'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      lastCompletedDate: json['lastCompletedDate'],
    );
  }
}

class HeatmapData {
  final String habitId;
  final int year;
  final List<HeatmapDay> data;

  HeatmapData({
    required this.habitId,
    required this.year,
    required this.data,
  });

  factory HeatmapData.fromJson(Map<String, dynamic> json) {
    return HeatmapData(
      habitId: json['habitId'] ?? '',
      year: json['year'] ?? 0,
      data: (json['data'] as List)
          .map((d) => HeatmapDay.fromJson(d))
          .toList(),
    );
  }
}

class HeatmapDay {
  final String date;
  final bool completed;

  HeatmapDay({required this.date, required this.completed});

  factory HeatmapDay.fromJson(Map<String, dynamic> json) {
    return HeatmapDay(
      date: json['date'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}

class ChartDay {
  final String date;
  final bool completed;

  ChartDay({required this.date, required this.completed});

  factory ChartDay.fromJson(Map<String, dynamic> json) {
    return ChartDay(
      date: json['date'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}

class ProfileStats {
  final int totalHabits;
  final int totalLogs;
  final int completedLogs;
  final double overallCompletionRate;
  final int longestStreak;
  final int todayCompleted;
  final int todayTotal;

  ProfileStats({
    required this.totalHabits,
    required this.totalLogs,
    required this.completedLogs,
    required this.overallCompletionRate,
    required this.longestStreak,
    required this.todayCompleted,
    required this.todayTotal,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalHabits: json['totalHabits'] ?? 0,
      totalLogs: json['totalLogs'] ?? 0,
      completedLogs: json['completedLogs'] ?? 0,
      overallCompletionRate: (json['overallCompletionRate'] ?? 0).toDouble(),
      longestStreak: json['longestStreak'] ?? 0,
      todayCompleted: json['todayCompleted'] ?? 0,
      todayTotal: json['todayTotal'] ?? 0,
    );
  }
}