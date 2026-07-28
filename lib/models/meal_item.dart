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

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
        name: json['name'] as String,
        calories: json['calories'] as int,
        category: json['category'] as String,
      );
}
