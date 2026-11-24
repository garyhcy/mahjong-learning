# Ludi — 專案營運筆記（PROJECT_NOTES）

> 本檔由 repo 根目錄舊 `AGENTS.md`（300 行）與 `SESSION_LOG.md`（163 行）於 2026-11-24 合併精簡而來，只保留仍然有效的營運事實。
> 舊檔已刪除，完整內容仍可從 git 歷史取回：`git log --all -- AGENTS.md SESSION_LOG.md`。

與 Gary 溝通：繁體中文書面語（香港），精簡直接；App UI 維持全英文，勿中文化。

---

## 1. 專案定位

Ludi = Duolingo 式麻將教學 + 線下約戰社交 App。目標：MVP 上架雙商店，供 Pre-seed / Seed 階段向投資者 Pitching。

- Framework：Flutter（Web / Mobile）
- 狀態管理：Provider（`GameState` + `PracticeState`）
- UI 風格：淺綠色系 `#F5F9F3` / `#4CAF50`，圓角卡片，全英文
- Repo：https://github.com/garyhcy/mahjong-learning
- Web Demo：https://garyhcy.github.io/mahjong-learning/ （由 `gh-pages` 分支提供，亦係 repo 預設分支）

---

## 2. Firebase

| 項目 | 值 |
| --- | --- |
| Project ID | `ludi-mahjong-46d78` |
| Project Number / Sender ID | `154204299071` |
| Storage Bucket | `ludi-mahjong-46d78.firebasestorage.app` |
| Console | https://console.firebase.google.com/project/ludi-mahjong-46d78 |

| 平台 | Bundle / Package ID | Firebase App ID |
| --- | --- | --- |
| Android | `com.ludi.teach` | `1:154204299071:android:b0e873016cb0b25ccefd8a` |
| iOS | `com.ludi.teach` | `1:154204299071:ios:545ff9fe210a302dcefd8a` |

| 平台 | API Key（公開金鑰，可入庫） |
| --- | --- |
| Android | `AIzaSyCyJzXaKaBmldAzi4weOkJVK1y5FDhU-1M` |
| iOS | `AIzaSyBlJ1QxWOdEOoCNx9EYC36teF9WYbavXFk` |
| Web | `AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw` |

- Auth providers：Email、Google、Apple（Apple 已於 2026-07-15 配置完成，iOS 加 Google Sign-In URL Scheme）。
- iOS `GoogleService-Info.plist` 曾出現大寫 `com.Ludi.teach`，最新版已統一為小寫。
- 帳號刪除功能已實作（Firestore 文件 + Auth user 一併刪除，Apple 上架強制要求）。

---

## 3. RevenueCat（訂閱金流）

| 項目 | 值 |
| --- | --- |
| Android Public SDK Key | `goog_KEaZIOSRNWEEpcHcKWjGHhSujDX` |
| iOS Public SDK Key | `appl_gnyvMLaYQbAlxQFlhKugGjlovMM` |
| Entitlement ID | `pro` |
| Offering | `default`（current） |
| 商品 ID | `ludi_pro_monthly`（HK$48/月）、`ludi_pro_yearly`（HK$368/年），各含 7 天免費試用 |
| App Store Connect API Key | Issuer `f4678083-a7b1-47e7-bc0a-0c2519bd805e` / Key ID `89HMF95AW9`（.p8 由 Gary 本地保存，供 Codemagic 簽名與上傳） |

- 串接層：`lib/services/purchases_service.dart`（init / login / logout / getOffering / purchase / restore / isPro / syncToGameState）。
- Paywall：`lib/screens/paywall_screen.dart`（價格、auto-renew 說明、Restore、Terms / Privacy 連結）。
- 設定順序：商店建訂閱商品 → RevenueCat 匯入 → 歸入 entitlement `pro` → 放入 Offering。

---

## 4. 開發者帳號與簽名

| 項目 | 狀態 |
| --- | --- |
| Apple Developer Program | 已啟用（2026-07-16 確認） |
| Google Play Console | 帳戶驗證完成，內部測試已上傳 AAB（2026-07-16） |
| Apple TestFlight | 2026-07-20 22:50 已 build 成功、上傳並可安裝測試 |

Codemagic 簽名設定（2026-07-20 已多次確認，毋須再重複驗證）：

| 項目 | 值 |
| --- | --- |
| Profile reference name | `Ludi Distribution` |
| Profile UUID | `bdf586ef-f1a7-4e2b-8a34-700d15036abc`（仍有效） |
| Profile 類型 | App Store distribution |
| Profile capabilities | Push Notifications + Sign in with Apple |
| Certificate 名稱 | `Ludi_codemagic`（Codemagic 持有 private key） |
| Build 位置 | App Store Connect → TestFlight → Builds |

Android debug keystore：`~/.android/debug.keystore`（alias `androiddebugkey`，storepass `android`）。

---

## 5. 法律文件（隨 web build 部署）

| 文件 | 上線網址 |
| --- | --- |
| Privacy Policy | https://garyhcy.github.io/mahjong-learning/legal/privacy.html |
| Terms of Use | https://garyhcy.github.io/mahjong-learning/legal/terms.html |
| Account Deletion | https://garyhcy.github.io/mahjong-learning/legal/account-deletion.html |

原始檔在 `web/legal/`，連結常數寫入 `lib/screens/paywall_screen.dart`。

---

## 6. 關鍵檔案結構

```text
lib/
├── main.dart                       # 入口 + Firebase/RevenueCat 初始化 + AuthGate + MainShell（4 tabs）
├── firebase_options.dart           # 各平台 Firebase 設定（已校正）
├── models/                         # mahjong_data, practice_data, mahjong_tiles
├── providers/
│   ├── game_state.dart             # 核心狀態（XP/hearts/streak/lessons/nickname/isPremium/cloud sync/stage 解鎖）
│   └── practice_state.dart         # 練習狀態（弱點追蹤/每日次數/isPremiumFlag）
├── services/
│   ├── firebase_service.dart       # Auth（Email/Google/Apple）+ Firestore + leaderboard
│   ├── cloud_sync_service.dart     # 匿名用戶 Firestore 同步（含 nickname/avatar/lessonBestAccuracy）
│   ├── progress_storage.dart       # SharedPreferences 本地存儲
│   └── purchases_service.dart      # RevenueCat 封裝
└── screens/
    ├── auth_screen.dart            # 登入/註冊（Email + Google + Apple；必須登入，無 guest mode）
    ├── learn_screen.dart           # Learn 闖關地圖（Stage 卡 + 課卡 + 題型 widget）
    ├── home_screen.dart            # 首頁
    ├── community_screen.dart       # 排行榜／成就／約戰／聯賽（Feed 暫為假數據）
    ├── practice_screen.dart        # 練習主頁
    ├── practice/                   # 5 種練習模式
    ├── more_screen.dart            # Settings（Master Mode 後門已用 kDebugMode 封鎖）
    ├── paywall_screen.dart         # Pro 訂閱頁
    └── profile_screen.dart         # 個人檔案／改名
```

---

## 7. 進度與解鎖規則（Duolingo 式，2026-11-24 定案）

- 每課本身無正確率門檻；完成即解鎖下一課。
- **Stage 解鎖條件＝完成上一個 Stage 的全部課**（不再用「正確率 ≥70%」做門檻）。
- 正確率仍然記錄（`_lessonBestAccuracy`，每課取最佳，按題數加權成 Stage 正確率）並同步到 Firestore 欄位 `lessonBestAccuracy`，但只作顯示／課後結果用途，不參與解鎖判斷。
- Stage 卡顯示完成課數 `x/y`；鎖住的 Stage 顯示上一 Stage 的完成進度。

---

## 8. Pro 會員特權

| 功能 | 免費 | Pro |
| --- | --- | --- |
| 每日生命 (Hearts) | 3 顆（已定案 `maxHearts=3`） | 無限 |
| 每日練習次數 | 3 次 | 無限 |
| 約戰次數 | 每週 1 次 | 無限 |
| 排行榜詳細數據 | 基本 | 完整 |
| 專屬吉祥物／頭像框 | 無 | 有 |
| 牌局回顧記錄 | 最近 3 局 | 完整 |

---

## 9. 建置與部署

```bash
flutter pub get
flutter analyze                                                        # 基線：0 error（info/warning 已知）
flutter test                                                           # 含 test/stage_accuracy_test.dart
flutter build web --no-tree-shake-icons --base-href /mahjong-learning/  # base-href 必填，否則白屏
flutter build apk --debug
```

**部署鐵律**：改了 `lib/` 而沒有 commit + `flutter build web` + 推 `gh-pages`，等於沒做。Gary 看的是 Web Demo，不是本地源碼。

```bash
# 部署到 gh-pages（保留歷史）
TMP=$(mktemp -d) && git clone --branch gh-pages --depth 1 https://github.com/garyhcy/mahjong-learning.git "$TMP" \
  && find "$TMP" -maxdepth 1 ! -name .git ! -name "$TMP" -exec rm -rf {} + \
  && cp -r build/web/. "$TMP"/ \
  && (cd "$TMP" && git add -A && git commit -m "deploy: <version>" && git push origin gh-pages) \
  && rm -rf "$TMP"
```

GitHub Pages 上線通常 1–2 分鐘。

---

## 10. 已知待辦／阻塞

| 優先 | 項目 | 狀態 |
| --- | --- | --- |
| 🟡 | 商店截圖、描述文案 | 待製作 |
| ⚪ | Community Feed 改真實數據 | 後端待開發 |
| ⚪ | Find a Match 約戰配對引擎（Cloud Functions + 場地 DB） | 後端待開發 |
| ⚪ | 四人對局引擎 | 未實作 |

---

## 11. 開發約定

- 標準繁體中文書面語，避免粵語口語與助詞；精簡直接，少客套。
- App UI 全英文，勿中文化。
- 漸進式交付：先配置檔 → 再狀態邏輯 → 最後 UI，確保每步可編譯。
- 未經 Gary 確認不擅自 push（部署 gh-pages 例外：改完 UI/邏輯即需部署，見第 9 節）。
- 必須登入才可使用 App（無 guest／demo mode，Gary 已定案）。


## Gary 規則補充裁決（2026-11-24）

兩條口頭裁決，覆蓋 `GARY_RULES_REFERENCE.md` 未講清或寫法有歧義的地方。課程內容已按此更新。

1. **一台花＝2 番，不累加門風花。** 持有全部四季牌或全部花牌，整組算 2 番；不再另外加 1 番門風花／正花。單張正花仍然每張 1 番（未成台花時）。
2. **暗槓不破門前清。** 「門前清」只排除食、碰、明槓；自己暗槓仍然保持門前清。

未經 Gary 批准前不改 `GARY_RULES_REFERENCE.md` 原文（規則檔改動需批）。
