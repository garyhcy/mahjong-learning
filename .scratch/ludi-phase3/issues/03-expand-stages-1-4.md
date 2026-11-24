# 03 - 現有課程擴充 Stage 1-4（每課 8-12 題 + 多樣題型）

**What to build:** 將 Stage 1-4 現有課程每課題目擴充至 8-12 題，並加入多樣化題型（單選、複選、拖曳、填空、配對、排序至少 2-3 種），不只是單選。

**Blocked by:** 02 - 題型標準化（新題型 widget 需先就位）

**Status:** done-for-review

**範圍對應：** PHASE3_PLAN 階段 C2a / P2 #18, #23 / Gary 已確認事項 #1

- [x] Stage 1（基礎）所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 2（番數基礎）所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 3 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] Stage 4 所有課程擴充至 8-12 題，每課 ≥ 2 種題型
- [x] 新增題目內容正確（對照 GARY_RULES_REFERENCE 半銃制）
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages


## 完成記錄（2026-11-24）
- 每課由 3 題擴充至 8 題（原有 3 題保留，新增 5 題），28 個課程共新增 140 題。
- 題型分佈（新增部分）：fillBlank 28、multiChoice 27、matching 28、tileSelection 26、tileOrdering 9、singleChoice 22；每課至少 2 種題型，部分課程有 4-5 種。
- 內容依 `docs/GARY_RULES_REFERENCE.md`（半銃制）出題：番數、出銃／自摸支付表、例牌計 10 番、手牌結構（4 組 + 1 對 = 14 張）、吃碰槓流程。
- 順手修正：lesson 1-6 對話把「大三元」講成 limit hand，按參考文件應為 5 + 3 = 8 番，已改寫該句。
- 生產工具：`.scratch/ticket03/SPEC.md`（出題規格）、`.scratch/ticket03/inject.py`（把 JSON 注入 `mahjong_data.dart`）、`.scratch/ticket03/stage1-4.json`（題目原文）。
- 測試：`test/mahjong_data_test.dart` 新增 Stage 1-4 覆蓋檢查（8-12 題、至少 2 種題型），全部 25 個 test 綠燈，`flutter analyze` 0 error。
