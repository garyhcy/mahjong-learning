# Ludi 開發 Session 紀錄

> 每次接手時更新此檔。記錄「接手當下的狀態快照」，方便其他 AI 或未來的自己快速定位。
> 穩定的帳號 / ID / 設定 / 架構請查 `AGENTS.md`，此檔只記進度與阻塞。

---

## 最新接手狀態（2026-07-14）

### 接手者
短短（Zo persona，model: GLM 5.2）

### 當時代碼狀態
| 項目 | 值 |
|------|-----|
| 本地 main | `9337318`（與遠端同步） |
| gh-pages | `bb701ae` |
| Web Demo | https://garyhcy.github.io/mahjong-learning/ |
| 工作區 | ⚠️ **有 7 個未提交變更 + 1 個未追蹤檔**（見下表） |

### ⚠️ 未提交變更清單（重要！新對話接手第一件事：先看這裡）

以下變更已寫入本機但**尚未 commit**。新對話接手時請先 `git status` 確認，再決定是否一併 commit：

| 檔案 | 變更內容 | 來源 |
|------|---------|------|
| `firestore.rules` | 新增 `match /users/{uid}`（owner 讀寫）+ `match /users`（已登入 list，供排行榜）| 本對話 2026-07-14 |
| `lib/services/firebase_service.dart` | `saveProgress` 移除 `'email': user.email`（email 只留 Auth，不寫 Firestore）| 本對話 2026-07-14 |
| `lib/services/purchases_service.dart` | iOS SDK Key 已填入 `appl_gnyvMLaYQbAlxQFlhKugGjlovMM`，移除 TODO | 上一對話 2026-07-14 |
| `ios/Runner.xcodeproj/project.pbxproj` | 啟用 In-App Purchase / Push / Background Modes capability | 上一對話 2026-07-14 |
| `ios/Runner/Runner.entitlements` | 新增 `aps-environment=development` + `applesignin` | 上一對話 2026-07-14 |
| `ios/Runner/Info.plist` | 新增 `UIBackgroundModes=remote-notification` | 上一對話 2026-07-14 |
| `AGENTS.md` | 第 5、11 節更新（RevenueCat / 待辦）| 上一對話 2026-07-14 |
| `SESSION_LOG.md`（未追蹤） | 本檔，本次新增 | 本對話 2026-07-14 |

> **建議**：上述變更中，`firestore.rules` + `firebase_service.dart` + iOS 設定屬於功能性改動，待 Gary 確認後可一併 commit（遵守「改動未經 Gary 確認不擅自 push」原則）。

---

### 本次對話修正重點（2026-07-14）

**解決的問題**：原 `SESSION_LOG.md` 記載的「已知潛在問題」--firestore.rules 與讀寫路徑不一致。

| 層面 | 修正前 | 修正後 |
|------|--------|--------|
| `firestore.rules` | 只放行 `users/{uid}/app/{docId}` 子集合 | 新增 `users/{uid}` 頂層 doc（owner 讀寫）+ `users` collection list（已登入，排行榜用）|
| `firebase_service.dart` `saveProgress` | 把 `user.email` 寫入 Firestore 頂層 doc | 移除 email 寫入；email 僅存於 Firebase Auth，不落入 Firestore |

**結果**：
- 雲端同步（`saveProgress` / `loadProgress` 讀寫 `users/{uid}`）現可通過 rules。
- 排行榜（`getLeaderboard()` query `users` collection 的 `xp`）現可通過 rules（`list` 放行）。
- 排行榜不再暴露用戶 email，隱私風險消除。
- **rules 仍尚未 deploy 到 Firebase Console**（見阻塞點）。

---

### 我已掌握的資訊
1. 完整閱讀 handover 文檔與 `AGENTS.md`（14 章節）
2. Firebase 專案 `ludi-mahjong-46d78` 已建好，Android/iOS/Web 三平台設定檔皆就位（`firebase_options.dart` 已校正）
3. RevenueCat：Android Key `goog_KEaZIOSRNWEEpcHcKWjGHhSujDX` + iOS Key `appl_gnyvMLaYQbAlxQFlhKugGjlovMM` 皆已填入 `purchases_service.dart`
4. 法律文件（Privacy Policy / Terms of Use）已撰寫並隨 web build 部署
5. Flutter 環境：`/opt/flutter`（stable 3.44.4 / Dart 3.12.2），需 `export PATH="$PATH:/opt/flutter/bin"`
6. 部署鐵律：改完 `lib/` 必須 commit + `flutter build web` + push gh-pages，否則等於沒做

### 上一對話更新（2026-07-14 早段）

- Gary 完成 App Store Connect API Key（Team Key，.p8 + Issuer ID + Key ID）上傳至 RevenueCat App settings
- Gary 取得 RevenueCat iOS Public SDK Key：`appl_gnyvMLaYQbAlxQFlhKugGjlovMM`，已填入 `purchases_service.dart`
- App Store Connect：App 已建（bundle ID `com.ludi.teach`），IAP 商品（`ludi_pro_monthly` HK$48 / `ludi_pro_yearly` HK$298）已建，Paid Apps Agreement 已完成（Gary 確認）
- iOS capabilities 已啟用：In-App Purchase、Sign in with Apple、Push Notifications、Background Modes（remote-notification）

### 目前進度定位

項目處於 **「MVP 上架準備的最後衝刺階段」**--前端與核心整合代碼幾乎全部完成，卡在開發者帳號審批與 Firebase Console 收尾。

| 範疇 | 狀態 |
|------|------|
| 前端 UI（闖關地圖 / 練習 5 模式 / 排行榜 / 約戰 UI / Settings） | ✅ 完成 |
| i18n 系統（1,766 條中英翻譯） | ✅ 完成 |
| Firebase Auth（Email / Google / Apple）+ Firestore 雲端同步 | ✅ 代碼完成 |
| RevenueCat 串接 + Paywall UI | ✅ 代碼完成（雙平台 Key 已補） |
| Firestore Security Rules | ✅ 本機已修正，⚠️ **尚未 deploy 到 Console** |
| 法律文件 | ✅ 已部署 |
| iOS 原生設定（capabilities / entitlements / Info.plist） | ✅ 完成（未 commit） |
| Apple Developer Program | ⏳ 後台處理中 |
| Google Play Console | ⏳ 帳戶驗證審批中 |
| 訂閱商品（App Store Connect） | ✅ 已建 |
| 訂閱商品（Google Play） | ⏳ 待帳號啟用 |
| App Icon / 商店截圖 / 描述文案 | ⏳ 待製作 |
| 提交雙商店審核 | ⏳ 待上述完成 |

### 當前阻塞點

1. **Google Play Console** 帳戶驗證審批中--擋住 Android 訂閱商品與上架。
2. **Apple Developer Program** 後台處理中--iOS 需待啟用才能 TestFlight / 提交。
3. **Firebase Console 收尾**（帳號到位後即可做，不依賴 Apple/Google 審批）：
   - `firestore.rules` **尚未 deploy**（本機已修正，需用 Firebase Console 或 `firebase deploy --only firestore:rules` 部署）
   - Firebase Console Auth 登入方式（Email/Google/Apple）需確認已開啟
   - Apple Sign-In 需在 Firebase Console 配置（Service ID / 授权域名）
   - Android SHA-1 指紋需註冊（Google Sign-In 需要）

### Firebase 代碼層現狀（2026-07-14 核對）

| 項目 | 狀態 |
|------|------|
| pubspec 依賴（firebase_core / firebase_auth / cloud_firestore） | ✅ 已加 |
| `lib/firebase_options.dart`（Android/iOS/Web） | ✅ 已校正 |
| `lib/services/firebase_service.dart`（Email/Google/Apple Auth + Firestore save/load + Leaderboard） | ✅ 完成（email 寫入已移除） |
| `lib/services/cloud_sync_service.dart`（雙向同步 + anonymous） | ✅ 完成 |
| `lib/screens/auth_screen.dart`（登入 UI） | ✅ 完成 |
| `firestore.rules` | ✅ 本機已修正（頂層 + 子集合 + collection list），⚠️ **尚未 deploy** |
| Firebase Console Auth providers 開啟狀態 | ❓ 待確認 |

### RevenueCat 現狀

| 項目 | 狀態 |
|------|------|
| RevenueCat Project + iOS App（bundle `com.ludi.teach`）| ✅ 已建 |
| App Store Connect API Key（.p8）上傳至 RevenueCat | ✅ 已上傳 |
| iOS Public SDK Key `appl_gnyvMLaYQbAlxQFlhKugGjlovMM` | ✅ 已填入代碼 |
| Android Public SDK Key `goog_KEaZIOSRNWEEpcHcKWjGHhSujDX` | ✅ 已填入代碼 |
| RevenueCat Entitlement ID | `pro`（見 `purchases_service.dart`） |
| App Store Connect 訂閱商品（monthly HK$48 / yearly HK$298） | ✅ 已建 |
| Google Play 訂閱商品 | ⏳ 待帳號啟用 |

---

### 帳號到位後的執行順序

依 `AGENTS.md` 第 11 節待辦，優先級：

1. 🔴 **Firebase Console 收尾**（不需等 Apple/Google 審批，可立刻做）：
   - Deploy `firestore.rules` 到 Console
   - 確認 Auth providers（Email/Google/Apple）已開啟
   - 配置 Apple Sign-In（Service ID）
   - 確認 Android SHA-1 已註冊（Google Sign-In 需要）
2. 🔴 **Google Play**：建 App + 訂閱商品（`ludi_pro_monthly` / `ludi_pro_yearly`）+ 上傳 Android Key 到 RevenueCat
3. 🟡 **Apple**：TestFlight 測試版（待 Developer Program 啟用）
4. 🟡 驗證帳號刪除功能（已開發，Apple 強制要求）
5. 🟡 App Icon、商店截圖、描述文案
6. ⚪ 配置 iOS/Android 原生設定並提交審核

### 遺留待確認事項
- 專案根目錄有一無副檔名檔案 `l`（內容為 Dart audioplayers 程式碼，疑為誤命名的遺留檔），待確認是否清理。
- `mahjong_master_new/` 目錄用途未明，待確認。

---

## 溝通與開發約定（繼承自 AGENTS.md）

- 標準繁體中文書面語，精簡直接
- App UI 全英文，勿中文化
- 漸進式交付：配置檔 -> 狀態邏輯 -> UI，每步可編譯
- 改動未經 Gary 確認不擅自 push
- **部署鐵律：改完 `lib/` 必須 commit + `flutter build web` + push gh-pages**

---

## 歷史 Session 紀錄

### 2026-07-02 v3（上一手 AI）
- 語言選擇頁 logo、AuthFlow 改 Stateful、Find a Match 系列修正、MatchRoom 序列化崩潰修復、Delete Account 位置、語言切換中文問題等 15 項修正並部署。
- 詳見 `AGENTS.md` 第 14 節。
