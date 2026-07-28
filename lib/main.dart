import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/meal_item.dart';
import 'screens/paywall_dialog.dart';
import 'screens/add_food_screen.dart';

void main() {
  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatefulWidget {
  const NutriTrackApp({super.key});

  @override
  State<NutriTrackApp> createState() => _NutriTrackAppState();
}

class _NutriTrackAppState extends State<NutriTrackApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF1E3A8A),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF60A5FA),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: DashboardScreen(onToggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const DashboardScreen({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int age = 25;
  double weight = 65;
  double height = 170;
  String gender = 'Pria';
  double activityMultiplier = 1.375;

  int targetCalorie = 2000;
  int waterGlasses = 0;
  bool isLoading = true;
  bool isProUser = false;

  List<MealItem> meals = [];
  final List<int> weeklyHistory = [1850, 2100, 1950, 2200, 1800, 2050, 1900];
  final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _calculateTDEE() {
    double bmr = (gender == 'Pria')
        ? (10 * weight) + (6.25 * height) - (5 * age) + 5
        : (10 * weight) + (6.25 * height) - (5 * age) - 161;
    setState(() {
      targetCalorie = (bmr * activityMultiplier).round();
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      waterGlasses = prefs.getInt('waterGlasses') ?? 0;
      age = prefs.getInt('age') ?? 25;
      weight = prefs.getDouble('weight') ?? 65.0;
      height = prefs.getDouble('height') ?? 170.0;
      gender = prefs.getString('gender') ?? 'Pria';
      activityMultiplier = prefs.getDouble('activityMultiplier') ?? 1.375;
      isProUser = prefs.getBool('isProUser') ?? false;

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

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterGlasses', waterGlasses);
    await prefs.setInt('age', age);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setString('gender', gender);
    await prefs.setDouble('activityMultiplier', activityMultiplier);
    await prefs.setBool('isProUser', isProUser);

    final String encoded = jsonEncode(meals.map((e) => e.toJson()).toList());
    await prefs.setString('savedMeals', encoded);
  }

  int get totalConsumed => meals.fold(0, (sum, item) => sum + item.calories);
  int get carbsTarget => ((targetCalorie * 0.50) / 4).round();
  int get proteinTarget => ((targetCalorie * 0.25) / 4).round();
  int get fatTarget => ((targetCalorie * 0.25) / 9).round();

  int get carbsConsumed => ((totalConsumed * 0.50) / 4).round();
  int get proteinConsumed => ((totalConsumed * 0.25) / 4).round();
  int get fatConsumed => ((totalConsumed * 0.25) / 9).round();

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallDialog(
        isDarkMode: widget.isDarkMode,
        isProUser: isProUser,
        onProStatusChanged: (status) {
          setState(() => isProUser = status);
          _saveData();
        },
      ),
    );
  }

  void _showAnalyticsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        int avgCalorie = (weeklyHistory.reduce((a, b) => a + b) / weeklyHistory.length).round();
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📈 Analisis Konsumsi Mingguan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              const SizedBox(height: 8),
              Text('Rata-rata asupan: $avgCalorie kcal / hari', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    double heightFactor = (weeklyHistory[index] / (targetCalorie * 1.2)).clamp(0.1, 1.0);
                    bool isOver = weeklyHistory[index] > targetCalorie;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${weeklyHistory[index]}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Container(
                          width: 18,
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            color: isOver ? Colors.redAccent : const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(days[index], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              const Text('💡 Catatan NutriTrack:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Asupan mingguanmu cukup stabil! Pertahankan pola makan seimbang.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

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
                    const Text('Pengaturan Profil & Target BMR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
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

  // Fungsi untuk berpindah ke layar AddFoodScreen
  void _navigateToAddFoodScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );

    if (result != null && result is MealItem) {
      setState(() {
        meals.add(result);
      });
      _saveData();
    }
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
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : const Color(0xFF1E3A8A),
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.white),
            const SizedBox(width: 10),
            const Text('NutriTrack', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            if (isProUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
              )
            ]
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: widget.onToggleTheme,
            tooltip: 'Ganti Tema',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: _showAnalyticsDialog,
            tooltip: 'Grafik Mingguan',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _showProfileDialog,
            tooltip: 'Profil',
          ),
          IconButton(
            icon: Icon(Icons.workspace_premium, color: isProUser ? Colors.amber : Colors.white70),
            onPressed: _showPaywall,
            tooltip: 'NutriTrack Pro',
          ),
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
                                backgroundColor: Colors.grey[300],
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
                        _buildStatColumn('Terpakai', '$totalConsumed', 'kcal', const Color(0xFF0D9488)),
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
                            Text('$waterGlasses / 8 Gelas (200ml)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

            const Text('Jurnal Makanan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

      bottomSheet: isProUser
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              height: 48,
              color: widget.isDarkMode ? Colors.black26 : Colors.grey[200],
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
        onPressed: _navigateToAddFoodScreen,
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
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
