import 'package:flutter/material.dart';
import '../data/food_data.dart';
import '../models/meal_item.dart';

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

            // Autocomplete Search
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
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
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
                prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange),
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
                  final int calories = int.tryParse(_caloriesController.text) ?? 0;

                  if (calories > 0) {
                    final newMeal = MealItem(
                      name: name,
                      calories: calories,
                      category: _selectedCategory,
                    );
                    Navigator.pop(context, newMeal);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan kalori yang valid')),
                    );
                  }
                },
                child: const Text(
                  'Simpan Ke Jurnal',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
