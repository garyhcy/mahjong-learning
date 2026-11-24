# 05 - 現有課程擴充 Stage 9-12（每課 8-12 題 + 多樣題型）

**What to build:** 將 Stage 9-12 現有課程每課題目擴充至 8-12 題，並加入多樣化題型（≥ 2-3 種）。

**Blocked by:** 02 - 題型標準化（新題型 widget 需先就位）

**Status:** done（2026-11-24）

**範圍對應：** PHASE3_PLAN 階段 C2c / P2 #18, #23 / Gary 已確認事項 #1

- [x] Stage 9 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 10 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 11 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 12 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] 新增題目內容正確（對照 GARY_RULES_REFERENCE 半銃制）
- [ ] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages


## 完成記錄（2026-11-24）

- 20 課由 3 題擴充至 8 題，新增 **100 題**（Stage 9-12 總數 60 → 160）。
- 題型分佈（新增 100）：multiChoice 20、matching 19、singleChoice 26、fillBlank 17、tileSelection 9、tileOrdering 8；
  每課 4-6 種題型。
- 出題方式同 ticket 03/04：4 個零上下文 subagent（一 Stage 一個），讀 `.scratch/ticket03/SPEC.md`
  （已載入 Gary 三條裁決，包括「搶槓當包自摸，被搶一方一家付」）＋ `docs/GARY_RULES_REFERENCE.md`，
  輸出 `.scratch/ticket03/stage{9,10,11,12}.json`，全部先過 `validate.py` 才注入。
- 全課程現況：**70 課、562 題、每課 8-9 題**；題型總分佈 fillBlank 91、multiChoice 73、singleChoice 72、
  matching 69、tileSelection 52、tileOrdering 34。
- `test/mahjong_data_test.dart` 覆蓋測試擴至 Stage 1-12。
- `dart format` OK、`flutter analyze` 0 error、`flutter test` 25/25 綠。
