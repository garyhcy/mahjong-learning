# Ticket 07 — Stage 14 (Faan Mastery) 作者 SPEC

你要為 Ludi（教外國人打香港麻雀的 App）寫指定的 **幾課** 新課程內容，輸出一個 JSON 檔。內容語言＝英文（學習者係外國人），但牌名同時保留中文（例如 `Big Flower Hand 大花糊`）。

## 你要讀的檔

1. `docs/GARY_RULES_REFERENCE.md` — 唯一權威規則來源（半銃制）。**任何番數、包牌、限制一律以此檔為準**，唔准自己發明。
2. `lib/models/mahjong_data.dart` 裡面 Stage 13 任何一課（例如 `id: '13-1'`）— 睇現有課程的語氣、難度、題型寫法。

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
- 唔准用 `$` 符號（會撞 Dart 字串插值）。講錢要寫 `24 points`、`128 points`，唔好寫 `$24`。
- 每課要有 **4-5 句 dialogue**，`speaker` 只可以係 `"mj"`（導師）或 `"you"`（學習者）。語氣輕鬆、每句 1-2 句英文，唔好長篇大論。

## 課程清單（每課一個 lesson id）

| lesson id | title（英文，App 顯示） | subtitle | 必教重點（全部要有題目覆蓋） |
|---|---|---|---|
| 14-1 | Big Flower Hand | Eight flowers, the rarest luck | 大花糊＝摸到八張花＝例牌 10 番；對比小花糊＝摸到七張花＝3 番；一台花（四張四季或四張花）＝2 番；花牌係即摸即補；10 番出銃 128／自摸每人 64 |
| 14-2 | All Terminals & Honours | 花么 — ones, nines and honours only | 花么＝1 番；手牌只有么、九、番子；同時一定係對對糊（另加 3 番），實收 4 番；同清么九（例牌 10，只限么九數牌）及字一色（例牌 10，全部番子）之分別 |
| 14-3 | Rob the Kong | 搶槓 — stealing the fourth tile | 搶槓＝1 番；當他家開**加槓**（用自己摸到嘅第四張牌補上原有坎子）嘅牌正好係自己食糊嘅牌；十三么可以搶**暗槓**；被搶一方當包自摸、一家付足整個自摸金額 |
| 14-4 | Last Tile of the Wall | 海底撈月 — winning on the final draw | 海底撈月＝1 番；自摸牌牆最後一張牌食糊；一定係自摸，唔係人哋打出；可以同其他番種累加（例如自摸 1 番＋海底 1 番） |
| 14-5 | Concealed Hand | 門前清 — nothing claimed | 門前清＝1 番；胡牌前冇吃、冇碰、冇**明槓**；**暗槓不破門前清**（Gary 裁決）；同自摸一齊可以有 2 番；一旦碰或吃過就冇 |
| 14-6 | Faan to Points | Turning faan into money | 半銃分數表：3 番＝出銃 8／自摸每人 4；4 番＝16／8；5 番＝24／12；6 番＝32／16；7 番＝48／24；8 番＝64／32；9 番＝96／48；10 番＝128／64；出銃者全付、自摸每人付出銃金額一半、10 番封頂 |
| 14-7 | How Many Faan? | Put the whole chart to work | 綜合測驗：描述一副牌（例如「自摸、門前清、平糊」＝自摸 1＋門前清 1＋平糊 1＝3 番），要考生計番數同應收分數；至少一題考包牌（大三元包／搶槓包）令某人一家付 |

其他通用事實（可以入題）：一輪四圈 16 局；三番起糊；10 番為上限、例牌一律算 10 番；莊家冇特別加成；流局莊家不連莊；門風花每張 1 番；無花 1 番；自摸 1 番；三元牌、風牌坎各 1 番（門風＋圈風重疊算兩番）；平糊 1 番；混一色 3 番；對對糊 3 番；清一色 7 番。

**注意**：Stage 7 已經有 `Faan Chart Overview`、`Payment Calculation`、`Stacking Faan` 三課。14-6／14-7 唔可以照抄，要**加深**：用具體例子計錢、故意混淆出銃 vs 自摸、加入 10 番封頂同包牌例外。

## 輸出格式（唯一允許）

寫檔 `SCRATCH_FILE`（路徑由派工訊息指定），內容係嚴格 JSON：

```json
{
  "14-1": {
    "title": "Big Flower Hand",
    "subtitle": "Eight flowers, the rarest luck",
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
  }
}
```

注意：
- JSON 唔准有註釋、唔准 trailing comma、唔准 markdown code fence。
- `tileOrdering` 要 `"tiles": ["m1","m2","m3"]`；`matching` 要 `"pairs": [{"left":"...","right":"..."}]`；`multiChoice` 要 `"correctIndexes": [0,2]`。
- 牌名可以中英並列，例如 `"question": "How much is Big Flower Hand 大花糊 worth?"`。

## 交貨前自我檢查（一定要跑）

```python
import json, re
d = json.load(open('SCRATCH_FILE'))
valid = set(['m%d'%i for i in range(1,10)] + ['p%d'%i for i in range(1,10)] + ['s%d'%i for i in range(1,10)] +
            ['east','south','west','north','red','green','white','f_spring','f_summer','f_autumn','f_winter','f_plum','f_orchid','f_chrys','f_bamboo'])
for lid, l in d.items():
    assert len(l['questions']) == 8, lid
    assert len({q['type'] for q in l['questions']}) >= 3, lid
    assert 4 <= len(l['dialogues']) <= 5, lid
    for q in l['questions']:
        assert q['explanation'].strip(), (lid, q['question'])
        assert '$' not in json.dumps(q), (lid, q['question'])
        for t in re.findall(r'\{\{([^}]+)\}\}', q['question']):
            assert t in valid, (lid, t)
        if q['type'] == 'matching':
            r = [p['right'] for p in q['pairs']]
            assert len(set(r)) == len(r), (lid, q['question'])
        if q['type'] == 'multiChoice':
            assert len(q['correctIndexes']) >= 2, (lid, q['question'])
        if q['type'] == 'fillBlank':
            assert len(q['acceptedAnswers']) >= 4, (lid, q['question'])
print('OK')
```

印出 `OK` 才交貨。
