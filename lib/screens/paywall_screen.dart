import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/game_state.dart';
import '../services/purchases_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  static const Color _gold = Color(0xFFE8B93E);
  static const Color _bg = Color(0xFFF5F9F3);
  static const String _termsUrl =
      'https://garyhcy.github.io/mahjong-learning/legal/terms.html';
  static const String _privacyUrl =
      'https://garyhcy.github.io/mahjong-learning/legal/privacy.html';

  Offering? _offering;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  static const List<(String, String)> _benefits = [
    ('❤️', 'Unlimited lives — never wait to keep learning'),
    ('🎯', 'Unlimited daily practice across all 5 modes'),
    ('⚔️', 'Unlimited matches with priority pairing'),
    ('📊', 'Full leaderboard stats — win rate, fan distribution'),
    ('🐼', 'Exclusive mascots and avatar frames'),
    ('🗂️', 'Complete game history and review records'),
  ];

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    final offering = await PurchasesService.getCurrentOffering();
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loading = false;
      if (!PurchasesService.isAvailable) {
        _error = 'Subscriptions are not available on this platform yet.';
      } else if (offering == null) {
        _error = 'No plans available right now. Please try again later.';
      }
    });
  }

  Future<void> _buy(Package package) async {
    setState(() {
      _purchasing = true;
      _error = null;
    });
    try {
      final isPro = await PurchasesService.purchase(package);
      if (!mounted) return;
      if (isPro) {
        context.read<GameState>().setPremium(true);
        _showDone('Welcome to Ludi Pro! 🎉');
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        setState(() => _error = e.message ?? 'Purchase failed.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Purchase failed. Please try again.');
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _purchasing = true;
      _error = null;
    });
    try {
      final isPro = await PurchasesService.restore();
      if (!mounted) return;
      if (isPro) {
        context.read<GameState>().setPremium(true);
        _showDone('Purchases restored 🎉');
      } else {
        setState(() => _error = 'No active subscription found to restore.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Restore failed. Please try again.');
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _showDone(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3A2E),
        title: Text('Ludi Pro',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(),
                    const SizedBox(height: 24),
                    ..._benefits.map(_benefitRow),
                    const SizedBox(height: 24),
                    if (_error != null) _errorBox(_error!),
                    if (_offering != null) ..._planButtons(_offering!),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _purchasing ? null : _restore,
                      child: Text('Restore Purchases',
                          style: GoogleFonts.nunito(
                              color: const Color(0xFF6B7A6E),
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subscription auto-renews unless cancelled at least 24 hours before the end of the period. Manage in your store account settings.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: const Color(0xFF9AA89C)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legalLink('Terms of Use', _termsUrl),
                        Text('  •  ',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: const Color(0xFF9AA89C))),
                        _legalLink('Privacy Policy', _privacyUrl),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_gold, Color(0xFFF5D060)]),
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        Text('Unlock Everything',
            style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D3A2E))),
        const SizedBox(height: 6),
        Text('Master mahjong without limits',
            style: GoogleFonts.nunito(
                fontSize: 14, color: const Color(0xFF6B7A6E))),
      ],
    );
  }

  Widget _benefitRow((String, String) b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(b.$1, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(b.$2,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3A2E))),
          ),
        ],
      ),
    );
  }

  List<Widget> _planButtons(Offering offering) {
    final packages = offering.availablePackages;
    return packages.map((p) {
      final product = p.storeProduct;
      final isAnnual = p.packageType == PackageType.annual;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          onPressed: _purchasing ? null : () => _buy(p),
          style: ElevatedButton.styleFrom(
            backgroundColor: isAnnual ? _gold : Colors.white,
            foregroundColor:
                isAnnual ? Colors.white : const Color(0xFF2D3A2E),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: _gold, width: isAnnual ? 0 : 1.5),
            ),
          ),
          child: _purchasing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Column(
                  children: [
                    Text(product.title.replaceAll(RegExp(r'\(.*\)'), '').trim(),
                        style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(product.priceString,
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      );
    }).toList();
  }

  Widget _legalLink(String text, String url) {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      },
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 11,
              color: const Color(0xFF9AA89C))),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.w600)),
    );
  }
}
