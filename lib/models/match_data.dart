import 'dart:math';

/// ─────────────────────────────────────────────────────────────
/// Ludi — Find a Match (約戰) data models
/// Demo scope: real frontend UI + interactions, simulated backend.
/// ─────────────────────────────────────────────────────────────

/// App / matchmaking language. Chosen on first launch, changeable in Settings.
enum AppLanguage {
  cantonese,
  mandarin,
  english,
}

extension AppLanguageInfo on AppLanguage {
  /// Stable key for storage.
  String get key {
    switch (this) {
      case AppLanguage.cantonese:
        return 'yue';
      case AppLanguage.mandarin:
        return 'cmn';
      case AppLanguage.english:
        return 'en';
    }
  }

  /// Label shown in the UI. For first-launch grouping, use [groupLabel].
  String get label {
    switch (this) {
      case AppLanguage.cantonese:
        return '廣東話';
      case AppLanguage.mandarin:
        return '普通話';
      case AppLanguage.english:
        return 'English';
    }
  }

  /// English descriptor — shown when app language is English.
  String get englishName {
    switch (this) {
      case AppLanguage.cantonese:
        return 'Cantonese';
      case AppLanguage.mandarin:
        return 'Mandarin';
      case AppLanguage.english:
        return 'English';
    }
  }

  /// First-launch group label: "中文" for cantonese/mandarin, "English" for english.
  String get groupLabel {
    switch (this) {
      case AppLanguage.cantonese:
      case AppLanguage.mandarin:
        return '中文';
      case AppLanguage.english:
        return 'English';
    }
  }

  /// Whether this is a Chinese variant.
  bool get isChinese =>
      this == AppLanguage.cantonese || this == AppLanguage.mandarin;

  /// Display label that adapts to the current app language.
  /// If [appIsEnglish] is true, show English names; otherwise show native script.
  String displayLabel(bool appIsEnglish) {
    if (this == AppLanguage.english) return 'English';
    return appIsEnglish ? englishName : label;
  }

  static AppLanguage fromKey(String? key) {
    switch (key) {
      case 'yue':
        return AppLanguage.cantonese;
      case 'cmn':
        return AppLanguage.mandarin;
      case 'en':
        return AppLanguage.english;
      default:
        return AppLanguage.cantonese;
    }
  }
}

/// Day-of-week availability preference (no specific time required).
enum DayPref { noPreference, mon, tue, wed, thu, fri, sat, sun }

extension DayPrefInfo on DayPref {
  String get short {
    switch (this) {
      case DayPref.noPreference:
        return 'Any';
      case DayPref.mon:
        return 'Mon';
      case DayPref.tue:
        return 'Tue';
      case DayPref.wed:
        return 'Wed';
      case DayPref.thu:
        return 'Thu';
      case DayPref.fri:
        return 'Fri';
      case DayPref.sat:
        return 'Sat';
      case DayPref.sun:
        return 'Sun';
    }
  }
}

/// Rough time-of-day band. Players pick preferred bands, or "no preference".
enum TimeBand { noPreference, morning, afternoon, evening, lateNight }

extension TimeBandInfo on TimeBand {
  String get label {
    switch (this) {
      case TimeBand.noPreference:
        return 'No preference';
      case TimeBand.morning:
        return 'Morning';
      case TimeBand.afternoon:
        return 'Afternoon';
      case TimeBand.evening:
        return 'Evening';
      case TimeBand.lateNight:
        return 'Late Night';
    }
  }

  String get range {
    switch (this) {
      case TimeBand.noPreference:
        return '';
      case TimeBand.morning:
        return '08:00 – 12:00';
      case TimeBand.afternoon:
        return '12:00 – 17:00';
      case TimeBand.evening:
        return '17:00 – 22:00';
      case TimeBand.lateNight:
        return '22:00 – 02:00';
    }
  }
}

/// ── Skill Rating (MMR), 0–100 ──
/// Derived from gameplay progress + accuracy + error rate, not self-declared.
class SkillRating {
  final int value; // 0–100

  const SkillRating(this.value);

  /// Compute a 0–100 rating from raw signals.
  /// - progress: 0..1 (lessons completed / total)
  /// - accuracy: 0..1 (correct / attempted across practice)
  /// - errorRate: 0..1 (wrong answers / attempted) — penalises sloppiness
  factory SkillRating.compute({
    required double progress,
    required double accuracy,
    required double errorRate,
  }) {
    final p = progress.clamp(0.0, 1.0);
    final a = accuracy.clamp(0.0, 1.0);
    final e = errorRate.clamp(0.0, 1.0);
    // Weights: progress 50%, accuracy 40%, error penalty 10%.
    final raw = (p * 50.0) + (a * 40.0) + ((1.0 - e) * 10.0);
    return SkillRating(raw.round().clamp(0, 100));
  }

  /// Display band name for the rating (cosmetic, for player aspiration).
  String get tierName {
    if (value >= 85) return 'Grandmaster';
    if (value >= 70) return 'Sharp';
    if (value >= 50) return 'Steady';
    if (value >= 30) return 'Rising';
    return 'Fresh';
  }

  String get tierEmoji {
    if (value >= 85) return '🐉';
    if (value >= 70) return '🔥';
    if (value >= 50) return '🀄';
    if (value >= 30) return '🌱';
    return '🐣';
  }
}

/// A candidate opponent surfaced by matchmaking (simulated for demo).
class MatchCandidate {
  final String id;
  final String name;
  final String avatarEmoji;
  final int skill; // 0–100
  final String city;
  final List<AppLanguage> languages;
  final List<DayPref> days;
  final List<TimeBand> times;
  final int gamesPlayed;
  final double reliability; // 0..1 show-up rate

  const MatchCandidate({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.skill,
    required this.city,
    required this.languages,
    required this.days,
    required this.times,
    required this.gamesPlayed,
    required this.reliability,
  });
}

/// A partnered venue recommended on a successful match (simulated for demo).
class Venue {
  final String id;
  final String name;
  final String district;
  final double pricePerHour; // HKD
  final double rating; // 0..5
  final bool hasStaff;
  final bool transparentPricing;

  const Venue({
    required this.id,
    required this.name,
    required this.district,
    required this.pricePerHour,
    required this.rating,
    required this.hasStaff,
    required this.transparentPricing,
  });
}

/// Message in a match chat room.
class MatchMessage {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime at;
  final bool isSystem;

  MatchMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    DateTime? at,
    this.isSystem = false,
  }) : at = at ?? DateTime.now();
}

/// A proposed schedule slot players vote on inside the chat room.
class ScheduleProposal {
  final String id;
  final DayPref day;
  final TimeBand time;
  final String proposedBy;
  final Set<String> votes; // voter ids
  final DateTime? slotDateTime; // exact date+time (30-min precision)

  ScheduleProposal({
    required this.id,
    required this.day,
    required this.time,
    required this.proposedBy,
    Set<String>? votes,
    this.slotDateTime,
  }) : votes = votes ?? {};

  String get label => '${day.short} · ${time.label}';
}


/// A persisted match room for the active-rooms list.
class MatchRoomData {
  final String id;
  final String title;
  final List<MatchCandidate> opponents;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? confirmedDay;
  final String? confirmedTime;
  final String? venueName;
  final DateTime deleteAt;
  final bool confirmed;

  MatchRoomData({
    required this.id,
    required this.title,
    required this.opponents,
    required this.createdAt,
    this.confirmedAt,
    this.confirmedDay,
    this.confirmedTime,
    this.venueName,
    required this.deleteAt,
    this.confirmed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'opponents': opponents.map((o) => {'id': o.id, 'name': o.name, 'avatarEmoji': o.avatarEmoji, 'skill': o.skill}).toList(),
    'createdAt': createdAt.toIso8601String(),
    'confirmedAt': confirmedAt?.toIso8601String(),
    'confirmedDay': confirmedDay?.toIso8601String(),
    'confirmedTime': confirmedTime,
    'venueName': venueName,
    'deleteAt': deleteAt.toIso8601String(),
    'confirmed': confirmed,
  };

  factory MatchRoomData.fromJson(Map<String, dynamic> j) {
    final opps = (j['opponents'] as List? ?? []).map((o) => MatchCandidate(
      id: o['id'] ?? '',
      name: o['name'] ?? 'Player',
      avatarEmoji: o['avatarEmoji'] ?? '🐼',
      skill: (o['skill'] as num?)?.toInt() ?? 50,
      city: '', languages: [], days: [], times: [],
      gamesPlayed: 0, reliability: 0.8,
    )).toList();
    return MatchRoomData(
      id: j['id'] ?? '',
      title: j['title'] ?? 'Match Room',
      opponents: opps,
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      confirmedAt: j['confirmedAt'] != null ? DateTime.tryParse(j['confirmedAt']) : null,
      confirmedDay: j['confirmedDay'] != null ? DateTime.tryParse(j['confirmedDay']) : null,
      confirmedTime: j['confirmedTime'],
      venueName: j['venueName'],
      deleteAt: DateTime.tryParse(j['deleteAt'] ?? '') ?? DateTime.now().add(Duration(days: 1)),
      confirmed: j['confirmed'] == true,
    );
  }
}

/// Random helpers to generate believable demo candidates/venues.
class MatchDemoData {
  static final _rng = Random();

  static const _names = [
    'Ka Ming', 'Wing', 'Tobie', 'Suet Yi', 'Marco', 'Hiu Tung',
    'Jasper', 'Mei Lin', 'Don', 'Yan', 'Carson', 'Pui Shan',
  ];
  static const _emojis = ['🐼', '🦊', '🐯', '🐰', '🦁', '🐵', '🐨', '🐶'];
  static const _cities = ['Hong Kong', 'Kowloon', 'New Territories'];

  /// Build a pool of candidates near a target skill rating.
  static List<MatchCandidate> candidates({
    required int targetSkill,
    required AppLanguage language,
    int count = 6,
  }) {
    final list = <MatchCandidate>[];
    for (var i = 0; i < count; i++) {
      final delta = _rng.nextInt(21) - 10; // ±10 skill band
      final skill = (targetSkill + delta).clamp(0, 100);
      list.add(MatchCandidate(
        id: 'cand_$i',
        name: _names[_rng.nextInt(_names.length)],
        avatarEmoji: _emojis[_rng.nextInt(_emojis.length)],
        skill: skill,
        city: _cities[_rng.nextInt(_cities.length)],
        languages: [language],
        days: DayPref.values
            .where((_) => _rng.nextBool())
            .toList(),
        times: TimeBand.values.where((_) => _rng.nextBool()).toList(),
        gamesPlayed: _rng.nextInt(80),
        reliability: 0.7 + _rng.nextDouble() * 0.3,
      ));
    }
    // Sort by closeness to target skill.
    list.sort((a, b) =>
        (a.skill - targetSkill).abs().compareTo((b.skill - targetSkill).abs()));
    return list;
  }

  /// Generate a 4-player room around target skill + language.
  /// Returns 3 opponents (the player is the 4th).
  static List<MatchCandidate> roomOpponents({
    required int targetSkill,
    required AppLanguage language,
  }) {
    return candidates(
      targetSkill: targetSkill,
      language: language,
      count: 3,
    );
  }

  static List<Venue> venues() => const [
        Venue(
          id: 'v1',
          name: 'Lucky Tiles Parlour',
          district: 'Mong Kok',
          pricePerHour: 60,
          rating: 4.7,
          hasStaff: true,
          transparentPricing: true,
        ),
        Venue(
          id: 'v2',
          name: 'Jade Dragon Club',
          district: 'Causeway Bay',
          pricePerHour: 80,
          rating: 4.5,
          hasStaff: true,
          transparentPricing: true,
        ),
        Venue(
          id: 'v3',
          name: 'Four Winds Lounge',
          district: 'Tsim Sha Tsui',
          pricePerHour: 70,
          rating: 4.6,
          hasStaff: true,
          transparentPricing: true,
        ),
      ];
}
