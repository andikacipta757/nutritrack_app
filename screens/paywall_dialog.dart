import 'package:flutter/material.dart';

class PaywallDialog extends StatefulWidget {
  final bool isDarkMode;
  final bool isProUser;
  final Function(bool) onProStatusChanged;

  const PaywallDialog({
    super.key,
    required this.isDarkMode,
    required this.isProUser,
    required this.onProStatusChanged,
  });

  @override
  State<PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends State<PaywallDialog> {
  String selectedPlan = 'monthly';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
              const SizedBox(width: 8),
              Text(
                'NutriTrack PRO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.amber : const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Buka seluruh potensi kesehatanmu tanpa batas!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          _buildProFeature(Icons.block, '100% Bebas Iklan Banner & Pop-up'),
          _buildProFeature(Icons.insights, 'Analisis Makronutrisi & Laporan Mingguan Lengkap'),
          _buildProFeature(Icons.cloud_sync, 'Backup Otomatis Cloud (Multi Devices)'),
          _buildProFeature(Icons.support_agent, 'Dukungan Prioritas Kebutuhan Nutrisi'),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => selectedPlan = 'monthly'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedPlan == 'monthly' ? const Color(0xFF0D9488) : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: selectedPlan == 'monthly' ? const Color(0xFF0D9488).withOpacity(0.1) : Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paket Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Batalkan kapan saja', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  Text('Rp 49.000 / bln', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D9488))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => selectedPlan = 'yearly'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedPlan == 'yearly' ? const Color(0xFF0D9488) : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: selectedPlan == 'yearly' ? const Color(0xFF0D9488).withOpacity(0.1) : Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paket Tahunan (Hemat 40%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Tagihan Rp 349.000 / tahun', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  Text('Rp 29.000 / bln', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D9488))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onProStatusChanged(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Selamat! Anda sekarang adalah Pengguna NutriTrack PRO!')),
                );
              },
              child: const Text(
                'Aktifkan NutriTrack PRO (Simulasi)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.isProUser)
            Center(
              child: TextButton(
                onPressed: () {
                  widget.onProStatusChanged(false);
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Free Tier (Reset)', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
