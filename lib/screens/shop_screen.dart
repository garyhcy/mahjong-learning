import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_i18n.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(AppI18n.t('shop.title'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 4),
                Text('520',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(AppI18n.t('shop.popular')),
          const SizedBox(height: 12),
          _buildShopItem(
            icon: Icons.auto_awesome,
            title: AppI18n.t('shop.xpBooster'),
            description: AppI18n.t('shop.xpBoosterDesc'),
            price: '50',
            color: const Color(0xFFE8B93E),
          ),
          const SizedBox(height: 10),
          _buildShopItem(
            icon: Icons.favorite_rounded,
            title: AppI18n.t('shop.heartPack'),
            description: AppI18n.t('shop.heartPackDesc'),
            price: '30',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 10),
          _buildShopItem(
            icon: Icons.lock_open_rounded,
            title: AppI18n.t('shop.unlockTicket'),
            description: AppI18n.t('shop.unlockTicketDesc'),
            price: '100',
            color: const Color(0xFF5B9BD5),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppI18n.t('shop.limitedOffer')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppI18n.t('shop.starterPack'),
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 4),
                      Text(AppI18n.t('shop.starterPackDesc'),
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(AppI18n.t('shop.starterPackPrice'),
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppI18n.t('shop.themes')),
          const SizedBox(height: 12),
          _buildShopItem(
            icon: Icons.palette_rounded,
            title: AppI18n.t('shop.pandaTheme'),
            description: AppI18n.t('shop.pandaThemeDesc'),
            price: '200',
            color: const Color(0xFFE8B93E),
          ),
          const SizedBox(height: 10),
          _buildShopItem(
            icon: Icons.music_note_rounded,
            title: AppI18n.t('shop.newBgm'),
            description: AppI18n.t('shop.newBgmDesc'),
            price: '80',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF333333),
        ));
  }

  Widget _buildShopItem({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
                    )),
                const SizedBox(height: 3),
                Text(description,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    )),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond_rounded, color: color, size: 18),
              const SizedBox(width: 3),
              Text(price,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
