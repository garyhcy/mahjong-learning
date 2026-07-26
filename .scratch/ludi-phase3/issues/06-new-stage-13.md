# 06 - 新增 Stage 13（缺失牌型課程）

**What to build:** 新增 Stage 13，涵蓋缺失的牌型課程：小三元、大三元、小四喜、大四喜、坎坎糊、十八羅漢、天糊、地糊、九蓮寶燈。每課 8-12 題，多樣題型。

**Blocked by:** 02 - 題型標準化（新題型 widget 需先就位）
**Soft dependency:** 03 - 現有課程擴充 Stage 1-4（建議先做以確認擴充模式，但不阻塞）

**Status:** ready-for-agent

**範圍對應：** PHASE3_PLAN 階段 C3a / P2 #19, #23 / Gary 已確認事項 #1, #3

- [ ] 新增 Stage 13 課程結構（9 種牌型各一課）
- [ ] 每課 8-12 題，每課 ≥ 2 種題型
- [ ] 牌型定義與番數對照 GARY_RULES_REFERENCE 半銃制正確
- [ ] Stage 13 解鎖條件納入 Ticket 01 的 70% 正確率邏輯
- [ ] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages
