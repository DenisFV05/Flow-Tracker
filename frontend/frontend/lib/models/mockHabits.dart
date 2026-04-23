import '../models/habit.dart';

final List<Habit> mockHabits = [
  Habit(
    id: "1",
    title: "Morning Exercise",
    subtitle: "30 minutes cardio",
    tags: ["health"],
    progress: 0.86,
    completedToday: true,
  ),
  Habit(
    id: "2",
    title: "Read 20 Pages",
    subtitle: "Book reading habit",
    tags: ["study"],
    progress: 1.0,
    completedToday: true,
  ),
  Habit(
    id: "3",
    title: "Meditation",
    subtitle: "10 minutes mindfulness",
    tags: ["mental"],
    progress: 0.4,
    completedToday: false,
  ),
    Habit(
    id: "4",
    title: "Estudiar",
    subtitle: "Aprender flutter",
    tags: ["study"],
    progress: 1.0,
    completedToday: false,
  ),
      Habit(
    id: "5",
    title: "Estudiar",
    subtitle: "Aprender java",
    tags: ["study"],
    progress: 0.2,
    completedToday: false,
  ),
];
