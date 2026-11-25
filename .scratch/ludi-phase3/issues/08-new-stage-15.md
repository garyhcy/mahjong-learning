# 08 - 新增 Stage 15（高級課程：叫糊判斷 + 最佳出牌策略）

**What to build:** 新增 Stage 15，高級課程：叫糊判斷、最佳出牌策略。每課 8-12 題，多樣題型。

**Blocked by:** 02 - 題型標準化、07 - 新增 Stage 14（解鎖鏈需連續）

**Status:** done

**範圍對應：** PHASE3_PLAN 階段 C3c / P2 #22, #23 / Gary 已確認事項 #1, #3

- [x] 新增 Stage 15 課程結構（叫糊判斷 + 最佳出牌策略，至少 2 課）
- [x] 叫糊判斷課：給手牌判斷聽哪些牌
- [x] 最佳出牌策略課：給手牌與場況判斷最佳出牌
- [x] 每課 8-12 題，每課 ≥ 2 種題型
- [x] Stage 15 解鎖條件沿用 Ticket 01 的完成制解鎖（原 70% 門檻已按 Gary 決策取消）
- [x] `flutter analyze` 零 error；`flutter build web` 成功；部署 gh-pages

## 完成記錄（2026-11-25）

**Stage 15「Table Sense」— 6 課 × 8 題 = 48 題**，全課程累計 15 stages / 92 lessons / 738 questions。

| 課 | 標題 | 題型數 | 重點 |
|---|---|---|---|
| 15-1 | Reading Your Waits | 5 | 兩面／邊張／坎張／單吊，十三么聽十三門 |
| 15-2 | Counting Outs | 5 | 手上副本與桌面明牌扣減，九蓮寶燈 23 outs |
| 15-3 | Choosing the Discard | 6 | 同一手 14 張比較四個打法（11 / 7 / 4 / 0 outs） |
| 15-4 | Reading the Table | 5 | 明刻定花色、槓令四張全死、棄牌堆證據、安全與效率取捨 |
| 15-5 | Push or Fold | 5 | 2 番不能出銃、自摸升至 3 番收 12；風險對比 24 / 128 |
| 15-6 | Graduation Challenge | 5 | 綜合：讀聽、數 outs、揀打出、計番與付款表 |

**驗證方法：** 新增 `.scratch/ticket03/waitcheck.py`（13 張列全部食糊牌與 live outs、14 張判完成；支援標準形、七對、十三么），所有 waits/outs 數字均由工具輸出，非人手估算。內容用 `.scratch/ticket03/gen_stage.py` 注入，`check_lesson()` 預檢（每課 8 題、≥3 題型、tile id 白名單、配對右值唯一、fillBlank 有 acceptedAnswers）。

**其他改動：** `MatchingInput` 右側選項改用 `parseTileMarkers`，配對題可顯示牌圖；`content_strings.dart` 加 `stage.stage15.title`／`subtitle`。

**測試：** `flutter analyze` 0 error（88 個既有 warning/info）、`flutter test` 27/27。`test/mahjong_data_test.dart` 對全部 92 課檢查 8–12 題及 ≥2 題型。

**Commit／部署：** `f8f8bf2`；gh-pages `1b622d3`；`main.dart.js` 3,884,727 bytes、sha256 前 16 位 `8153c8f38ccce4c2`，raw.githubusercontent 與 Pages CDN 均與本地 build 一致。
