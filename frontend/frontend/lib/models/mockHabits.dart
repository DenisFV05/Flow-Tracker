import '../models/habit.dart';

final List<Habit> mockHabits = [
  Habit(
    id: "1",
    name: "Morning Exercise",
    description: "30 minutes cardio",
    tags: [Tag(id: "t1", name: "health")],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completedToday: true,
  ),
  Habit(
    id: "2",
    name: "Read 20 Pages",
    description: "Book reading habit",
    tags: [Tag(id: "t2", name: "study")],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completedToday: true,
  ),
  Habit(
    id: "3",
    name: "Meditation",
    description: "10 minutes mindfulness",
    tags: [Tag(id: "t3", name: "mental")],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completedToday: false,
  ),
  Habit(
    id: "4",
    name: "Estudiar Flutter",
    description: "Aprender Flutter bien",
    tags: [Tag(id: "t4", name: "study")],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completedToday: false,
  ),
  Habit(
    id: "5",
    name: "Estudiar Java",
    description: "Bases de Java",
    tags: [Tag(id: "t5", name: "study")],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completedToday: false,
  ),
];