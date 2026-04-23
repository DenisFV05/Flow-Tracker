class Habit {
  final String id;
  final String name;
  final String? description;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool completedToday;

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.completedToday = false,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      tags: json['tags'] != null
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tags': tags.map((t) => t.name).toList(),
      };

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? completedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}

class Tag {
  final String id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
