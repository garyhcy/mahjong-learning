# Ludi — 麻將教學 App 開發接手指南 (AGENTS.md)

> 給下一位 AI / 開發者的權威接手文件。所有帳號、ID、設定、進度與已知問題都記於此。
> 與 Gary 溝通：標準繁體中文書面語，輕鬆但正式，精簡直接。App UI 維持全英文，勿中文化。

---

## 1. 項目概述

Ludi = Duolingo 式麻將教學 + 線下約戰社交 App。目標：做出 MVP 上架雙商店，供 Pre-seed / Seed 階段向投資者 Pitching。原則：**速度大於完美**。

- **Framework:** Flutter（Web/Mobile），Dart `^3.10.0`
- **State Management:** Provider（`GameState` + `PracticeState`）
- **UI 風格:** 淺綠色系 `#F5F9F3` / `#4CAF50`，圓角卡片，全英文
- **Repo:** https://github.com/garyhcy/mahjong-learning
- **本地路徑:** `/home/workspace/Ludi/mahjong-learning`

---

## 2. 開發環境（這台 Zo 機器）

- **Flutter SDK:** `/opt/flutter`（stable 3.44.4 / Dart 3.12.2）。每次用 `export PATH="$PATH:/opt/flutter/bin"`。
- **JDK:** `default-jdk-headless` 已裝（含 keytool）。
- **以 root 跑 flutter** 需忽略警告，功能正常。
- **約定：Android 一律在此機器 build。** Debug keystore 已生成在 `~/.android/debug.keystore`（見第 5 節指紋）。

### 常用指令
```bash
export PATH="$PATH:/opt/flutter/bin"
cd /home/workspace/Ludi/mahjong-learning
flutter pub get
flutter analyze
flutter build web --no-tree-shake-icons
flutter build apk --debug        # Android debug build（在本機）
```

---

## 3. Firebase 設定

| 項目 | 值 |
|------|-----|
| Project ID | `ludi-mahjong-46d78` |
| Project Number / Sender ID | `154204299071` |
| Storage Bucket | `ludi-mahjong-46d78.firebasestorage.app` |
| Console | https://console.firebase.google.com/project/ludi-mahjong-46d78 |

### App IDs
| 平台 | Bundle / Package ID | Firebase App ID |
|------|--------------------|-----------------|
| Android | `com.ludi.teach` | `1:154204299071:android:b0e873016cb0b25ccefd8a` |
| iOS | `com.ludi.teach` | `1:154204299071:ios:545ff9fe210a302dcefd8a` |

> ⚠️ 注意：iOS 的 `GoogleService-Info.plist` 內 `BUNDLE_ID` 曾出現大寫 `com.Ludi.teach`，最新版已統一為小寫 `com.ludi.teach`。Xcode pbxproj 的 `PRODUCT_BUNDLE_IDENTIFIER` 已從預設 `com.marvis.mahjongApp` 改為 `com.ludi.teach`（RunnerTests target 仍保留舊 id，不影響上架）。

### API Keys（公開金鑰，可入庫）
| 平台 | API Key |
|------|---------|
| Android | `AIzaSyCyJzXaKaBmldAzi4weOkJVK1y5FDhU-1M` |
| iOS | `AIzaSyBlJ1QxWOdEOoCNx9EYC36teF9WYbavXFk` |
| Web | `AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw` |

### Google Sign-In (iOS)
- CLIENT_ID: `154204299071-i0uo9nuo2teupm4vgasr8h6nojocssq0.apps.googleusercontent.com`
- REVERSED_CLIENT_ID: `com.googleusercontent.apps.154204299071-i0uo9nuo2teupm4vgasr8h6nojocssq0`
- 已加入 `ios/Runner/Info.plist` 的 `CFBundleURLTypes`。

### 設定檔位置
- `android/app/google-services.json`（已含 oauth_client，Google 登入就緒）
- `ios/Runner/GoogleService-Info.plist`（已掛入 Xcode pbxproj 的 file ref + Resources build phase）
- `lib/firebase_options.dart`（Android/iOS/Web 各平台值已校正）

---

## 4. Android 簽名指紋 (SHA-1)

**此機器的 debug keystore**（`~/.android/debug.keystore`，storepass/keypass=`android`，alias=`androiddebugkey`）：

| 類型 | 值 |
|------|-----|
| SHA-1 | `0F:DE:FE:3B:0B:7D:9A:83:18:5D:6D:B0:70:6C:EC:BE:A5:75:06:29` |
| SHA-256 | `BE:13:50:40:2D:42:78:1A:E0:3A:89:9A:39:51:04:F4:B9:9D:B8:52:D0:96:0F:43:AE:88:A6:B3:02:D3:3B:95` |

- 此 SHA-1 已登記在 Firebase（google-services.json 內 `certificate_hash: 0fdefe3b0b7d9a83185d6db0706cecbea5750629`）。
- ⚠️ 此指紋**只對在這台機器 build 的 APK 有效**。換機 build 需重新登記。
- 正式上架另需 release keystore + Google Play App Signing 的 SHA-1。

取得指令：
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep -A1 SHA1
```

---

## 5. RevenueCat（訂閱金流）

| 項目 | 值 |
|------|-----|
| Android Public SDK Key | `goog_KEaZIOSRNWEEpcHcKWjGHhSujDX`（已填入 `lib/services/purchases_service.dart`） |
| iOS Public SDK Key | **待補** — Apple 帳號處理中 |
| Entitlement ID（代碼判斷 Pro） | `pro` |
| Offering / Packages | 在 RevenueCat 後台建月費 / 年費 package |

- 定價策略：HK$48/月、HK$298/年，7 天免費試用。
- 串接層：`lib/services/purchases_service.dart`（init/login/logout/getOffering/purchase/restore/isPro/syncToGameState）。
- Paywall UI：`lib/screens/paywall_screen.dart`（含價格、auto-renew 說明、Restore、Terms/Privacy 連結）。
- 設定順序：先在 Google Play / App Store Connect 建訂閱商品 → RevenueCat 匯入 → 歸入 entitlement `pro` → 放入 Offering。

---

## 6. 開發者帳號狀態

| 項目 | 連結 | 狀態 |
|------|------|------|
| Apple Developer Program | https://developer.apple.com | 後台處理中（待啟用 App Store Connect / 簽 Paid Apps Agreement） |
| Google Play Console | https://play.google.com/console | 帳戶驗證審批中（驗證後才能建 App + 訂閱商品） |

---

## 7. 法律文件（已撰寫，隨 web build 部署）

| 文件 | 原始檔 | 上線網址 |
|------|--------|---------|
| Privacy Policy | `web/legal/privacy.html` | https://garyhcy.github.io/mahjong-learning/legal/privacy.html |
| Terms of Use | `web/legal/terms.html` | https://garyhcy.github.io/mahjong-learning/legal/terms.html |

連結已寫入 `lib/screens/paywall_screen.dart` 常數。

---

## 8. 文件結構（關鍵檔案）

```
lib/
├── main.dart                       # 入口 + Firebase/RevenueCat 初始化 + AuthGate + MainShell（4 tabs）
├── firebase_options.dart           # 各平台 Firebase 設定（已校正）
├── models/                         # mahjong_data, practice_data, mahjong_tiles
├── providers/
│   ├── game_state.dart             # 核心狀態（XP/hearts/streak/lessons/nickname/isPremium/cloud sync）
│   └── practice_state.dart         # 練習狀態（弱點追蹤/每日次數/isPremiumFlag）
├── services/
│   ├── firebase_service.dart       # Auth（Email/Google/Apple）+ Firestore + leaderboard
│   ├── cloud_sync_service.dart     # 匿名用戶 Firestore 同步（含 nickname/avatar）
│   ├── progress_storage.dart       # SharedPreferences 本地存儲
│   └── purchases_service.dart      # RevenueCat 封裝
└── screens/
    ├── auth_screen.dart            # 登入/註冊（Email + Google + Apple 按鈕）
    ├── home_screen.dart            # Learn 闖關地圖
    ├── community_screen.dart       # 排行榜/成就/約戰/聯賽（Feed 為假數據）
    ├── practice_screen.dart        # 練習主頁（已修 premium 即時同步）
    ├── practice/                   # 5 種練習模式
    ├── more_screen.dart            # Settings（Master Mode 後門已用 kDebugMode 封鎖）
    ├── paywall_screen.dart         # Pro 訂閱頁
    └── profile_screen.dart         # 個人檔案 / 改名
```

---

## 9. Pro 會員特權（盈利模式）

| 功能 | 免費 | Pro |
|------|------|-----|
| 每日生命 (Hearts) | **3 顆**（已定案，maxHearts=3） | 無限 |
| 每日練習次數 | 3 次 | 無限 |
| 約戰次數 | 每週 1 次 | 無限 |
| 排行榜詳細數據 | 基本 | 完整 |
| 專屬吉祥物/頭像框 | 無 | 有 |
| 牌局回顧記錄 | 最近 3 局 | 完整 |

> 注意：交接文件舊版寫「免費 5 顆血」，Gary 已定案 **統一為 3 顆**。

---

## 10. 已完成的修正（本次接手）

1. Firebase 各平台設定校正（`firebase_options.dart` 原本 android/ios 誤用 web 值）。
2. Android `applicationId` 從 `com.marvis.mahjong_app` 改為 `com.ludi.teach`，掛載 google-services plugin。
3. iOS Bundle ID 統一 `com.ludi.teach`，加入 Google Sign-In URL Scheme。
4. RevenueCat 整合（service + Paywall + main.dart 初始化）。
5. 練習特權即時同步修正（`PracticeState.updatePremium` 原本從不被呼叫）。
6. 雲端同步補上 nickname / avatar（原本會遺失）。
7. Auth UI 加入 Google + Apple 登入按鈕（Apple 限 iOS 顯示）。
8. `retryQuiz` 修正：免費用戶不再無條件回滿血。
9. Master Mode 後門用 `kDebugMode` 封鎖（release 版失效）。
10. App 顯示名稱統一「Ludi」（iOS CFBundleDisplayName + Android android:label）。
11. iOS `Runner.entitlements`（Sign in with Apple capability）+ GoogleService-Info.plist 掛入 Xcode project。
12. Privacy Policy + Terms of Use（`web/legal/`）。

---

## 11. 待辦 / 已知阻塞

| 優先 | 項目 | 阻塞原因 |
|------|------|---------|
| 🔴 | RevenueCat iOS SDK Key + 訂閱商品 | Apple 帳號處理中 |
| 🔴 | App Store Connect 建 In-App Purchase + 簽 Paid Apps Agreement | Apple 帳號處理中 |
| 🔴 | Google Play 建 App + 訂閱商品（`ludi_pro_monthly` HK$48 / `ludi_pro_yearly` HK$298） | Play 帳戶驗證審批中 |
| 🟡 | Apple Developer 後台開啟「Sign in with Apple」capability（帳號啟用後） | Apple 帳號處理中 |
| 🟡 | 在 App 內加入帳號刪除功能（Apple 強制要求） | 待開發 |
| 🟡 | App Icon、商店截圖、描述文案 | 待製作 |
| ⚪ | Community Feed 改為真實數據 | 後端待開發 |
| ⚪ | Find a Match 約戰配對引擎（Cloud Functions + 場地 DB） | 後端待開發 |

---

## 12. 與 Gary 的偏好

- 標準繁體中文書面語，避免廣東話口語化與粵語助詞。
- 精簡直接，少客套，少重複確認。
- App UI 全英文，勿中文化。
- 漸進式交付：先配置檔 → 再狀態邏輯 → 最後 UI，確保每步可編譯。
- 改動先在 local / main 完成並驗證編譯，未經確認不擅自 push（目前慣例：等 Gary 確認）。
- **🚨 部署鐵律：改了 lib/ 代碼但沒 commit + `flutter build web` + 推 gh-pages，等於沒做。Gary 看的是 https://garyhcy.github.io/mahjong-learning/ 的 Web Demo，不是本地源碼。每次改完 UI/邏輯都要重新部署 gh-pages，否則 Gary 會認為「沒改、欺騙、浪費 Token」。**

---

## 13. 部署流程（gh-pages Web Demo）

```bash
export PATH="$PATH:/opt/flutter/bin"
cd /home/workspace/Ludi/mahjong-learning
flutter build web --no-tree-shake-icons          # ~40s
# 部署（保留 gh-pages 歷史）：
TMP=$(mktemp -d) && cd "$TMP" \
  && git clone --branch gh-pages --depth 1 https://github.com/garyhcy/mahjong-learning.git . \
  && find . -maxdepth 1 ! -name .git ! -name . -exec rm -rf {} + \
  && cp -r /home/workspace/Ludi/mahjong-learning/build/web/. . \
  && git add -A && git commit -m "deploy: <version>" && git push origin gh-pages \
  && cd / && rm -rf "$TMP"
```
- `gh auth setup-git` 已執行，git push https 自動帶 token。
- GitHub Pages 上線通常 1-2 分鐘；可用 `agent-browser open https://garyhcy.github.io/mahjong-learning/` 驗證。

---

## 14. 本次修正紀錄（2026-07-02 v3）

| # | 項目 | 修正 |
|---|------|------|
| 1 | 語言選擇頁 logo | 改用 `assets/images/topbar_logo.png`（原 chat 上傳的 `_TopBar_256px`） |
| 2 | 按完語言沒轉登入頁 | `_AuthFlow` 改 StatefulWidget；Firebase 不可用時顯示 AuthScreen（demo/guest mode，`Continue as Guest` 按鈕），存 `local_demo_authed` |
| 3-13 | Find a Match / Skill Rating / playerId / auto-matchmaking / chat 輸入欄 / propose slot 月曆(30min) / 自選場地警告 / Match Rooms 列表 | 代碼上個 session 已改，但**從未 commit / build / 部署**，本次一併部署 |
| 12 根因 | 完成預訂後找不到 Chat Room | (a) `MatchRoomData.toJson()` 存 ISO 字串但 `loadRooms()` 用 `as num?` 解析→崩→room 被清空，改為 DateTime.parse 兼容；(b) confirm 時 `updateRoom` 把 deleteAt 改為預約當天 +24h（原本是建立+24h） |
| 14 | Delete Account 位置 | 從 Account section 移到頁面最底（Account Management section，Log Out 之後） |
| 15 | 改語言不能選中文 | more_screen `_langOption` callback 原本沒存 SharedPreferences，補上 `app_display_lang`；約戰語言子選項補 English |
