import 'package:flutter/material.dart';

/// Ludi i18n — central string table.
///
/// Two display languages: English (en) and Chinese (zh).
/// Cantonese and Mandarin share the same zh strings for UI labels;
/// they only differ in matchmaking language selection.
enum DisplayLang { en, zh }

/// Global current display language. Set on first launch and in Settings.
/// Accessed via [AppI18n.of(context)] or directly as a static for non-widget code.
class AppI18n extends ChangeNotifier {
  static DisplayLang _current = DisplayLang.en;
  static DisplayLang get current => _current;

  static void set(DisplayLang lang) {
    if (_current == lang) return;
    _current = lang;
    // Notify listeners via a singleton instance registered in provider tree.
    _instance?._notify();
  }

  static AppI18n? _instance;
  AppI18n() {
    _instance = this;
  }

  void _notify() => notifyListeners();

  /// Public method to notify listeners after [AppI18n.set] changes language.
  void renotify() => notifyListeners();

  /// Get a string for the current language.
  static String t(String key) {
    final en = _strings[key]?['en'] ?? key;
    final zh = _strings[key]?['zh'] ?? key;
    return _current == DisplayLang.zh ? zh : en;
  }

  /// Helper for widgets: t(context, key)
  static String of(BuildContext context, String key) => t(key);
}

/// All UI strings. Keys are stable identifiers.
/// Add new keys here when introducing new UI text.
const Map<String, Map<String, String>> _strings = {
  // ── Nav ──
  'nav.home': {'en': 'Home', 'zh': '首頁'},
  'nav.community': {'en': 'Community', 'zh': '社區'},
  'nav.practice': {'en': 'Practice', 'zh': '練習'},
  'nav.more': {'en': 'More', 'zh': '更多'},

  // ── Auth ──
  'auth.appName': {'en': 'Ludi', 'zh': 'Ludi'},
  'auth.tagline': {'en': 'Master the Game', 'zh': '精通麻將'},
  'auth.email': {'en': 'Email', 'zh': '電郵'},
  'auth.emailHint': {'en': 'you@example.com', 'zh': 'you@example.com'},
  'auth.password': {'en': 'Password', 'zh': '密碼'},
  'auth.signIn': {'en': 'Sign In', 'zh': '登入'},
  'auth.createAccount': {'en': 'Create Account', 'zh': '建立帳號'},
  'auth.noAccount': {'en': "Don't have an account?", 'zh': '還沒有帳號？'},
  'auth.haveAccount': {'en': 'Already have an account?', 'zh': '已有帳號？'},
  'auth.signUp': {'en': 'Sign Up', 'zh': '註冊'},
  'auth.orContinueWith': {'en': 'or continue with', 'zh': '或使用以下方式'},
  'auth.enterEmail': {'en': 'Please enter your email', 'zh': '請輸入電郵'},
  'auth.validEmail': {'en': 'Please enter a valid email', 'zh': '請輸入有效的電郵'},
  'auth.enterPassword': {'en': 'Please enter your password', 'zh': '請輸入密碼'},
  'auth.weakPassword': {'en': 'Password must be at least 6 characters', 'zh': '密碼至少 6 個字元'},
  'auth.noAccountFound': {'en': 'No account found with this email.', 'zh': '找不到此電郵的帳號。'},
  'auth.wrongPassword': {'en': 'Incorrect password. Please try again.', 'zh': '密碼不正確，請重試。'},
  'auth.emailInUse': {'en': 'An account with this email already exists.', 'zh': '此電郵已註冊。'},
  'auth.authFailed': {'en': 'Authentication failed. Please try again.', 'zh': '認證失敗，請重試。'},
  'auth.socialFailed': {'en': 'Sign-in was cancelled or failed. Please try again.', 'zh': '登入已取消或失敗，請重試。'},
  'auth.unexpected': {'en': 'An unexpected error occurred. Please try again.', 'zh': '發生未預期的錯誤，請重試。'},

  // ── Language selection ──
  'lang.title': {'en': 'Choose your language', 'zh': '選擇你的語言'},
  'lang.subtitle': {'en': 'Used across the app and to match you with players', 'zh': '用於整個應用程式及配對對手'},
  'lang.chinese': {'en': '中文', 'zh': '中文'},
  'lang.english': {'en': 'English', 'zh': 'English'},

  // ── Settings ──
  'settings.title': {'en': 'Settings', 'zh': '設定'},
  'settings.account': {'en': 'Account', 'zh': '帳號'},
  'settings.playerName': {'en': 'Player Name', 'zh': '玩家名稱'},
  'settings.changePassword': {'en': 'Change Password', 'zh': '修改密碼'},
  'settings.email': {'en': 'Email', 'zh': '電郵'},
  'settings.preferences': {'en': 'Preferences', 'zh': '偏好設定'},
  'settings.notifications': {'en': 'Notifications', 'zh': '通知'},
  'settings.soundEffects': {'en': 'Sound Effects', 'zh': '音效'},
  'settings.hapticFeedback': {'en': 'Haptic Feedback', 'zh': '震動回饋'},
  'settings.bgm': {'en': 'Background Music', 'zh': '背景音樂'},
  'settings.language': {'en': 'Language', 'zh': '語言'},
  'settings.learning': {'en': 'Learning', 'zh': '學習'},
  'settings.dailyReminder': {'en': 'Daily Reminder', 'zh': '每日提醒'},
  'settings.resetProgress': {'en': 'Reset Progress', 'zh': '重置進度'},
  'settings.subscription': {'en': 'Subscription', 'zh': '訂閱'},
  'settings.upgradeToPro': {'en': 'Upgrade to Pro', 'zh': '升級至 Pro'},
  'settings.upgradeDesc': {'en': 'Unlimited lives, practice, matches, and exclusive avatar frames', 'zh': '無限生命、練習、約戰次數及專屬頭像框'},
  'settings.viewPlans': {'en': 'View Plans', 'zh': '查看方案'},
  'settings.about': {'en': 'About', 'zh': '關於'},
  'settings.version': {'en': 'Version', 'zh': '版本'},
  'settings.termsOfService': {'en': 'Terms of Service', 'zh': '服務條款'},
  'settings.privacyPolicy': {'en': 'Privacy Policy', 'zh': '隱私政策'},
  'settings.deleteAccount': {'en': 'Delete Account', 'zh': '刪除帳號'},
  'settings.signOut': {'en': 'Sign Out', 'zh': '登出'},

  // ── Find a Match ──
  'match.title': {'en': 'Find a Match', 'zh': '約戰'},
  'match.skillRating': {'en': 'Skill Rating', 'zh': '技術評分'},
  'match.skillDesc': {'en': 'Calculated from your progress & accuracy', 'zh': '根據你的進度與準確度計算'},
  'match.matchLanguage': {'en': 'Match Language', 'zh': '約戰語言'},
  'match.matchLanguageDesc': {'en': 'Players are paired in your chosen language', 'zh': '以你選擇的語言配對對手'},
  'match.preferredDays': {'en': 'Preferred Days', 'zh': '偏好日期'},
  'match.preferredDaysDesc': {'en': 'Pick the days you usually can play', 'zh': '選擇你通常可以玩的日期'},
  'match.noPreference': {'en': 'No Preference', 'zh': '無偏好'},
  'match.preferredTime': {'en': 'Preferred Time', 'zh': '偏好時段'},
  'match.preferredTimeDesc': {'en': 'Optional — leave on "No preference" if flexible', 'zh': '可選 — 保持「無偏好」則任意配對'},
  'match.noParticularPref': {'en': 'No particular preference', 'zh': '無特別偏好'},
  'match.findPlayers': {'en': 'Find a Match', 'zh': '尋找對手'},
  'match.noMatchesLeft': {'en': 'No matches left this week', 'zh': '本週已無約戰次數'},
  'match.proUnlimited': {'en': 'Pro: unlimited matches', 'zh': 'Pro：無限約戰'},
  'match.weeklyUsed': {'en': 'Weekly match used. Resets next week — or go Pro for unlimited.', 'zh': '本週約戰已用完，下週重置 — 或升級 Pro 享無限次數。'},
  'match.freeMatchLeft': {'en': '1 free match this week', 'zh': '本週尚餘 1 次免費約戰'},
  'match.schedulingTriesLeft': {'en': 'scheduling tries left', 'zh': '次配對嘗試剩餘'},

  // ── Match Room ──
  'room.closesIn': {'en': 'Closes in', 'zh': '剩餘'},
  'room.windowExpired': {'en': 'Window expired', 'zh': '配對窗口已過'},
  'room.proposeSlot': {'en': 'Propose a Day & Time', 'zh': '提議日期與時間'},
  'room.proposeAgain': {'en': 'Propose again in', 'zh': '可再次提議於'},
  'room.slotAgreed': {'en': 'Slot agreed — pick a venue below', 'zh': '時間已確認 — 請選擇場地'},
  'room.proposedSlots': {'en': 'Proposed slots — tap to vote', 'zh': '已提議時段 — 點擊投票'},
  'room.cantAgree': {'en': "Can't agree? Report unsuccessful", 'zh': '無法達成共識？回報失敗'},
  'room.pickVenue': {'en': 'Pick a venue', 'zh': '選擇場地'},
  'room.customVenue': {'en': 'Choose my own venue', 'zh': '我自己選擇場地'},
  'room.customVenueWarning': {'en': 'Ludi cannot guarantee pricing transparency or on-site staff for venues outside our network. Proceed with caution.', 'zh': 'Ludi 無法保證合作場地以外的收費透明度及駐場職員。請自行留意。'},
  'room.book': {'en': 'Book', 'zh': '預訂'},
  'room.reservationConfirmed': {'en': 'Reservation confirmed!', 'zh': '預訂成功！'},
  'room.seeYouAtTable': {'en': 'See you at the table', 'zh': '桌邊見'},
  'room.done': {'en': 'Done', 'zh': '完成'},
  'room.sendProposal': {'en': 'Send Proposal', 'zh': '發送提議'},
  'room.selectDate': {'en': 'Select Date', 'zh': '選擇日期'},
  'room.selectTime': {'en': 'Select Time', 'zh': '選擇時間'},
  'room.typeMessage': {'en': 'Type a message...', 'zh': '輸入訊息...'},
  'room.send': {'en': 'Send', 'zh': '發送'},
  'room.myRooms': {'en': 'My Match Rooms', 'zh': '我的約戰聊天室'},
  'room.noActiveRooms': {'en': 'No active match rooms', 'zh': '沒有進行中的約戰聊天室'},
  'room.proceed': {'en': 'Proceed', 'zh': '繼續'},
  'room.cancel': {'en': 'Cancel', 'zh': '取消'},

  // ── Community ──
  'community.friendLeaderboard': {'en': 'Friend Leaderboard', 'zh': '好友排行榜'},
  'community.addAll': {'en': 'Add', 'zh': '加入'},
  'community.viewAll': {'en': 'View All', 'zh': '查看全部'},
  'community.addFriend': {'en': 'Add Friend', 'zh': '加入好友'},
  'community.addFriendDesc': {'en': "Enter your friend's player number to connect.", 'zh': '輸入好友的玩家編號以加入。'},
  'community.playerNumber': {'en': 'Player Number', 'zh': '玩家編號'},
  'community.playerNumberHint': {'en': 'e.g. 100234', 'zh': '例如 100234'},
  'community.friendRequestSent': {'en': 'Friend request sent!', 'zh': '好友請求已發送！'},
  'community.playerNotFound': {'en': 'Player not found. Check the number and try again.', 'zh': '找不到該玩家，請檢查編號再試。'},
  'community.findMatch': {'en': 'Find a Match', 'zh': '約戰'},
  'community.myPlayerNumber': {'en': 'My Player Number', 'zh': '我的玩家編號'},
  'community.skillRating': {'en': 'Skill Rating', 'zh': '技術評分'},

  // ── Practice ──
  'practice.title': {'en': 'Practice', 'zh': '練習'},
  'practice.recommended': {'en': 'Recommended for You', 'zh': '為你推薦'},
  'practice.weaknessReview': {'en': 'Review: Wrong Answers', 'zh': '複習：錯題'},
  'practice.reviewComplete': {'en': 'Review Complete!', 'zh': '複習完成！'},

  // ── Paywall ──
  'paywall.title': {'en': 'Ludi Pro', 'zh': 'Ludi Pro'},
  'paywall.unlockEverything': {'en': 'Unlock Everything', 'zh': '解鎖全部功能'},
  'paywall.masterWithoutLimits': {'en': 'Master mahjong without limits', 'zh': '無限制地精通麻將'},
  'paywall.restorePurchases': {'en': 'Restore Purchases', 'zh': '恢復購買'},
  'paywall.autoRenewNote': {'en': 'Subscription auto-renews unless cancelled at least 24 hours before the end of the period. Manage in your store account settings.', 'zh': '訂閱將自動續期，除非在期滿前至少 24 小時取消。請在商店帳號設定中管理。'},

  // ── Delete Account ──
  'delete.title': {'en': 'Delete Account', 'zh': '刪除帳號'},
  'delete.warning1': {'en': 'Are you sure you want to delete your account? This will permanently remove all your progress, achievements, and match history.', 'zh': '確定要刪除帳號嗎？這將永久移除你的所有進度、成就和約戰記錄。'},
  'delete.warning2': {'en': 'This action CANNOT be undone. All your data will be lost forever. Type DELETE to confirm.', 'zh': '此操作無法復原。所有資料將永久遺失。請輸入 DELETE 以確認。'},
  'delete.typeDelete': {'en': 'Type DELETE', 'zh': '輸入 DELETE'},
  'delete.confirm': {'en': 'Delete Forever', 'zh': '永久刪除'},
  'delete.cancel': {'en': 'Keep Account', 'zh': '保留帳號'},
  'delete.success': {'en': 'Your account has been deleted.', 'zh': '你的帳號已刪除。'},
};
