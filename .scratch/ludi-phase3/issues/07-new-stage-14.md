# 07 - 新增 Stage 14（缺失牌型續 + 番表計算 + 牌型測驗）

**What to build:** 新增 Stage 14，涵蓋：大花糊、花么、搶槓、海底撈月、門前清（缺失牌型續），加上「番表計算」課（番數對應金額，半銃表）與「牌型值多少番」測驗課（給牌型判斷番數）。每課 8-12 題，多樣題型。

**Blocked by:** 02 - 題型標準化、06 - 新增 Stage 13（解鎖鏈需連續）

**Status:** DONE (2026-11-24)

**範圍對應：** PHASE3_PLAN 階段 C3b / P2 #19, #20, #21, #23 / Gary 已確認事項 #1, #3

- [x] 新增 Stage 14 課程結構（5 種缺失牌型 + 番表計算 + 牌型測驗，共 7 課）
- [x] 番表計算課：3F=8, 4F=16, 5F=24, 6F=32, 7F=48, 8F=64, 9F=96, 10F=128（半銃）
- [x] 牌型測驗課：給牌型判斷番數
- [x] 每課 8 題，每課 4-6 種題型
- [x] Stage 14 解鎖沿用「完成上一 Stage」邏輯
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages（hash `4da032e2d46ef1be`）

---

## 完成記錄（2026-11-24）

**做法**：`SPEC_STAGE14.md` → 3 個零上下文 subagent 分別寫 `stage14a/b/c.json` → 新的通用工具 `.scratch/ticket03/gen_stage.py`（可指定任何 stage／課號／標題／圖示／顏色）驗證後生成 Dart 並插入。舊的 `gen_stage13.py` 保留作歷史記錄。

**新增內容**：7 課 × 8 題 = 56 題。

| 課 | 名稱 | 教咩 |
|---|---|---|
| 14-1 | Big Flower Hand 大花糊 | 八張花＝例牌 10 番；七張花（小花糊）＝3 番不另加自摸；一台花 2 番；10 番自摸每人 64 |
| 14-2 | All Terminals & Honours 花么 | 1 番，必然連帶對對糊 3 番＝實收 4；同清么九／字一色分別 |
| 14-3 | Rob the Kong 搶槓 | 1 番；搶加槓為常態、十三么可搶暗槓；被搶者包足整個自摸金額 |
| 14-4 | Last Tile of the Wall 海底撈月 | 1 番；只限自摸牌牆最後一張；可與自摸累加（2 番仍未夠起糊） |
| 14-5 | Concealed Hand 門前清 | 1 番；暗槓不破、明槓／吃碰即破；配自摸 2 番仍不夠三番起糊 |
| 14-6 | Faan to Points | 半銃分數表實算：出銃 vs 自摸差額、反推番數、10 番封頂 |
| 14-7 | How Many Faan? | 情境綜合計番＋計錢，含大三元包與 13 番封頂 |

**題型分佈**：singleChoice 24、fillBlank 10、matching 7、multiChoice 7、tileSelection 5、tileOrdering 1。

**工具改動**：`gen_stage.py` 內置完整驗證（8 題、≥3 題型、4-5 dialogue、tile id 白名單、multiChoice ≥2 正解、matching 右值唯一、fillBlank ≥4 寫法、禁 `$`），任何一項不合格就一個 byte 都唔寫。`test/mahjong_data_test.dart` 由固定 stage 清單改為**全課程逐課檢查**，日後加 stage 唔會漏測。

**其他改動**：`lib/i18n/content_strings.dart` 加 `stage.stage14.title`（番數精通）／`subtitle`（計分、罕見牌型與封頂）。

**驗證**：`flutter analyze` 0 error、`flutter test` 27/27、`flutter build web` 成功、實機顯示 `Stage 1 0/14` 與 `3 / 86 lessons completed`。

**Course 總量**：14 stages / 86 lessons / 690 questions。

**Commit**：`09c7f54`；**部署**：gh-pages `b355783`，`main.dart.js` = 3,858,913 bytes / `4da032e2d46ef1be`。
