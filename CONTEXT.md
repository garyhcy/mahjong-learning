# Ludi - Domain Glossary (CONTEXT.md)

> 麻將教學 + 線下約戰社交 App 的領域詞彙。只記錄詞彙含義，不涉及實作細節。
> 架構決策見 `docs/adr/`，開發進度見 `CHANGELOG3.md`。

## 學習核心 (Learning)

| 詞彙 | 含義 |
| --- | --- |
| **Lesson** | 課程單元，含對話 (Dialogue) 與測驗 (Quiz)。完成獲 XP。 |
| **Stage** | 關卡階段，含多個 Lesson，依序解鎖。 |
| **XP** | 經驗值，完成 Lesson / Practice 累積，決定 League 歸屬。 |
| **Hearts** | 生命值，答錯扣 1。免費用戶上限 3 顆，Pro 無限。每日重置。 |
| **Streak** | 連續完成 Lesson 的天數。斷裂歸零。 |
| **DailyTask** | 每日任務，完成可領獎勵。每日重置。 |
| **WrongAnswer** | 錯題記錄，可進入複習模式重答。 |
| **MasterMode** | 大師模式，高難度學習。release 版以 `kDebugMode` 封鎖後門。 |

## 社群 (Community)

| 詞彙 | 含義 |
| --- | --- |
| **League / LeagueTier** | 聯賽階級，依 XP 劃分：Bronze / Silver / Gold / Emerald / Diamond。 |
| **LeaderboardEntry** | 排行榜項目，含 rank / name / avatar / xp / streak / playerId / skillRating。 |
| **AchievementDisplay** | 成就展示項，含 emoji / title / subtitle，依條件動態解鎖（共 24 個）。 |
| **AvatarOption** | 頭像選項，綁定 MascotExpression 與框色。 |
| **SkillRating** | 技能評分，反映玩家實力，影響配對。 |
| **PlayerId** | 玩家唯一識別碼，格式 `LD####`（純數字）。 |
| **Region** | 地區，共 38 個（含 EU/US 重點）。排行榜與假玩家依 Region 分組。 |

## 約戰 (Find a Match)

| 詞彙 | 含義 |
| --- | --- |
| **Match / MatchRoom** | 約戰 / 約戰房間。含預約時段、場地、雙方玩家、聊天室。 |
| **Friend / FriendRequest** | 好友 / 好友請求。可發送、接受、拒絕。 |

## 狀態 (State)

| 詞彙 | 含義 |
| --- | --- |
| **GameState** | 核心狀態 (Provider)，涵蓋 XP / Hearts / Streak / Lessons / Nickname / Avatar / Cloud Sync。 |
| **PracticeState** | 練習狀態 (Provider)，涵蓋弱點追蹤 / 每日次數 / isPremiumFlag。 |
| **MascotExpression** | 吉祥物（熊貓）表情：happy / excited / wink 等。 |

## 會員 (Membership)

| 詞彙 | 含義 |
| --- | --- |
| **Pro** | 付費會員資格（RevenueCat entitlement `pro`）。享有無限 Hearts / 練習 / 約戰等特權。 |
