# 02 - 題型標準化與新增題型 widget

**What to build:** 統一現有題型為可擴充的標準介面，並新增缺失的題型 widget（填空、配對、排序），供後續課程擴充使用。每題依其 `question type` 決定單選/複選/拖曳/填空/配對/排序，無預設題型，逐題審查。該單選就單選，該複選就複選。

**Blocked by:** 01 - 進度系統（正確率追蹤需先就位，新題型才能正確計入）

**Status:** ready-for-agent

**範圍對應：** PHASE3_PLAN 階段 C1 / P2 #23 / Gary 已確認事項 #4

- [ ] 定義統一題型介面（abstract class 或 sealed class），現有單選/複選/拖曳歸併
- [ ] 新增填空題 widget（文字輸入 + 答案比對，支援中英文）
- [ ] 新增配對題 widget（左側項目 ↔ 右側項目連線）
- [ ] 新增排序題 widget（拖曳排序，複用既有 ReorderableListView）
- [ ] 既有題目逐題審查 question type 是否正確（該單選就單選，該複選就複選）
- [ ] `mahjong_data.dart` 題目結構支援新題型欄位
- [ ] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages
