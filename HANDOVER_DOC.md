# Ludi - Mahjong Learning & Social App
## Project Handover Document

### 1. 項目概述 (Project Overview)
Ludi 是一個結合了「Duolingo 式麻將教學」與「線下約戰社交」的應用程式。
目標用戶為麻將初學者，解決他們「學習門檻高」以及「害怕出外約戰被嫌棄/場地不透明」的痛點。

**核心價值主張：**
- **教學：** 闖關式學習，將複雜規則拆解為小單元。
- **社交與約戰：** 根據學習進度推算技術水平，配對程度相近的對手，並推薦有駐場職員、收費透明的合作麻將館。

**當前階段目標：**
準備 MVP（Minimum Viable Product）版本，以個人開發者名義上架 App Store 及 Google Play，主要用於向投資者進行 Pre-seed / Seed 階段的 Pitching 獲取 Funding。

---

### 2. 已完成工作 (Completed Work)
目前已完成前端 UI 框架與核心互動邏輯，並部署於 GitHub Pages (https://garyhcy.github.io/mahjong-learning/) 作為 Web Demo。

**前端架構：**
- **Framework:** Flutter (Web/Mobile 跨平台)
- **State Management:** Provider (`GameState` 及 `PracticeState`)
- **UI 風格:** 淺綠色系 (`#F5F9F3`)，圓角卡片設計，全英文介面。

**已實現模塊：**
1. **Home (Learn):** 闖關式地圖、單元進度、生命值 (Hearts) 與經驗值 (XP) 系統。
2. **Community:** 
   - 社交動態 Feed（目前為假數據）。
   - 聯賽排行榜 (Bronze 到 Diamond，根據 XP 動態計算)。
   - 「Find a Match」線下約戰入口（目前為 UI 展示）。
   - 成就系統 (Achievements)。
3. **Practice:**
   - 5 種可玩練習模式：Tile Recognition, Tile Matching, Sequence Sorting, Rules Quiz, Speed Challenge。
   - 弱點追蹤系統與每日次數限制（免費用戶 3 次）。
   - 已整合真實麻將牌面圖片 (位於 `assets/tiles/`)。
4. **Settings (More):**
   - 帳號管理 (Player Name 修改)。
   - 偏好設定 (通知、音效、震動)。
   - 學習設定 (重置進度)。
   - 吉祥物頭像選擇系統。

---

### 3. 下一步：正式上線準備 (Next Steps for Launch)

為了將當前的 Demo 轉化為可上架的 MVP，下一位 AI Agent 需要協助用戶完成四大範疇的工作。以下表格總結了上線準備的核心任務與技術選型：

| 範疇 | 技術選型與策略 | 具體執行任務 |
|------|--------------|--------------|
| 玩家帳號與數據庫 | Firebase Authentication & Cloud Firestore | 整合 Apple Sign-In（App Store 強制要求）、Google 及 Email 登入。設計 Firestore 數據結構以存放用戶的 XP、生命值、聯賽級別及弱點數據，並實現本地狀態與雲端的雙向同步。 |
| 訂閱金流系統 | RevenueCat | 建議定價為 $48 HKD/月或 $298 HKD/年，並附帶 7 天免費試用。需在 Flutter 中配置 `purchases_flutter`，串接 Paywall UI，並根據訂閱狀態解鎖 Pro 專屬功能（如無限練習次數）。 |
| 安全與合規 | GitHub Pages / Notion 託管文件 | 撰寫並發佈隱私政策 (Privacy Policy) 及服務條款 (Terms of Service)。同時需確保 Firestore 設置了嚴格的 Security Rules 以保護用戶數據。 |
| 應用商店上架 | Apple Developer Program & Google Play Console | 指導用戶以個人名義註冊開發者帳號。生成 App Icon 及 Store Screenshots，撰寫應用描述文案，並配置 iOS 的 `Info.plist` 及 Android 的 `AndroidManifest.xml`。 |

---

### 4. 給下一位 AI 的執行建議 (Guidelines for the Next AI)

在協助用戶推進項目時，必須把握「速度大於完美」的原則。由於用戶的短期目標是製作一個用於獲取 Funding 的 Demo，請優先完成 Firebase Auth 與 Firestore 的核心串接，確保應用具備基本的帳號系統與雲端存檔能力，隨後應盡快準備 TestFlight 測試版供展示之用。

在溝通與開發細節上，必須嚴格遵守用戶的偏好。與用戶 (Gary) 溝通時，應保持輕鬆的語氣，但**必須全程使用書面語**，絕不可使用口語化表達。此外，App 介面目前維持全英文設計，這是既定的開發策略，請勿隨意將 UI 代碼中文化。

最後，在進行複雜的系統整合（如 Firebase 或 RevenueCat）時，應採取漸進式交付的策略。建議先完成配置文件，再逐步修改狀態管理邏輯（如 `GameState`），最後才處理 UI 登入畫面。這種分步執行的模式能確保每一步都能成功編譯，降低除錯成本。

---

### 5. 項目文件結構 (Project Structure)

```
mahjong-learning/
├── lib/
│   ├── main.dart                          # 入口 + 底部導覽欄 (4 tabs: Home, Community, Practice, More)
│   ├── models/
│   │   ├── mahjong_tiles.dart             # 麻將牌面數據定義
│   │   └── practice_data.dart             # 練習記錄數據模型
│   ├── providers/
│   │   ├── game_state.dart                # 核心狀態管理 (XP, hearts, streak, lessons, nickname)
│   │   └── practice_state.dart            # 練習狀態管理 (弱點追蹤, 每日次數, 歷史記錄)
│   ├── screens/
│   │   ├── home_screen.dart               # 首頁 (Learn 地圖)
│   │   ├── community_screen.dart          # 社區 (排行榜 + 成就 + 約戰 + 聯賽詳情等子頁面)
│   │   ├── practice_screen.dart           # 練習主頁面
│   │   ├── practice/
│   │   │   ├── tile_recognition_screen.dart
│   │   │   ├── tile_matching_screen.dart
│   │   │   ├── sequence_sorting_screen.dart
│   │   │   ├── rules_quiz_screen.dart
│   │   │   └── speed_challenge_screen.dart
│   │   ├── more_screen.dart               # Settings 頁面
│   │   ├── learn_screen.dart              # 學習單元內容頁
│   │   └── achievements_screen.dart       # 成就頁面 (已合併到 community)
│   ├── services/
│   │   └── progress_storage.dart          # SharedPreferences 本地存儲
│   └── widgets/
│       └── mascot_widget.dart             # 吉祥物組件 (6 種表情: happy, wink, excited, thinking, sad, content)
├── assets/
│   ├── tiles/                             # 真實麻將牌面 PNG (42 張)
│   │   ├── m1.png ~ m9.png               # 萬子
│   │   ├── p1.png ~ p9.png               # 筒子
│   │   ├── s1.png ~ s9.png               # 條子
│   │   ├── east.png, south.png, west.png, north.png  # 風牌
│   │   ├── red.png, green.png, white.png  # 三元牌
│   │   └── f_*.png                        # 花牌
│   └── images/                            # 其他圖片資源
├── build/web/                             # Flutter Web 構建產物 (gh-pages 分支)
└── pubspec.yaml                           # 依賴配置
```

---

### 6. 盈利模式與 Pro 會員特權 (Monetization & Pro Features)

Ludi 的盈利模式以 Pro 訂閱為核心，輔以線下場地合作分成。以下是 Pro 會員的完整特權設計：

| 功能 | 免費用戶 | Pro 會員 |
|------|---------|---------|
| 每日生命 (Hearts) | 5 顆 | 無限 |
| 每日練習次數 | 3 次 | 無限 |
| 約戰次數 | 每週 1 次 | 無限 |
| 約戰配對優先度 | 普通 | 優先匹配 |
| 排行榜詳細數據 | 基本 | 完整統計（勝率、番數分布等） |
| 專屬吉祥物/頭像框 | 無 | 有（已在 Settings 頁面預留 Pro 鎖定 UI） |
| 牌局回顧記錄 | 最近 3 局 | 完整歷史 |

其他潛在盈利來源包括：線下合作場地推廣費（置頂推薦）、定期新手友誼賽報名費、虛擬商品（頭像框/牌桌主題）以及企業團建套餐。

---

### 7. 約戰功能設計概要 (Find a Match - Design Spec)

約戰功能是 Ludi 的核心差異化賣點，目前僅完成 UI 展示（標記為 Coming Soon）。以下是未來實現時的設計方向：

**配對邏輯：** 系統根據用戶的學習進度（已完成的關卡數量和 XP）推算技術水平，並結合用戶設定的常用語言（廣東話/普通話/英文）進行配對。配對結果會推薦合作場地，這些場地具備透明收費和駐場職員可即時查詢的特點。

**後端需求（未來開發）：** 需要一個配對引擎（可用 Firebase Cloud Functions 實現），以及合作場地的數據庫（場地資訊、價格、可用時段等）。

---

### 8. 用戶需要完成的註冊事項 (User Action Items)

| 項目 | 連結 | 費用 |
|------|------|------|
| Apple Developer Program | https://developer.apple.com/programs/enroll/ | $99 USD/年 |
| Google Play Console | https://play.google.com/console/signup | $25 USD 一次性 |
| Firebase Console | https://console.firebase.google.com/ | 免費 |
| RevenueCat | https://www.revenuecat.com/ | 免費至 $2.5k MRR |

---

### 9. GitHub 倉庫資訊 (Repository Info)

| 項目 | 值 |
|------|---|
| Repository | https://github.com/garyhcy/mahjong-learning |
| Main Branch | `main`（源碼） |
| Deploy Branch | `gh-pages`（構建產物） |
| Live Demo | https://garyhcy.github.io/mahjong-learning/ |
| Flutter Version | 需確認（建議使用 stable channel 最新版） |

---

### 10. 建議的執行順序 (Recommended Execution Order)

以下是建議下一位 AI 按順序執行的任務清單，按優先級排列：

| 步驟 | 任務 | 預計時間 |
|------|------|---------|
| 1 | 確認用戶已完成 Firebase Console 及開發者帳號註冊 | 用戶自行完成 |
| 2 | 在 Flutter 項目中配置 Firebase（`firebase_core`, `firebase_auth`, `cloud_firestore`） | 1-2 小時 |
| 3 | 實現登入/註冊 UI（Apple + Google + Email） | 2-3 小時 |
| 4 | 將 `GameState` 和 `PracticeState` 的數據同步至 Firestore | 3-4 小時 |
| 5 | 撰寫 Privacy Policy 及 Terms of Service | 1 小時 |
| 6 | 配置 RevenueCat 及 Paywall UI | 2-3 小時 |
| 7 | 生成 App Icon、Store Screenshots、描述文案 | 1-2 小時 |
| 8 | 配置 iOS/Android 原生設定並提交審核 | 2-3 小時 |
