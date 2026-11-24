# 02 - 題型標準化與新增題型 widget

**What to build:** 統一現有題型為可擴充的標準介面，並新增缺失的題型 widget（填空、配對、排序），供後續課程擴充使用。每題依其 `question type` 決定單選/複選/拖曳/填空/配對/排序，無預設題型，逐題審查。該單選就單選，該複選就複選。

**Blocked by:** 01 - 進度系統（正確率追蹤需先就位，新題型才能正確計入）

**Status:** done-for-review

**範圍對應：** PHASE3_PLAN 階段 C1 / P2 #23 / Gary 已確認事項 #4

- [x] 定義統一題型介面（abstract class 或 sealed class），現有單選/複選/拖曳歸併
- [x] 新增填空題 widget（文字輸入 + 答案比對，支援中英文）
- [x] 新增配對題 widget（左側項目 ↔ 右側項目連線）
- [x] 新增排序題 widget（拖曳排序，複用既有 ReorderableListView）
- [x] 既有題目逐題審查 question type 是否正確（該單選就單選，該複選就複選）
- [x] `mahjong_data.dart` 題目結構支援新題型欄位
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages


## 完成記錄（2026-11-24）

### 架構
- `lib/models/quiz_answer.dart`：`QuizAnswer`（choice / ordering / text / matching 四種 payload）＋ `isQuizAnswerCorrect()` 單一驗證入口，`GameState.submitAnswer()` 統一呼叫，刪除原本 `_processAnswer` / `answerReviewQuestion` 各自重複的比對邏輯。
- `lib/widgets/quiz/question_inputs.dart`：`abstract class QuestionInput` + `QuestionInputConfig` + `buildQuestionInput()` switch 分派，六種題型各一個實作，`learn_screen.dart` 只保留一個 dispatch 點。
- `lib/widgets/quiz/tile_markers.dart`：`{{tile_id}}` 標記解析抽成共用函式；`lib/widgets/mahjong_tile.dart` 搬出 `MahjongTile`。
- `mahjong_data.dart`：`QuizType { singleChoice, multiChoice, tileSelection, tileOrdering, fillBlank, matching }`，新增 `acceptedAnswers`、`pairs`、`correctIndexes` 欄位。

### 逐題審查（212 題全數看過）
方法：把 214 條 `QuizQuestion(` 全部抽成 `lesson#idx [type] stem | options | -> correctIndex` 一覽，逐條判題型。

結論：**舊題目本身設計就係單選**——絕大部分是「情境決策題」（一個正確做法、三個誘餌），四個選項只有一個真確成立。因此：
- 維持 singleChoice：大部分題目（正確，冇改）。
- 維持 tileSelection（6 題）／tileOrdering（9 題）：題型選擇本身正確。
- 冇任何既有題目天然係真複選或配對（即「舊資料本來冇錯類型」），所以新題型要靠**改寫既有題目**去落地。

### 實際改寫（26 題）
| 題型 | 題數 | 例子 |
|---|---|---|
| fillBlank | 22 | 「How many players are in a standard mahjong game?」→ 接受 `4` / `four` / `4 players`；「How many tiles in a complete set?」→ `144`；番數上限 → `10` |
| matching | 2 | 「Match each tile family to how it looks」（4 對）；「Match each seat to its two flowers」（東南西北 ↔ 春夏秋冬／梅蘭菊竹） |
| multiChoice | 2 | 「Which of these ARE sources of Faan?」正確 = 箭刻／花牌／自摸；「Which of these are terminals?」正確 = `{{m1}}`、`{{s9}}` |

改寫原則：只改「同一知識點更適合另一種作答方式」的題；答案內容與解釋跟原有教學內容一致，冇新增未經課程涵蓋的知識。

### 測試
- `test/quiz_answer_test.dart`：14 個案例，覆蓋六種題型的正確／錯誤／邊界（大小寫、空格、標點、中文答案、部分配對、選多／選少）。
- `test/mahjong_data_test.dart`：逐題檢查答案定義完整性（複選至少 2 個正確、配對右值不可重複、填空必須有 acceptedAnswers 或 fallback），防止之後加題時再出現「題型與答案定義不匹配」。
- 全部 21 個 test 綠燈；`flutter analyze` 0 error。
