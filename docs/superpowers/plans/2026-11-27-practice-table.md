# 單機實戰練習局 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 讓玩家用香港麻雀規則，對三個基本 AI 打一局真正可玩的牌（摸、打、碰、上、槓、食糊、計番、結算）。

**Architecture:** 純 Dart 引擎（牌牆／手牌／面子／勝負／番數）與 Flutter 畫面分離；`TableController` 只負責 AI 節奏、音效、把引擎狀態推給 UI。先做單局、東圈、玩家坐東，不做多人連線、包牌、搶槓、多響。

**Tech Stack:** Flutter 3.50 / Dart 3.14、`ChangeNotifier`、現有 `MahjongTile` 牌面元件、`AudioService`、`SharedPreferences` 不涉及新依賴。

**Spec:** 本文件；規則依據 `docs/GARY_RULES_REFERENCE.md`。

## Global Constraints

- 144 張牌（含 8 花）；東圈、玩家坐東；一局定勝負，不連莊。
- 3 番起糊、10 番上限；出銃者全付；自摸其餘三家每人付一半（3→4、4→8、5→12 … 10→64）。
- 第一版必須有：食糊（出銃／自摸）、碰、上（只限下家）、槓（明槓）、花牌補牌、流局。
- 第一版不做：包牌、搶槓、一炮多響、莊家加成、比賽場、真人連線、複雜台型（坎坎糊、花么、天糊、地糊、槓上槓）。
- 所有文字同時提供英文／繁中；不得硬編碼只有英文的玩家可見字串。
- 改 `lib/` 後必須跑 `flutter analyze`、`flutter test`，再 build web、push gh-pages、核對 `main.dart.js` bytes 與 sha256。
- 不得把 `lib/screens/match_room_screen.dart` 的約戰 lobby 當成對局引擎；它是預約流程，不是牌桌。

## Review Focus

- 14 張手牌有多種拆法時，番數應取最高合法拆法，不可只取第一個。
- 碰／上／槓後手牌張數與「四面子一將」判斷必須仍然正確（槓算一個面子、四張牌）。
- 花牌補牌不可令牌牆/手牌張數失衡；補到花牌要繼續補。
- 玩家按「Pass」後不可再被同一個出銃反覆彈出 claim。
- 流局、食糊、重新開局後計時器與選牌狀態必須清空，不可殘留上局事件。

---

### Task 1: 牌張工具與勝負判斷

**Files:**
- Create: `lib/game/tile_set.dart`
- Create: `lib/game/win_checker.dart`
- Test: `test/win_checker_test.dart`

**Interfaces:**
- Consumes: 現有字串牌碼（`m1`…`white`、`f_plum`…）。
- Produces: `TileSet.allTileCodes`, `TileSet.flowerCodes`, `TileSet.isFlower(String)`, `TileSet.sortTiles(List<String>)`, `bool isWinningHand(List<String> concealed, {int meldCount = 0})`, `List<HandDecomposition> decomposeHands(List<String> concealed, {int meldCount = 0})`.

- [ ] Step 1: 寫 failing tests：標準 4 面子一將、七對、十三么、差一張、有面子數的 11 張手牌。
- [ ] Step 2: `flutter test test/win_checker_test.dart` 確認 fail。
- [ ] Step 3: 實作牌張排序、么九/番子/花色 helper、遞迴拆牌；`decomposeHands` 回傳所有合法拆法（面子種類＋將）。
- [ ] Step 4: 測試 pass。
- [ ] Step 5: commit `feat: add mahjong win checker`。

### Task 2: 番數與支付

**Files:**
- Create: `lib/game/faan_calculator.dart`
- Test: `test/faan_calculator_test.dart`

**Interfaces:**
- Consumes: `HandDecomposition`、`Meld`（Task 3 定義；先在本檔定義 `MeldKind`/`Meld` 供兩邊共用，Task 3 直接 import）。
- Produces: `class Meld`, `enum MeldKind`, `class FaanPattern`, `class WinScore { int faan; List<FaanPattern> patterns; int payout; int selfDrawEach; }`, `WinScore? scoreWin({required List<String> concealed, required List<Meld> melds, required List<String> flowers, required String seatWind, required String roundWind, required bool selfDraw})`, `int payoutForFaan(int faan)`, `int selfDrawShareForFaan(int faan)`.

- [ ] Step 1: failing tests：平糊＋自摸＋門前清＋無花 = 4 番；3 番出銃付 8；5 番自摸每人 12；清一色 7 番；低於 3 番回 null；多拆法取最高。
- [ ] Step 2: 實作番種（平糊、自摸、門前清、無花、正花、三元牌、風牌、混一色、對對糊、小/大三元、清一色、字一色、小/大四喜、十八羅漢、清么九、十三么、九蓮、大小花糊），10 番封頂。
- [ ] Step 3: 支付表與 `scoreWin` 完成，測試 pass。
- [ ] Step 4: commit `feat: add faan scoring`。

### Task 3: 牌局狀態、牌牆、摸打

**Files:**
- Create: `lib/game/table_engine.dart`
- Test: `test/table_engine_test.dart`

**Interfaces:**
- Consumes: Task 1/2。
- Produces: `enum TablePhase { playing, awaitingClaim, finished }`, `class TablePlayer { String seat; List<String> hand; List<Meld> melds; List<String> flowers; List<String> discards; bool get isHuman; }`, `class TableEngine { TableEngine({int seed = 1, bool playerIsDealer = true}); List<TablePlayer> players; List<String> wall; int currentPlayer; TablePhase phase; String? lastDiscard; int? lastDiscarder; void start(); void drawForCurrent(); bool discard(int player, String tile); void nextTurn(); }`.

- [ ] Step 1: failing tests：開局每人 13 張、莊家 14 張、牌牆 144 減已發；打牌後輪轉；花牌補牌。
- [ ] Step 2: 實作 `start/draw/discard/nextTurn` 與花牌 replacement、排序。
- [ ] Step 3: 測試 pass、commit `feat: add table engine core`。

### Task 4: 碰／上／槓／食糊 claim 與 AI

**Files:**
- Modify: `lib/game/table_engine.dart`
- Create: `lib/game/table_ai.dart`
- Test: `test/table_claims_test.dart`, `test/table_ai_test.dart`

**Interfaces:**
- Produces: `class ClaimOption { int player; MeldKind? meld; List<String> tiles; bool isWin; WinScore? score; }`, `List<ClaimOption> claimsForLastDiscard()`, `void applyClaim(ClaimOption option)`, `void passClaims()`, `String chooseDiscard(List<String> hand)`, `ClaimOption? chooseAiClaim(List<ClaimOption> options)`.

- [ ] Step 1: failing tests：碰、上（只限下家）、明槓、食糊優先、Pass 後前進、AI 拆牌不拆面子。
- [ ] Step 2: 實作 claim 判斷（win > kong > pong > chow、座位距離）與 AI heuristic。
- [ ] Step 3: 測試 pass、commit `feat: add claims and basic ai`。

### Task 5: 牌桌 UI 與流程控制

**Files:**
- Create: `lib/game/table_controller.dart`
- Create: `lib/screens/table_screen.dart`
- Test: `test/table_screen_test.dart`

**Interfaces:**
- Consumes: `TableEngine`、`TableAI`、`AudioService`。
- Produces: `TableController extends ChangeNotifier`：`startNewHand()`, `selectTile(String)`, `discardSelected()`, `claim(ClaimOption)`, `pass()`, `dispose()`；`TableScreen` 可直接 push。

- [ ] Step 1: failing widget test：載入見到「Play a hand」/桌面、玩家手牌可選、Discard 後手牌少一張。
- [ ] Step 2: 實作 controller 的 AI 延時（350ms）、claim sheet、結果 overlay、流局。
- [ ] Step 3: 實作桌面：四個座位、中央棄牌河、牌牆數、玩家手牌、選牌高亮、Last discard。
- [ ] Step 4: 測試 pass、commit `feat: add playable table screen`。

### Task 6: 入口、i18n、結果與再玩

**Files:**
- Modify: `lib/screens/practice_screen.dart`
- Modify: `lib/services/app_i18n.dart`
- Modify: `test/table_screen_test.dart`

- [ ] Step 1: 在 Practice 頂部加 `table.play` 卡，push `TableScreen`。
- [ ] Step 2: 加 `table.*` 中英字串；結果顯示勝者、番種、番數、支付、Play again。
- [ ] Step 3: widget test 覆蓋 entry 與 result replay；`flutter test` 全綠。
- [ ] Step 4: commit `feat: add practice table entry`。

### Task 7: 實機 QA、修正、部署

- [ ] Step 1: build web（base `/mahjong-learning/`），serve QA，登入測試帳號打一局：自摸/出銃/碰/上/槓/流局至少各一次。
- [ ] Step 2: 修正實機發現的 overflow、計時器、claim 卡死。
- [ ] Step 3: 正式 build、commit、push main、更新 gh-pages，核對 `main.dart.js` bytes 與 sha256。
- [ ] Step 4: 用可見文字如實報告未支援規則與未測分支。
