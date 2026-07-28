import 'package:flutter/material.dart';
import '../models/meal_item.dart';

class FoodItem {
  final String name;
  final double calories;
  final String servingSize;

  const FoodItem({
    required this.name,
    required this.calories,
    this.servingSize = '1 porsi',
  });
}

const List<FoodItem> foodDatabase = [
  FoodItem(name: 'Nasi Putih', calories: 175, servingSize: '1 centong (100g)'),
  FoodItem(name: 'Nasi Goreng', calories: 330, servingSize: '1 porsi (200g)'),
  FoodItem(name: 'Nasi Uduk', calories: 260, servingSize: '1 porsi (150g)'),
  FoodItem(name: 'Ayam Goreng', calories: 260, servingSize: '1 potong (100g)'),
  FoodItem(name: 'Dada Ayam Rebus', calories: 165, servingSize: '100g'),
  FoodItem(name: 'Telur Dadar', calories: 110, servingSize: '1 butir'),
  FoodItem(name: 'Telur Ceplok', calories: 90, servingSize: '1 butir'),
  FoodItem(name: 'Telur Rebus', calories: 78, servingSize: '1 butir'),
  FoodItem(name: 'Tahu Goreng', calories: 78, servingSize: '1 buah (50g)'),
  FoodItem(name: 'Tempe Goreng', calories: 118, servingSize: '1 potong (50g)'),
  FoodItem(name: 'Soto Ayam', calories: 310, servingSize: '1 mangkok'),
  FoodItem(name: 'Bakso Sapi', calories: 350, servingSize: '1 mangkok'),
  FoodItem(name: 'Rendang Daging', calories: 195, servingSize: '1 potong (50g)'),
  FoodItem(name: 'Gado-Gado', calories: 318, servingSize: '1 porsi'),
  FoodItem(name: 'Mie Goreng Instant', calories: 380, servingSize: '1 bungkus'),
];

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedCategory = 'Sarapan';
  FoodItem? _selectedFood;

  void _onFoodSelected(FoodItem item) {
    setState(() {
      _selectedFood = item;
      _nameController.text = item.name;
      _caloriesController.text = item.calories.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Makanan'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Text(
              'Cari Makanan di Database',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Autocomplete<FoodItem>(
              displayStringForOption: (FoodItem option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<FoodItem>.empty();
                }
                return foodDatabase.where((FoodItem option) {
                  return option.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (FoodItem selection) {
                _onFoodSelected(selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    hintText: 'Ketik misal: Nasi, Ayam, Telur...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                );
              },
            ),

            if (_selectedFood != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💡 Porsi standar: ${_selectedFood!.servingSize} (${_selectedFood!.calories.toInt()} kcal)',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              'Detail Catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Makanan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Kalori (kcal)',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.local_fire_department, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori Makanan',
                border: OutlineInputBorder(),
              ),
              items: ['Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final String name = _nameController.text.isEmpty
                      ? (_selectedFood?.name ?? 'Makanan')
                      : _nameController.text;
                  final int calories =
                      int.tryParse(_caloriesController.text) ?? 0;

                  if (calories > 0) {
                    final newMeal = MealItem(
                      name: name,
                      calories: calories,
                      category: _selectedCategory,
                    );
                    Navigator.pop(context, newMeal);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Masukkan kalori yang valid')),
                    );
                  }
                },
                child: const Text(
                  'Simpan Ke Jurnal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
