import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF1E3A8A),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      home: const DashboardScreen(),
    );
  }
}

class MealItem {
  final String name;
  final int calories;
  final String category;

  MealItem({required this.name, required this.calories, required this.category});

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Data Profil Pengguna & BMR
  int age = 25;
  double weight = 65; // kg
  double height = 170; // cm
  String gender = 'Pria'; // 'Pria' atau 'Wanita'
  double activityMultiplier = 1.375; // Ringan
  
  int targetCalorie = 2000;
  int waterGlasses = 0;
  bool isLoading = true;

  List<MealItem> meals = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // --- MENGHITUNG TDEE (TARGET KALORI OTOMATIS) ---
  void _calculateTDEE() {
    double bmr;
    if (gender == 'Pria') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    setState(() {
      targetCalorie = (bmr * activityMultiplier).round();
    });
  }

  // --- MEMBACA DATA LOKAL ---
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      waterGlasses = prefs.getInt('waterGlasses') ?? 0;
      age = prefs.getInt('age') ?? 25;
      weight = prefs.getDouble('weight') ?? 65.0;
      height = prefs.getDouble('height') ?? 170.0;
      gender = prefs.getString('gender') ?? 'Pria';
      activityMultiplier = prefs.getDouble('activityMultiplier') ?? 1.375;

      _calculateTDEE();

      final String? mealsString = prefs.getString('savedMeals');
      if (mealsString != null) {
        final List<dynamic> decoded = jsonDecode(mealsString);
        meals = decoded.map((item) => MealItem.fromJson(item)).toList();
      } else {
        meals = [
          MealItem(name: 'Oatmeal & Pisang', calories: 320, category: 'Sarapan'),
          MealItem(name: 'Ayam Bakar & Nasi Merah', calories: 550, category: 'Makan Siang'),
        ];
      }
      isLoading = false;
    });
  }

  // --- MENYIMPAN DATA LOKAL ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterGlasses', waterGlasses);
    await prefs.setInt('age', age);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setString('gender', gender);
    await prefs.setDouble('activityMultiplier', activityMultiplier);

    final String encoded = jsonEncode(meals.map((e) => e.toJson()).toList());
    await prefs.setString('savedMeals', encoded);
  }

  int get totalConsumed => meals.fold(0, (sum, item) => sum + item.calories);

  // Target Makro berdasarkan % Kalori (50% Karbo, 25% Protein, 25% Lemak)
  int get carbsTarget => ((targetCalorie * 0.50) / 4).round();
  int get proteinTarget => ((targetCalorie * 0.25) / 4).round();
  int get fatTarget => ((targetCalorie * 0.25) / 9).round();

  // Estimasi Makro Terkonsumsi (Simulasi Rasio Rata-rata Makanan)
  int get carbsConsumed => ((totalConsumed * 0.50) / 4).round();
  int get proteinConsumed => ((totalConsumed * 0.25) / 4).round();
  int get fatConsumed => ((totalConsumed * 0.25) / 9).round();

  // --- DIALOG EDIT PROFIL & HITUNG BMR ---
  void _showProfileDialog() {
    final ageController = TextEditingController(text: age.toString());
    final weightController = TextEditingController(text: weight.toString());
    final heightController = TextEditingController(text: height.toString());
    String tempGender = gender;
    double tempActivity = activityMultiplier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pengaturan Profil & Target BMR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tempGender,
                            decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                            items: ['Pria', 'Wanita'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setModalState(() => tempGender = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Usia (Thn)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'BB (kg)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'TB (cm)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<double>(
                      value: tempActivity,
                      decoration: const InputDecoration(labelText: 'Tingkat Aktivitas Harian', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 1.2, child: Text('Sedenter (Jarang Olahraga)')),
                        DropdownMenuItem(value: 1.375, child: Text('Ringan (Olahraga 1-3x/minggu)')),
                        DropdownMenuItem(value: 1.55, child: Text('Sedang (Olahraga 3-5x/minggu)')),
                        DropdownMenuItem(value: 1.725, child: Text('Berat (Olahraga 6-7x/minggu)')),
                      ],
                      onChanged: (v) => setModalState(() => tempActivity = v!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            gender = tempGender;
                            age = int.tryParse(ageController.text) ?? age;
                            weight = double.tryParse(weightController.text) ?? weight;
                            height = double.tryParse(heightController.text) ?? height;
                            activityMultiplier = tempActivity;
                            _calculateTDEE();
                          });
                          _saveData();
                          Navigator.pop(context);
                        },
                        child: const Text('Hitung Ulang Target Kalori', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddMealDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    String selectedCategory = 'Sarapan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catat Makanan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nama Makanan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: calController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Kalori (kcal)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    items: ['Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final cal = int.tryParse(calController.text.trim()) ?? 0;
                        if (name.isNotEmpty && cal > 0) {
                          setState(() {
                            meals.add(MealItem(name: name, calories: cal, category: selectedCategory));
                          });
                          _saveData();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan Catatan', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))));
    }

    int remaining = targetCalorie - totalConsumed;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Row(
          children: [
            Icon(Icons.restaurant, color: Colors.white),
            SizedBox(width: 10),
            Text('NutriTrack', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _showProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Premium: Bebas Iklan & Analisis Lengkap!')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Target (BMR)', '$targetCalorie', 'kcal', Colors.grey),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90, height: 90,
                              child: CircularProgressIndicator(
                                value: (totalConsumed / targetCalorie).clamp(0.0, 1.0),
                                strokeWidth: 8,
                                backgroundColor: Colors.grey[200],
                                color: remaining >= 0 ? const Color(0xFF0D9488) : Colors.red,
                              ),
                            ),
                            Column(
                              children: [
                                Text('$remaining', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: remaining >= 0 ? const Color(0xFF0D9488) : Colors.red)),
                                const Text('Sisa kcal', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                        _buildStatColumn('Terpakai', '$totalConsumed', 'kcal', const Color(0xFF1E3A8A)),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      children: [
                        Expanded(child: _buildMacroIndicator('Karbo', carbsConsumed, carbsTarget, Colors.orange)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMacroIndicator('Protein', proteinConsumed, proteinTarget, Colors.blue)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMacroIndicator('Lemak', fatConsumed, fatTarget, Colors.redAccent)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Asupan Air Minum', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$waterGlasses / 8 Gelas (200ml)', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
                          onPressed: () {
                            if (waterGlasses > 0) {
                              setState(() => waterGlasses--);
                              _saveData();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            if (waterGlasses < 12) {
                              setState(() => waterGlasses++);
                              _saveData();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Jurnal Makanan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 10),

            ...['Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan'].map((cat) {
              final categoryMeals = meals.where((m) => m.category == cat).toList();
              int catTotal = categoryMeals.fold(0, (sum, item) => sum + item.calories);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$catTotal kcal', style: const TextStyle(color: Color(0xFF0D9488), fontSize: 12)),
                  children: [
                    if (categoryMeals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Belum ada catatan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      )
                    else
                      ...categoryMeals.map((item) => ListTile(
                            dense: true,
                            title: Text(item.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${item.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                  onPressed: () {
                                    setState(() => meals.remove(item));
                                    _saveData();
                                  },
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              );
            }),

            const SizedBox(height: 50),
          ],
        ),
      ),

      bottomSheet: Container(
        width: double.infinity,
        height: 48,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ad_units, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text('📢 [AdMob Banner Slot - Free Tier]', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMealDialog,
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Makan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildMacroIndicator(String label, int current, int target, Color color) {
    double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${current}/${target}g', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
