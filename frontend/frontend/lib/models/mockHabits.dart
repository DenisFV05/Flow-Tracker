import '../models/habit.dart';

final List<Habit> mockHabits = [
  Habit(
    id: "1",
    title: "Exercicis al matí",
    subtitle: "Caminar 30 minuts",
    tags: ["salut"],
    progress: 0.86,
    completedToday: true,
  ),
  Habit(
    id: "2",
    title: "Llegir un llibre",
    subtitle: "Habit de lectura",
    tags: ["temps_lliure"],
    progress: 1.0,
    completedToday: true,
  ),
  Habit(
    id: "3",
    title: "Netejar la casa",
    subtitle: "Escombrar l'habitació",
    tags: ["tasques"],
    progress: 0.4,
    completedToday: false,
  ),
    Habit(
    id: "4",
    title: "Projecte UI",
    subtitle: "Estudiar flutter",
    tags: ["estudis"],
    progress: 1.0,
    completedToday: true,
  ),
    Habit(
    id: "5",
    title: "Projecte API",
    subtitle: "Fer l'api",
    tags: ["estudis"],
    progress: 0.2,
    completedToday: false,
  ),
];
