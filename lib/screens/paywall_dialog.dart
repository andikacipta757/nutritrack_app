import 'package:flutter/material.dart';

class PaywallDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, size: 60, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'NutriTrack Pro',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nikmati pengalaman tanpa iklan dan fitur analisis nutrisi lengkap!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                onProStatusChanged(!isProUser);
                Navigator.pop(context);
              },
              child: Text(
                isProUser ? 'Batalkan Status Pro' : 'Aktifkan Pro (Simulasi)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
