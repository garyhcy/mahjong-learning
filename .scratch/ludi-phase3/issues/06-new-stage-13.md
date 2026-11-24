# 06 - 新增 Stage 13（缺失牌型課程）

**What to build:** 新增 Stage 13，涵蓋缺失的牌型課程：小三元、大三元、小四喜、大四喜、坎坎糊、十八羅漢、天糊、地糊、九蓮寶燈。每課 8-12 題，多樣題型。

**Blocked by:** 02 - 題型標準化（新題型 widget 需先就位）
**Soft dependency:** 03 - 現有課程擴充 Stage 1-4（建議先做以確認擴充模式，但不阻塞）

**Status:** DONE (2026-11-24)

**範圍對應：** PHASE3_PLAN 階段 C3a / P2 #19, #23 / Gary 已確認事項 #1, #3

- [x] 新增 Stage 13 課程結構（9 種牌型各一課）
- [x] 每課 8-12 題，每課 ≥ 2 種題型（實作：每課 8 題、5 種題型）
- [x] 牌型定義與番數對照 GARY_RULES_REFERENCE 半銃制正確
- [x] Stage 13 解鎖沿用「完成上一 Stage」邏輯（2026-11-24 改為 completion-based）
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages（hash `087384d34b055507`）

---

## 完成記錄（2026-11-24）

**做法**：寫 `SPEC_STAGE13.md` → 3 個零上下文 subagent 分別寫 `stage13a/b/c.json`（每份 3 課）→ `gen_stage13.py` 驗證（每課 8 題、≥3 題型、4-5 句 dialogue、tile id 合法）後生成 Dart 並插入 `lib/models/mahjong_data.dart`。

**新增內容**：9 課 × 8 題 = 72 題。

| 課 | 牌型 | 番數 |
|---|---|---|
| 13-1 | 小三元 | 3 + 2 = 5 |
| 13-2 | 大三元（含「包」） | 5 + 3 = 8 |
| 13-3 | 小四喜 | 例牌 10 |
| 13-4 | 大四喜 | 例牌 10 |
| 13-5 | 坎坎糊 | 例牌 10 |
| 13-6 | 十八羅漢 | 例牌 10 |
| 13-7 | 天糊 | 例牌 10 |
| 13-8 | 地糊 | 例牌 10 |
| 13-9 | 九蓮寶燈 | 例牌 10 |

**題型分佈**：singleChoice 33、fillBlank 12、multiChoice 8、matching 8、tileSelection 8、tileOrdering 3。

**其他改動**：`lib/i18n/content_strings.dart` 加 Stage 13 中文標題；`game_state.dart` 兩處「12 stages」註釋改為動態描述（explorer 成就自動包含新 stage）；`test/mahjong_data_test.dart` 覆蓋範圍擴至 Stage 1-13。

**驗證**：`flutter analyze` 0 error、`flutter test` 27/27、`flutter build web` 成功、實機確認課程列表出現「Limit Hands」卡、課程總數顯示 79 課。

**Course 總量**：13 stages / 79 lessons / 634 questions。

**Commit**：`169ea41`；**部署**：gh-pages `166ea6b`，`main.dart.js` = 3,832,802 bytes / `087384d34b055507`。
