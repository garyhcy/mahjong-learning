# Ticket 08 — Stage 15 (Table Mastery) 作者 SPEC

你要為 Ludi（教外國人打香港麻雀的 App）寫指定的 **課**，輸出一個 JSON 檔。內容語言＝英文（學習者係外國人），牌名／術語可以中英並列（例如 `closed wait 坎張`）。

Stage 15 係**最後一個 Stage**，主題係「實戰判斷」：叫糊判斷、數有效牌、揀打出邊張、睇場況、推或收。前面 Stage 8-12 已經教過概念（讀牌河、安全牌、效率、危險評估、收手），所以 Stage 15 要**用具體手牌同具體場況落手做決定**，唔可以再講一次概念。

## 你要讀的檔

1. `docs/GARY_RULES_REFERENCE.md` — 規則同番數唯一來源（半銃制）。
2. `lib/models/mahjong_data.dart` 裡面 Stage 14 任何一課（`id: '14-1'` 附近）— 睇語氣、難度、題型寫法。
3. `.scratch/ticket03/SPEC_STAGE14.md` — 上一張票的規格，格式一樣。

## 硬規則（違反即退貨）

- 每課 **正好 8 題**，**至少 3 種不同題型**，**4-5 句 dialogue**（`speaker` 只准 `mj`／`you`）。
- 題型字串只准：`singleChoice`、`multiChoice`、`tileSelection`、`tileOrdering`、`fillBlank`、`matching`。
  - `singleChoice`：4 個 `options` ＋ `correctIndex`
  - `multiChoice`：4 個 `options` ＋ `correctIndexes`（≥2）＋ `correctIndex`（＝correctIndexes[0]）
  - `tileSelection`：4 個 tile id `options` ＋ `correctIndex`
  - `tileOrdering`：`options: []`、`tiles`（3-5 個 tile id，正確次序）、`correctIndex: 0`
  - `fillBlank`：`options: []`、`acceptedAnswers` ≥4 種寫法（數字要有阿拉伯數字＋英文字）、`correctIndex: 0`
  - `matching`：`options: []`、`pairs` 3-4 對（右值不可重複）、`correctIndex: 0`
- 每題都要有 `explanation`（1-2 句英文）。
- 牌圖用 `{{tile_id}}`，id 只准 42 個：`m1..m9`、`p1..p9`、`s1..s9`、`east`、`south`、`west`、`north`、`red`、`green`、`white`、`f_spring`、`f_summer`、`f_autumn`、`f_winter`、`f_plum`、`f_orchid`、`f_chrys`、`f_bamboo`。
- 唔准出現 `$` 符號（講錢寫 `24 points`）。

## 手牌一定要機械驗證（最重要）

**任何講「呢手牌聽咩 / 有幾多 outs」嘅題目，你寫之前一定要用工具驗一次**：

```bash
cd /opt/data/home/Ludi/mahjong-learning
python3 .scratch/ticket03/waitcheck.py m2 m3 m4 m5 m6 p5 p6 p7 s3 s4 s5 east east --outs
```

- 13 隻牌 → 印出所有可食糊嘅牌同 outs 數。
- 14 隻牌 → 印 `complete hand: True/False`。
- 答案一定要同工具輸出**完全一致**；工具話錯就改手牌或改答案，唔准靠感覺。
- outs 數只計「4 張減手上持有」，除非題目另外講明有幾多張已經打出（講明就要扣）。

## 課程清單

| lesson id | title | subtitle | 必教重點 |
|---|---|---|---|
| 15-3 | Choosing the Discard | Which tile keeps the most hand alive | 同一手牌有幾個打法時，計每個打法保留幾多 outs，揀最大；例子要具體（14 隻牌 → 打邊張 → 13 隻牌聽咩），用 waitcheck.py 驗；唔好只講「打孤張」 |
| 15-4 | Reading the Table | Danger is what they have shown you | 場況判斷：同一手牌，桌面已經見到咩牌（碰／槓／連續打出同一花色／有人明顯做混一色）會改變最佳出牌；要有一題「安全牌 vs 效率」的取捨 |
| 15-5 | Push or Fold | When a small hand is not worth the risk | 叫糊與否：手上 1 番／2 番（未夠三番起糊）嘅時候要唔要繼續衝；對比 5 番大牌時嘅取捨；要有一題講「未夠三番起糊」嘅具體後果 |
| 15-6 | Graduation Challenge | Everything, all at once | 綜合：由叫糊、數 outs、揀打出、判斷危險、推或收混合出題，至少一題要同時用到兩項知識（例如「打呢張會聽幾多 outs，但係危險，值唔值」） |

番數／限制一律照 `GARY_RULES_REFERENCE.md`（三番起糊、10 番封頂、半銃分數表）。

## 輸出格式（唯一允許）

寫檔 `SCRATCH_FILE`（路徑由派工訊息指定），嚴格 JSON：

```json
{
  "15-3": {
    "title": "Choosing the Discard",
    "subtitle": "Which tile keeps the most hand alive",
    "dialogues": [
      {"speaker": "mj", "text": "..."},
      {"speaker": "you", "text": "..."},
      {"speaker": "mj", "text": "..."},
      {"speaker": "mj", "text": "..."}
    ],
    "questions": [
      {"type": "singleChoice", "question": "...", "options": ["a","b","c","d"], "correctIndex": 1, "explanation": "..."},
      {"type": "fillBlank", "question": "...", "options": [], "correctIndex": 0, "acceptedAnswers": ["8","eight","8 outs"], "explanation": "..."}
    ]
  }
}
```

唔准有註釋、唔准 trailing comma、唔准 markdown code fence。

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
            assert q['correctIndex'] == q['correctIndexes'][0], (lid, q['question'])
        if q['type'] == 'fillBlank':
            assert len(q['acceptedAnswers']) >= 4, (lid, q['question'])
print('OK')
```

印出 `OK` 才交貨。
