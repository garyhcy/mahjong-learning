import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mascot_widget.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Achievements', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MascotWidget(expression: MascotExpression.content, size: 120),
            const SizedBox(height: 20),
            Text('Coming Soon!', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Unlock badges and track your progress', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
