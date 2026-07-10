import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mascot_widget.dart';
import '../services/app_i18n.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(AppI18n.t('community.leaderboard'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MascotWidget(expression: MascotExpression.excited, size: 120),
            const SizedBox(height: 20),
            Text(AppI18n.t('common.comingSoon'), style: GoogleFonts.poppins(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(AppI18n.t('community.competeDesc'), style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
