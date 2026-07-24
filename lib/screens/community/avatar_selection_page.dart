import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/community/avatar_option.dart';
import '../../widgets/mascot_widget.dart';
import '../../services/app_i18n.dart';


// ═══════════════════════════════════════════════════════════════
// ─── Avatar Selection Page ───
// ═══════════════════════════════════════════════════════════════
class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage();

  @override
  State<AvatarSelectionPage> createState() => AvatarSelectionPageState();
}

class AvatarSelectionPageState extends State<AvatarSelectionPage> {
  String _selectedId = 'happy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppI18n.t('community.chooseAvatar'),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Preview
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatarOptions
                      .firstWhere((a) => a.id == _selectedId)
                      .frameColor,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: MascotWidget(
                  expression: avatarOptions
                      .firstWhere((a) => a.id == _selectedId)
                      .expression,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Free avatars
            Text(AppI18n.t('community.mascotExpressions'),
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: avatarOptions
                  .where((a) => !a.isLocked)
                  .map((a) => _avatarGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Pro frames
            Row(
              children: [
                Text(AppI18n.t('community.proFrames'),
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2D2D))),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('PRO',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE65100))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: avatarOptions
                  .where((a) => a.isLocked)
                  .map((a) => _avatarGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppI18n.t('community.avatarUpdated'),
                          style: GoogleFonts.nunito()),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(AppI18n.t('community.saveAvatar'),
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarGridItem(AvatarOption option) {
    final isSelected = option.id == _selectedId;
    return GestureDetector(
      onTap: () {
        if (!option.isLocked) {
          setState(() => _selectedId = option.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppI18n.t('community.upgradeToUnlock'),
                  style: GoogleFonts.nunito()),
              backgroundColor: const Color(0xFFE65100),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? option.frameColor.withAlpha(20)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? option.frameColor : const Color(0xFFE0E0E0),
                width: isSelected ? 3 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: MascotWidget(
                    expression: option.expression,
                    size: 50,
                  ),
                ),
                if (option.isLocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(option.label,
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: option.isLocked
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFF424242)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
