# Ticket 06 — Stage 13 (Limit Hands) 作者 SPEC

你要為 Ludi（教外國人打香港麻雀的 App）寫 **3 課** 新課程內容，輸出一個 JSON 檔。內容語言＝英文（學習者係外國人），但牌名同時保留中文（例如 `Small Three Dragons 小三元`）。

## 你要讀的檔

1. `docs/GARY_RULES_REFERENCE.md` — 唯一權威規則來源（半銃制）。**任何番數、包牌、限制一律以此檔為準**，唔准自己發明。
2. `lib/models/mahjong_data.dart` 裡面 Stage 12 任何一課（例如 `id: '12-1'` 附近）— 睇現有課程的語氣、難度、題型寫法。

## 硬規則（違反即退貨）

- 每個 lesson 要 **8 題 question**（正好 8 題），且 **至少 3 種不同題型**。
- 允許題型只有六種，字串必須一模一樣：
  - `singleChoice` — 單選，要有 `options`（4 個）＋ `correctIndex`（0-3）
  - `multiChoice` — 真複選，`options` 4 個 ＋ `correctIndexes`（至少 2 個 index）＋ `correctIndex`（第一個正確 index）
  - `tileSelection` — 揀牌，`options` 係 4 個 tile id，`correctIndex`
  - `tileOrdering` — 排序，`options: []`，`tiles` 係 3-5 個 tile id（正確次序），`correctIndex: 0`
  - `fillBlank` — 填空，`options: []`，`acceptedAnswers` 至少 4 個寫法（數字要同時有阿拉伯數字同英文字，例如 `["4","four","4 tiles"]`），`correctIndex: 0`
  - `matching` — 配對，`options: []`，`pairs` 係 3-4 對 `{"left":..., "right":...}`，**右邊值不可重複**，`correctIndex: 0`
- 每題必須有 `explanation`（1-2 句英文，講點解）。
- 題目文字內可以用 `{{tile_id}}` 顯示真實牌圖，例如 `{{m1}}` 或 `{{east}}`。**tile id 只准用以下 42 個**：
  `m1..m9`, `p1..p9`, `s1..s9`, `east`, `south`, `west`, `north`, `red`, `green`, `white`, `f_spring`, `f_summer`, `f_autumn`, `f_winter`, `f_plum`, `f_orchid`, `f_chrys`, `f_bamboo`
- 唔准用單引號入面再插 `$`（會撞 Dart 字串插值）。避免 `$` 符號。
- 每課要有 **4-5 句 dialogue**，`speaker` 只可以係 `"mj"`（導師）或 `"you"`（學習者）。語氣輕鬆、每句 1-2 句英文，唔好長篇大論。

## 課程清單（每課一個 lesson id）

| lesson id | title（英文，App 顯示） | subtitle | 必教重點（全部要有題目覆蓋） |
|---|---|---|---|
| 13-1 | Small Three Dragons | Two dragon triplets plus a dragon pair | 小三元＝3 番，另外兩組三元牌各 1 番，實收 5 番；牌型係兩個三元坎/槓 + 一個三元眼 |
| 13-2 | Great Three Dragons | All three dragons, and who pays | 大三元＝5 番，三組三元牌另加 3 番，實收 8 番；**大三元包**：明章有齊中發白坎/槓，供給第三副三元牌的一家包付自摸分（第三組為暗槓則無人包） |
| 13-3 | Small Four Winds | Three wind triplets, one wind pair | 小四喜＝例牌 10 番；三副風坎 + 風眼；四個風牌只計其中三副做坎 |
| 13-4 | Great Four Winds | All four winds at once | 大四喜＝10 番；四副風坎；同小四喜分別；10 番上限，其他番唔再累加 |
| 13-5 | All Concealed Triplets | Four hidden pungs | 坎坎糊（四暗坎）＝10 番；**不可有槓**；單吊可以食出銃，對碰必須自摸 |
| 13-6 | Eighteen Arhats | Four kongs in one hand | 十八羅漢＝10 番；手牌要有四個槓（明槓暗槓都算）；同坎坎糊分別（坎坎糊不准有槓） |
| 13-7 | Heavenly Hand | Winning on the dealt hand | 天糊＝10 番；只限東家、配牌即刻食糊；**暗槓之後不算天糊** |
| 13-8 | Earthly Hand | Winning on the dealer's first discard | 地糊＝10 番；閒家配牌已叫糊，食東家第一張打出；**東家暗槓之後不算地糊** |
| 13-9 | Nine Gates | 1112345678999 in one suit | 九蓮寶燈＝10 番；門清、同一花式 1112345678999 加任一隻同花式牌；自摸集齊即食，**食出銃必須叫九扉** |

其他通用事實（可以入題）：三番起糊；10 番為上限、例牌一律算 10 番；分數表 3 番＝出銃 8 / 自摸每人 4、10 番＝出銃 128 / 自摸每人 64；一台花整組 2 番（不另加門風花）；門前清唔怕暗槓；搶槓當包自摸（被搶一家付整個自摸金額）。

## 輸出格式（唯一允許）

寫檔 `SCRATCH_FILE`（路徑由派工訊息指定），內容係嚴格 JSON：

```json
{
  "13-1": {
    "title": "Small Three Dragons",
    "subtitle": "Two dragon triplets plus a dragon pair",
    "dialogues": [
      {"speaker": "mj", "text": "..."},
      {"speaker": "mj", "text": "..."},
      {"speaker": "you", "text": "..."},
      {"speaker": "mj", "text": "..."}
    ],
    "questions": [
      {"type": "singleChoice", "question": "...", "options": ["a","b","c","d"], "correctIndex": 1, "explanation": "..."},
      {"type": "fillBlank", "question": "...", "options": [], "correctIndex": 0, "acceptedAnswers": ["3","three","3 faan"], "explanation": "..."}
    ]
  },
  "13-2": { "...": "..." }
}
```

注意：
- JSON 唔准有註釋、唔准 trailing comma。
- `tileOrdering` 要 `"tiles": ["m1","m2","m3"]`；`matching` 要 `"pairs": [{"left":"...","right":"..."}]`；`multiChoice` 要 `"correctIndexes": [0,2]`。
- 牌名可以中英並列，例如 `"question": "Small Three Dragons 小三元 needs which pair as the eyes?"`。

## 自我檢查（交貨前一定要跑）

```python
python3 - <<'PY'
import json,sys
d=json.load(open('SCRATCH_FILE'))
assert len(d)==3, len(d)
valid_tiles=set(['m%d'%i for i in range(1,10)]+['p%d'%i for i in range(1,10)]+['s%d'%i for i in range(1,10)]+
 ['east','south','west','north','red','green','white','f_spring','f_summer','f_autumn','f_winter','f_plum','f_orchid','f_chrys','f_bamboo'])
for lid,lesson in d.items():
    qs=lesson['questions']; assert len(qs)==8, (lid,len(qs))
    types={q['type'] for q in qs}; assert len(types)>=3, (lid,types)
    assert 4<=len(lesson['dialogues'])<=5, (lid,len(lesson['dialogues']))
    for q in qs:
        assert q['type'] in {'singleChoice','multiChoice','tileSelection','tileOrdering','fillBlank','matching'}, q['type']
        assert q.get('explanation'), q['question']
        t=q['type']
        if t=='singleChoice': assert len(q['options'])==4 and 0<=q['correctIndex']<4
        if t=='multiChoice': assert len(q['options'])==4 and len(q.get('correctIndexes',[]))>=2
        if t=='tileSelection':
            assert len(q['options'])==4
            for o in q['options']: assert o in valid_tiles, o
        if t=='tileOrdering':
            assert q['options']==[] and 3<=len(q['tiles'])<=5
            for o in q['tiles']: assert o in valid_tiles, o
        if t=='fillBlank': assert len(q.get('acceptedAnswers',[]))>=4
        if t=='matching':
            assert 3<=len(q.get('pairs',[]))<=4
            rights=[p['right'] for p in q['pairs']]; assert len(set(rights))==len(rights)
        import re
        for tt in re.findall(r'\{\{([^}]+)\}\}', q['question']):
            assert tt in valid_tiles, tt
print('OK')
PY
```

跑完要確認印 `OK` 才回報完成。回報只需一句：寫了哪 3 課、每課題數、題型分佈。
