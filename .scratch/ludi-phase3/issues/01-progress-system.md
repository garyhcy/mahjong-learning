# 01 - 進度系統（Stage 70% 正確率解鎖 + 每課無 % 限制）

**What to build:** 玩家完成一個 Stage 內所有課程後，系統依「該 Stage 所有題目的總正確率（答對次數 / 總答題次數）」判斷是否解鎖下一 Stage。正確率 ≥ 70% 解鎖；未達標無懲罰，可重試（重試時因答錯題扣心心）。每一課本身無正確率門檻，答錯也能完成該課（扣心心），不阻塞該課的完成與下一課的開放。

**Blocked by:** None - can start immediately

**Status:** ready-for-agent

**範圍對應：** PHASE3_PLAN 階段 B / P1 #16-17 / Gary 已確認事項 #7-8

- [ ] 新增 Stage 正確率追蹤：每題記錄答對次數與總答題次數（per-stage 聚合），持久化至 SharedPreferences
- [ ] `game_state.dart` 解鎖邏輯改為：Stage 內所有課程完成 + Stage 總正確率 ≥ 70% 才解鎖下一 Stage
- [ ] 每課完成邏輯保留「走到最後一題即完成」，移除任何課內正確率門檻
- [ ] 未達 70% 時不扣額外懲罰，僅答錯題扣心心；可無限重試已完成的課以拉高正確率
- [ ] UI 呈現 Stage 鎖定狀態與正確率進度（鎖頭 + 當前正確率 %），達標即解鎖
- [ ] 正確率數據隨雲端同步（cloud_sync_service / Firestore），跨裝置一致
- [ ] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages
