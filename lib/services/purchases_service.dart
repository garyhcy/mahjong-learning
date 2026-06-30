import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/game_state.dart';

/// Wraps RevenueCat (purchases_flutter) for the Ludi Pro subscription.
///
/// Setup notes:
/// - Android public SDK key is configured below.
/// - iOS public SDK key is pending (Apple account still provisioning the
///   In-App Purchase Key). Fill [_iosApiKey] once available, then purchases
///   will work on iOS without further code changes.
/// - The RevenueCat entitlement that unlocks Pro is identified by [entitlementId].
class PurchasesService {
  PurchasesService._();

  /// RevenueCat public SDK keys (NOT secret — safe to ship in the app).
  static const String _androidApiKey = 'goog_KEaZIOSRNWEEpcHcKWjGHhSujDX';
  static const String _iosApiKey = ''; // TODO: fill in once Apple key is ready.

  /// The entitlement identifier configured in the RevenueCat dashboard.
  /// Granting this entitlement unlocks all Pro features.
  static const String entitlementId = 'pro';

  static bool _configured = false;

  /// Whether RevenueCat has a usable API key for the current platform.
  static bool get isAvailable {
    if (kIsWeb) return false;
    if (Platform.isAndroid) return _androidApiKey.isNotEmpty;
    if (Platform.isIOS) return _iosApiKey.isNotEmpty;
    return false;
  }

  /// Initialize the RevenueCat SDK. Safe to call multiple times.
  /// [appUserId] should be the Firebase UID so purchases follow the account.
  static Future<void> init({String? appUserId}) async {
    if (_configured || !isAvailable) return;
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
      final config = PurchasesConfiguration(apiKey)..appUserID = appUserId;
      await Purchases.configure(config);
      _configured = true;
    } catch (e) {
      debugPrint('PurchasesService.init failed: $e');
    }
  }

  /// Link purchases to a Firebase user. Call after sign-in.
  static Future<void> login(String uid) async {
    if (!_configured) return;
    try {
      await Purchases.logIn(uid);
    } catch (e) {
      debugPrint('PurchasesService.login failed: $e');
    }
  }

  /// Detach purchases from the current user. Call on sign-out.
  static Future<void> logout() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('PurchasesService.logout failed: $e');
    }
  }

  /// Fetch the current offering (set of packages) to display in the paywall.
  static Future<Offering?> getCurrentOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      debugPrint('PurchasesService.getCurrentOffering failed: $e');
      return null;
    }
  }

  /// Whether the user currently has the Pro entitlement active.
  static Future<bool> isPro() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('PurchasesService.isPro failed: $e');
      return false;
    }
  }

  /// Purchase a package. Returns true if Pro is now active.
  static Future<bool> purchase(Package package) async {
    if (!_configured) return false;
    final info = await Purchases.purchasePackage(package);
    return info.entitlements.active.containsKey(entitlementId);
  }

  /// Restore previous purchases. Returns true if Pro is now active.
  static Future<bool> restore() async {
    if (!_configured) return false;
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(entitlementId);
  }

  /// Listen to entitlement changes pushed by RevenueCat.
  static void addCustomerInfoListener(void Function(bool isPro) onChange) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener((info) {
      onChange(info.entitlements.active.containsKey(entitlementId));
    });
  }

  /// Sync current Pro entitlement into [GameState] and keep it updated when
  /// RevenueCat pushes entitlement changes.
  static Future<void> syncToGameState(GameState gameState) async {
    if (!_configured) return;
    final pro = await isPro();
    gameState.setPremium(pro);
    addCustomerInfoListener((isPro) => gameState.setPremium(isPro));
  }
}
