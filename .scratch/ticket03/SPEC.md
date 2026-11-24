# Ticket 03 — Stage 1-4 question expansion: authoring spec

## Goal
Each lesson in Stage 1-4 must end up with **8 questions** (3 existing + 5 new),
covering **at least 2 question types**, facts consistent with
`docs/GARY_RULES_REFERENCE.md` (Hong Kong 半銃制 rules).

## Output file
Write ONE JSON file per stage:

```
.scratch/ticket03/stage<N>.json
```

Shape:

```json
{
  "1-1": [ {question object}, ... 5 objects ... ],
  "1-2": [ ... ]
}
```

## Question object
```json
{
  "type": "singleChoice" | "multiChoice" | "tileSelection" | "tileOrdering" | "fillBlank" | "matching",
  "question": "string (English, may contain {{m1}} tile markers)",
  "options": ["..."] ,          // required; [] for matching
  "correctIndex": 0,             // index into options (0 for matching)
  "explanation": "short one-sentence rationale",
  // type-specific:
  "correctIndexes": [0, 2],      // multiChoice: >= 2 indices, must NOT be [correctIndex] only
  "acceptedAnswers": ["4", "four", "4 players"],  // fillBlank: 1-4 spellings, lowercase ok
  "pairs": [{"left": "East", "right": "Spring & Plum"}, ...], // matching: 3-4 pairs, right values MUST be unique
  "tiles": ["m1", "m2", "m3"]    // tileOrdering: 2-4 tile ids in the CORRECT order
}
```

## Hard rules
1. `tileSelection` options and `tileOrdering` tiles must use real tile ids:
   `m1..m9`, `p1..p9`, `s1..s9` (suits), `east south west north` (winds),
   `red green white` (dragons), `f_spring f_summer f_autumn f_winter f_plum f_orchid f_chrys f_bamboo` (flowers).
   Do NOT invent ids (e.g. no `b1`, no `east_wind`).
2. `fillBlank`: `options` may be `[]`; `acceptedAnswers` must include a numeric form
   and a word form where sensible (`"9"`, `"nine"`, `"9 tiles"`).
3. `matching`: 3-4 pairs; right-hand values must be mutually distinct.
4. `multiChoice`: at least 2 correct options and at least 1 wrong option.
5. Avoid duplicating an existing question in the same lesson (same fact, same wording).
   New questions must test the lesson's own topic, deeper than the existing 3.
6. Facts must match `docs/GARY_RULES_REFERENCE.md` (3 faan minimum, 10 faan cap,
   半銃制 payments, 番種 list). If a fact is not in that document and you are not
   certain, do not use it — pick another angle.
7. Explanations: one sentence, no fluff, no "Great job".

## Mix target per stage
Per lesson at least 2 of these types must appear among all 8 questions:
multiChoice, fillBlank, matching, tileOrdering, tileSelection.
Across a stage, use each of the five at least twice.

## Self-check before finishing
Run:
```
python3 -c "import json;d=json.load(open('.scratch/ticket03/stage<N>.json'));print({k:len(v) for k,v in d.items()})"
```
Every lesson must have exactly 5 entries.


## Gary rulings added 2026-11-24 (override ambiguity in the rules reference)
- **一台花 = 2 Faan in total** (a complete set of four Seasons OR four Plants). Do NOT add the
  matching seat flower on top of it. A single matching seat flower is still 1 Faan when you do
  not hold the complete set.
- **暗槓 (concealed kong) does NOT break 門前清.** Only a claimed chow/pong/exposed kong does.
- 3 Faan minimum, 10 Faan cap (limit hands = 10), 半銃制 payment table as in
  `docs/GARY_RULES_REFERENCE.md`.
