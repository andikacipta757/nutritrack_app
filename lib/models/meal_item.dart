class MealItem {
  final String name;
  final int calories;
  final String category;

  MealItem({
    required this.name,
    required this.calories,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'category': category,
      };

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      calories: json['calories'] ?? 0,
      category: json['category'] ?? 'Sarapan',
    );
  }
}
