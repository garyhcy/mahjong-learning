# 09 UI/UX — 實作拆解與分期（2026-11-24）

原票五項需求，我先量度現狀，再拆成四期。**現狀量度結果**：

| 票上項目 | 現狀 | 差距 |
|---|---|---|
| (1) tap to continue 全頁可點 | 只有左邊對話面板（約 440px）可點；右邊約 960px 死區，實測點 (1250,400) 完全無反應 | **真問題，要修** |
| (2) 教學加一頁選項防點太快 | 不存在；一按課程即入對話 | 新功能 |
| (3) 每課完成圖案（皇冠/剔/鎖） | 現時只有剔（完成）與鎖；無皇冠 | 加一級 |
| (4) 吉祥物多動作 | `MascotWidget` 已有 6 種表情，但只靠對話文字關鍵字觸發，同一課可能全程同一表情 | 改成輪替＋語氣配對 |
| (5) 錯題簿一鍵練全部 | **後端已完成**：`GameState.startWrongAnswerReview()`、Practice 卡入口、課後結果頁入口、review 模式 UI 全部有 | 只缺「錯題清單頁」與「答對後移出」規則 |

星級現況（`learn_screen.dart:952`）：正確率 ≥90 → 3 星、≥70 → 2 星、其餘 1 星；最佳正確率已存 `_lessonBestAccuracy` 並同步 Firestore。

## 分期

### Phase 1（小、風險低，一次部署）
- 1.1 對話頁整個 body 包一層 tap 區（左右兩欄都算），「Tap to continue」改成有底色的小按鈕提示，避免用戶以為要點文字。
- 1.2 課程列表完成圖案三級：`bestAccuracy == 100` → 皇冠；已完成但 < 100 → 剔；未做 → 鎖。Stage 標題旁加圖例。
- 驗收：`flutter test` 綠、analyze 0 error、部署後實機點右半頁可推進。

### Phase 2（中）
- 2.1 課程開始頁：點課程 → 預覽卡（標題、題數、上次成績、[開始]／[重播教學]），必須按掣才入對話。呢個就係「防點太快」的落點。
- 2.2 吉祥物姿態輪替：每課對話至少出現 3 種不同姿態；保留關鍵字優先（答對=happy、答錯=sad），其餘按句序輪替 content/thinking/wink/excited。

### Phase 3（中）
- 3.1 錯題簿頁面：列出所有錯題（題目、來源課程、曾錯次數），頂部「一鍵練全部」。
- 3.2 答對移出規則（待 Gary 決定：一次／兩次／不移出）。
- 注意：review 模式現時不扣心，答完不清錯題（`clearWrongAnswers` 只在設定頁手動）。

### Phase 4（大、可選）
- 4.1 課程地圖／單元卡／動效整體重做（Duolingo 式路徑）。屬視覺重做，建議獨立開票。

## 待 Gary 決定
- D1 錯題簿：答對一次就移出 / 要連續兩次答對 / 永不移出（只增不減）？
- D2 皇冠：只要 100% 全對才給，還是 ≥90% 都算（現時 3 星門檻係 90%）？
- D3 開始頁樣式：(a) 整頁預覽卡帶「開始」掣 / (b) 對話第一句下方加「開始」掣 / (c) 唔需要。

## 完成記錄（P1–P4，2026-11-24 至 25）

Gary 決策：D1a（錯題答對一次即移出）、D2a（最佳正確率 100% 才皇冠）、D3a（整頁預覽卡＋「開始」掣）。

### P1 全頁點擊＋三級圖案
- body 包 `GestureDetector(behavior: HitTestBehavior.opaque)`；並修好 body `Container` 因無約束而 shrink-wrap 到對話泡泡寬的老問題（補 `width/height: double.infinity`）。
- 完成圖案三級：`bestAccuracy >= 100` → `workspace_premium_rounded` 金冠；已完成 → 剔；未完成／鎖 → 鎖。
- 吉祥物按句序輪替，關鍵字（答對／答錯）優先。

### P2 課前預覽卡
- `_showLessonIntro` + `_buildLessonIntro`：mascot、課程標題、`N questions`、`Best so far: X%`、「Start」、`Skip the lesson intro`；必須按 Start 才入對話。

### P3 錯題簿清單頁
- 新 `lib/screens/wrong_answers_screen.dart`：逐題列出（課名＋簡化題幹）、單題刪除、`Practise all N`。
- `GameState._reviewSources` 記錄 review 題來源；答對即 `removeWhere(lessonId + questionIndex)` 移出錯題簿；另加 `removeWrongAnswer()`。
- Practice 卡加 `See all N` 入口；新測試 `test/wrong_answer_book_test.dart`。

### P4 Table Trail 地圖重做
- 新 `lib/widgets/stage_map.dart`：stage 變麻雀牌（68×94），沿奶白氈布曲線排列，x 偏移 8 段週期（幅度上限 96px，地圖最寬 620）；completed＝象牙金冠、current＝stage color＋白色進度條＋旁邊撒嬌 panda、unlocked＝象牙牌＋stage color 邊、locked＝牌背斜紋＋鎖。
- 連線：`CustomPainter` 畫 20px 奶白底帶，已完成段落實線、未完成虛線；入場 900ms stagger fade-up，`MediaQuery.disableAnimations` 時直接顯示。
- 當前牌旁有 mascot（`IgnorePointer`，不影響點擊）；每張牌有 `Semantics(button, label: "N. Stage title")`。
- Home `_buildLearningPath` 改用 `StageMap`；解鎖提示只顯示在「下一個未解鎖」那張，其餘顯示 `Locked`，減少重複噪音。
- 單元 banner gradient 改用當前 stage 顏色（原本固定綠），crowns 仍按已完成 stage 數計。
- Learn 的 stage 卡改牌形 icon（42×54）＋完成金冠＋`Cleared`，列表最寬 900 於桌面居中；lesson 列表沿用。
- 新測試 `test/stage_map_test.dart`（3 個：渲染三態、locked callback、available callback）。注意測試用 `pump(Duration(seconds: 1))`，因 mascot 有持續動畫，`pumpAndSettle` 會 timeout。
