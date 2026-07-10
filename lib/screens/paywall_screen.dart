import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/game_state.dart';
import '../services/purchases_service.dart';
import '../services/app_i18n.dart';

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

  List<(String, String)> get _benefits => [
    ('❤️', AppI18n.t('paywall.benefit.lives')),
    ('🎯', AppI18n.t('paywall.benefit.practice')),
    ('⚔️', AppI18n.t('paywall.benefit.matches')),
    ('📊', AppI18n.t('paywall.benefit.stats')),
    ('🐼', AppI18n.t('paywall.benefit.mascots')),
    ('🗂️', AppI18n.t('paywall.benefit.history')),
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
        _error = AppI18n.t('paywall.error.notAvailable');
      } else if (offering == null) {
        _error = AppI18n.t('paywall.error.noPlans');
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
        _showDone(AppI18n.t('paywall.welcomePro'));
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        setState(() => _error = e.message ?? AppI18n.t('paywall.error.purchaseFailed'));
      }
    } catch (e) {
      if (mounted) setState(() => _error = AppI18n.t('paywall.error.purchaseFailedRetry'));
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
        _showDone(AppI18n.t('paywall.restored'));
      } else {
        setState(() => _error = AppI18n.t('paywall.error.noSubscription'));
      }
    } catch (e) {
      if (mounted) setState(() => _error = AppI18n.t('paywall.error.restoreFailed'));
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
        title: Text(AppI18n.t('paywall.title'),
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
                      child: Text(AppI18n.t('paywall.restorePurchases'),
                          style: GoogleFonts.nunito(
                              color: const Color(0xFF6B7A6E),
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppI18n.t('paywall.autoRenewNote'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: const Color(0xFF9AA89C)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legalLink(AppI18n.t('settings.termsOfService'), _termsUrl),
                        Text('  •  ',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: const Color(0xFF9AA89C))),
                        _legalLink(AppI18n.t('settings.privacyPolicy'), _privacyUrl),
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
        Text(AppI18n.t('paywall.unlockEverything'),
            style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D3A2E))),
        const SizedBox(height: 6),
        Text(AppI18n.t('paywall.masterWithoutLimits'),
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
