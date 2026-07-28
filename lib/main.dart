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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int targetCalorie = 2000;
  int consumedCalorie = 650;

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
                  _buildMealTile('Sarapan', '350 kcal', Icons.wb_sunny_outlined),
                  _buildMealTile('Makan Siang', '300 kcal', Icons.light_mode_outlined),
                  _buildMealTile('Makan Malam', 'Belum dicatat', Icons.nightlight_round_outlined),
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
    );
  }

  Widget _buildMealTile(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0D9488)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
