class FoodItem {
  final String name;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final String servingSize;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.servingSize = '1 porsi',
  });
}

// Database makanan lokal Indonesia & umum
const List<FoodItem> foodDatabase = [
  FoodItem(name: 'Nasi Putih', calories: 175, carbs: 40, protein: 3, fat: 0.4, servingSize: '1 centong (100g)'),
  FoodItem(name: 'Nasi Goreng', calories: 330, carbs: 42, protein: 8, fat: 14, servingSize: '1 porsi (200g)'),
  FoodItem(name: 'Nasi Uduk', calories: 260, carbs: 36, protein: 5, fat: 11, servingSize: '1 porsi (150g)'),
  FoodItem(name: 'Ayam Goreng', calories: 260, carbs: 0, protein: 25, fat: 17, servingSize: '1 potong (100g)'),
  FoodItem(name: 'Dada Ayam Rebus', calories: 165, carbs: 0, protein: 31, fat: 3.6, servingSize: '100g'),
  FoodItem(name: 'Telur Dadar', calories: 110, carbs: 0.6, protein: 7, fat: 9, servingSize: '1 butir'),
  FoodItem(name: 'Telur Ceplok', calories: 90, carbs: 0.4, protein: 6.3, fat: 7, servingSize: '1 butir'),
  FoodItem(name: 'Telur Rebus', calories: 78, carbs: 0.6, protein: 6.3, fat: 5.3, servingSize: '1 butir'),
  FoodItem(name: 'Tahu Goreng', calories: 78, carbs: 2, protein: 8, fat: 5, servingSize: '1 buah (50g)'),
  FoodItem(name: 'Tempe Goreng', calories: 118, carbs: 8, protein: 7, fat: 7, servingSize: '1 potong (50g)'),
  FoodItem(name: 'Soto Ayam', calories: 310, carbs: 25, protein: 20, fat: 12, servingSize: '1 mangkok'),
  FoodItem(name: 'Bakso Sapi', calories: 350, carbs: 32, protein: 18, fat: 16, servingSize: '1 mangkok'),
  FoodItem(name: 'Rendang Daging', calories: 195, carbs: 4, protein: 15, fat: 13, servingSize: '1 potong (50g)'),
  FoodItem(name: 'Gado-Gado', calories: 318, carbs: 35, protein: 14, fat: 14, servingSize: '1 porsi'),
  FoodItem(name: 'Mie Goreng Instant', calories: 380, carbs: 54, protein: 8, fat: 15, servingSize: '1 bungkus'),
  FoodItem(name: 'Roti Tawar', calories: 80, carbs: 15, protein: 3, fat: 1, servingSize: '1 lembar'),
  FoodItem(name: 'Pisang Goreng', calories: 140, carbs: 24, protein: 1.5, fat: 4.5, servingSize: '1 buah'),
  FoodItem(name: 'Oatmeal', calories: 150, carbs: 27, protein: 5, fat: 3, servingSize: '1 mangkok (40g)'),
  FoodItem(name: 'Alpukat', calories: 160, carbs: 8.5, protein: 2, fat: 15, servingSize: '1 buah sedang'),
  FoodItem(name: 'Susu UHT Full Cream', calories: 150, carbs: 12, protein: 8, fat: 8, servingSize: '1 gelas (250ml)'),
];
