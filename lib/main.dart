import 'package:flutter/material.dart';

void main() {
  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF1E3A8A),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class MealItem {
  final String title;
  final int calories;
  final IconData icon;

  MealItem({required this.title, required this.calories, required this.icon});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int targetCalorie = 2000;
  
  // List makanan yang bisa bertambah secara dinamis
  final List<MealItem> meals = [
    MealItem(title: 'Sarapan', calories: 350, icon: Icons.wb_sunny_outlined),
    MealItem(title: 'Makan Siang', calories: 300, icon: Icons.light_mode_outlined),
  ];

  int get consumedCalorie {
    return meals.fold(0, (sum, item) => sum + item.calories);
  }

  void _showAddMealDialog() {
    final titleController = TextEditingController();
    final calorieController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Makanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Makanan/Sesi',
                  hintText: 'Misal: Makan Malam / Snack',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kalori (kcal)',
                  hintText: 'Misal: 450',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = titleController.text.trim();
                final cal = int.tryParse(calorieController.text.trim()) ?? 0;

                if (name.isNotEmpty && cal > 0) {
                  setState(() {
                    meals.add(MealItem(
                      title: name,
                      calories: cal,
                      icon: Icons.restaurant_menu,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int remainingCalorie = targetCalorie - consumedCalorie;
    double progress = (consumedCalorie / targetCalorie).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTrack Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ringkasan Kalori Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Target: $targetCalorie kcal', style: const TextStyle(color: Colors.grey)),
                                  Text('Masuk: $consumedCalorie kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                                ],
                              ),
                              Text(
                                'Sisa: $remainingCalorie kcal',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: remainingCalorie >= 0 ? const Color(0xFF0D9488) : Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: const Color(0xFF0D9488),
                            minHeight: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Catatan Makan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final item = meals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Icon(item.icon, color: const Color(0xFF0D9488)),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${item.calories} kcal'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  meals.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Area Banner Ad (Fitur Free Tier)
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Text('📢 [Google AdMob Banner Ad Area]', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealDialog,
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
