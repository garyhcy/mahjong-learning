# 04 - 現有課程擴充 Stage 5-8（每課 8-12 題 + 多樣題型）

**What to build:** 將 Stage 5-8 現有課程每課題目擴充至 8-12 題，並加入多樣化題型（≥ 2-3 種）。

**Blocked by:** 02 - 題型標準化（新題型 widget 需先就位）

**Status:** done（2026-11-24）

**範圍對應：** PHASE3_PLAN 階段 C2b / P2 #18, #23 / Gary 已確認事項 #1

- [x] Stage 5 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 6 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 7 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 8 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] 新增題目內容正確（對照 GARY_RULES_REFERENCE 半銃制）
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages


## 完成記錄（2026-11-24）

- 22 課由 3-4 題擴充至 8-9 題，新增 **110 題**（Stage 5-8 總數 68 → 178）。
- 題型分佈（新增 110）：multiChoice 24、fillBlank 22、matching 18、singleChoice 24、tileSelection 12、tileOrdering 10。
  每課 ≥ 3 種題型；7-5 與 8-2 原有 4 題，擴充後 9 題（仍在 8-12 上限內）。
- 出題方式同 ticket 03：4 個零上下文 subagent（一 Stage 一個）讀 `.scratch/ticket03/SPEC.md`
  （已載入 Gary 2026-11-24 兩條裁決）＋ `docs/GARY_RULES_REFERENCE.md`，輸出
  `.scratch/ticket03/stage{5,6,7,8}.json`（每課 5 題）。
- 新增 `.scratch/ticket03/validate.py`（注入前驗證：題型、tile id、複選 ≥2 正確、配對右值唯一、
  填空有 acceptedAnswers、每課合併後 8-12 題）與 `.scratch/ticket03/inject_v2.py`
  （按檔名注入、已有 ≥8 題的課程自動跳過，避免重跑重複注入；`$` 亦已轉義）。
- 順手修正三處舊內容：`lib/models/mahjong_data.dart:4018` 花牌對話（改 一台花＝2 番不累加）、
  5 番對話列表（大三元誤列為例牌）、`搶槓`付款題（改為「當自摸，各家付」，依 GARY_RULES §4）。
- `test/mahjong_data_test.dart` 的覆蓋測試由 Stage 1-4 擴至 Stage 1-8。
- `dart format` OK、`flutter analyze` 0 error（87 issues 全為既有 deprecated/ lint info）、
  `flutter test` 25/25 綠。
