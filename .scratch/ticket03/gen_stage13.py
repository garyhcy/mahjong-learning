#!/usr/bin/env python3
"""Generate Stage 13 (Limit Hands) lessons + the stage entry from authored JSON.

Usage: python3 .scratch/ticket03/gen_stage13.py

Reads .scratch/ticket03/stage13{a,b,c}.json (written by the authoring
subagents), builds 9 Lesson blocks, inserts them before the closing `];` of
defaultLessons, and adds the LearningStage entry after stage12.
Refuses to run twice (it aborts if `id: '13-1'` already exists).
"""
import json
import sys
from pathlib import Path

ROOT = Path('/opt/data/home/Ludi/mahjong-learning')
DATA = ROOT / 'lib/models/mahjong_data.dart'
SCRATCH = ROOT / '.scratch/ticket03'

sys.path.insert(0, str(SCRATCH))
from inject_v2 import dart_str, to_dart  # noqa: E402

LESSON_ORDER = ['13-1', '13-2', '13-3', '13-4', '13-5', '13-6', '13-7', '13-8', '13-9']


def load_lessons() -> dict:
    merged = {}
    for part in ('a', 'b', 'c'):
        path = SCRATCH / f'stage13{part}.json'
        if not path.exists():
            raise SystemExit(f'missing {path}')
        data = json.loads(path.read_text())
        for lid, lesson in data.items():
            if lid in merged:
                raise SystemExit(f'duplicate lesson {lid} in {path}')
            merged[lid] = lesson
    missing = [lid for lid in LESSON_ORDER if lid not in merged]
    if missing:
        raise SystemExit(f'missing lessons: {missing}')
    extra = [lid for lid in merged if lid not in LESSON_ORDER]
    if extra:
        raise SystemExit(f'unexpected lessons: {extra}')
    return merged


def dialogue_dart(msg: dict) -> str:
    speaker = msg['speaker']
    if speaker not in ('mj', 'you'):
        raise SystemExit(f'bad speaker {speaker}')
    return ("      DialogueMessage(\n"
            f"        speaker: '{speaker}',\n"
            f"        text: {dart_str(msg['text'])},\n"
            "      ),")


def lesson_dart(lid: str, lesson: dict) -> str:
    questions = lesson['questions']
    if len(questions) != 8:
        raise SystemExit(f'{lid}: expected 8 questions, got {len(questions)}')
    types = {q.get('type', 'singleChoice') for q in questions}
    if len(types) < 3:
        raise SystemExit(f'{lid}: needs at least 3 question types, got {types}')

    dialogues = lesson['dialogues']
    if not 4 <= len(dialogues) <= 5:
        raise SystemExit(f'{lid}: expected 4-5 dialogues, got {len(dialogues)}')

    lines = [
        '  Lesson(',
        f"    id: '{lid}',",
        "    stageId: 'stage13',",
        f"    title: {dart_str(lesson['title'])},",
        f"    subtitle: {dart_str(lesson['subtitle'])},",
        '    dialogues: [',
        '\n'.join(dialogue_dart(m) for m in dialogues),
        '    ],',
        '    questions: [',
        '\n'.join(to_dart(q) for q in questions),
        '    ],',
        '  ),',
    ]
    return '\n'.join(lines)


STAGE_ENTRY = """  LearningStage(
    id: 'stage13',
    title: 'Limit Hands',
    subtitle: 'The hands that cap the table at 10 faan',
    icon: Icons.local_fire_department_rounded,
    color: const Color(0xFFB71C1C),
    lessonCount: 9,
  ),
"""


def main() -> None:
    text = DATA.read_text()
    if "id: '13-1'" in text:
        raise SystemExit('stage 13 looks already generated; aborting')

    lessons = load_lessons()

    # 1. stage entry, right after the stage12 entry
    anchor = """  LearningStage(
    id: 'stage12',
    title: 'Challenge Mode',
    subtitle: 'Timed challenges & special conditions',
    icon: Icons.emoji_events_rounded,
    color: const Color(0xFFFF6F00),
    lessonCount: 5,
  ),
"""
    if text.count(anchor) != 1:
        raise SystemExit('stage12 entry anchor not found exactly once')
    text = text.replace(anchor, anchor + STAGE_ENTRY)

    # 2. lesson blocks before the closing `];` of defaultLessons
    blocks = '\n'.join(lesson_dart(lid, lessons[lid]) for lid in LESSON_ORDER)
    banner = (
        '  // ═══════════════════════════════════\n'
        '  //  STAGE 13: Limit Hands (9 lessons)\n'
        '  // ═══════════════════════════════════\n')
    tail = '\n];\n'
    if not text.endswith(tail):
        raise SystemExit('file does not end with the expected `];`')
    text = text[:-len(tail)] + '\n' + banner + blocks + tail

    # 3. header comment
    text = text.replace('Complete Curriculum (12 Stages, 70 Lessons)',
                        'Complete Curriculum (13 Stages, 79 Lessons)')

    DATA.write_text(text)

    counts = {lid: len(lessons[lid]['questions']) for lid in LESSON_ORDER}
    total = sum(counts.values())
    print('inserted lessons:', ', '.join(f'{k}({v})' for k, v in counts.items()))
    print('total new questions:', total)


if __name__ == '__main__':
    main()
