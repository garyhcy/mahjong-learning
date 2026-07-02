import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/match_data.dart';
import '../providers/game_state.dart';
import '../providers/match_state.dart';

/// Match chat room (simulated). Demo scope:
/// - 12-hour scheduling window (live countdown).
/// - Player can propose schedule slots; both sides vote.
/// - Unlimited proposals, but a 1-minute cooldown between proposals.
/// - When a slot has votes from both players → agreement → venue suggestion.
/// - Confirming a reservation consumes the weekly opportunity.
/// - Failing to agree can be reported; 3 failed attempts consume the week.
///
/// The opponent is a simple scripted bot that replies and votes so investors
/// can see the full loop end-to-end without a real second device.
class MatchRoomScreen extends StatefulWidget {
  const MatchRoomScreen({super.key, required this.opponent});

  final MatchCandidate opponent;

  @override
  State<MatchRoomScreen> createState() => _MatchRoomScreenState();
}

class _MatchRoomScreenState extends State<MatchRoomScreen> {
  static const Color _green = Color(0xFF4CAF50);
  static const Color _bg = Color(0xFFF5F9F3);
  static const String _meId = 'me';

  static const Duration _window = Duration(hours: 12);
  static const Duration _cooldown = Duration(minutes: 1);

  final List<MatchMessage> _messages = [];
  final List<ScheduleProposal> _proposals = [];
  final _scrollController = ScrollController();

  late DateTime _expiresAt;
  Timer? _ticker;
  Duration _remaining = _window;

  DateTime? _lastProposalAt;
  Timer? _cooldownTicker;
  Duration _cooldownLeft = Duration.zero;

  bool _agreed = false;
  bool _confirmed = false;
  ScheduleProposal? _agreedSlot;

  @override
  void initState() {
    super.initState();
    _expiresAt = DateTime.now().add(_window);
    _messages.add(MatchMessage(
      senderId: 'system',
      senderName: 'System',
      text:
          'You matched with ${widget.opponent.name}! You have 12 hours to agree on a day & time. Propose a slot below.',
      isSystem: true,
    ));
    _messages.add(MatchMessage(
      senderId: widget.opponent.id,
      senderName: widget.opponent.name,
      text: 'Hi! Looking forward to a game. When works for you?',
    ));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final left = _expiresAt.difference(DateTime.now());
      setState(() => _remaining = left.isNegative ? Duration.zero : left);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _cooldownTicker?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _onCooldown => _cooldownLeft > Duration.zero;
  bool get _expired => _remaining == Duration.zero;

  void _startCooldown() {
    _lastProposalAt = DateTime.now();
    _cooldownLeft = _cooldown;
    _cooldownTicker?.cancel();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(_lastProposalAt!);
      final left = _cooldown - elapsed;
      setState(() => _cooldownLeft = left.isNegative ? Duration.zero : left);
      if (left.isNegative) _cooldownTicker?.cancel();
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Propose a slot ──
  void _openProposeSheet() {
    if (_onCooldown || _expired || _agreed) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProposeSheet(
        onSubmit: (day, time) {
          Navigator.of(context).pop();
          _addProposal(day, time);
        },
      ),
    );
  }

  void _addProposal(DayPref day, TimeBand time) {
    final proposal = ScheduleProposal(
      id: 'p${_proposals.length}',
      day: day,
      time: time,
      proposedBy: _meId,
      votes: {_meId},
    );
    setState(() {
      _proposals.add(proposal);
      _messages.add(MatchMessage(
        senderId: _meId,
        senderName: 'You',
        text: 'Proposed: ${proposal.label}',
      ));
    });
    _startCooldown();
    _scrollToBottom();
    // Opponent reacts after a short delay: votes yes ~60% of the time.
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final accepts = widget.opponent.reliability > 0.78 ||
          DateTime.now().millisecond % 10 < 6;
      if (accepts) {
        setState(() {
          proposal.votes.add(widget.opponent.id);
          _messages.add(MatchMessage(
            senderId: widget.opponent.id,
            senderName: widget.opponent.name,
            text: 'That works for me! ✅ (${proposal.label})',
          ));
          _agreed = true;
          _agreedSlot = proposal;
        });
      } else {
        setState(() {
          _messages.add(MatchMessage(
            senderId: widget.opponent.id,
            senderName: widget.opponent.name,
            text: 'Hmm, ${proposal.label} is tough for me. Another slot?',
          ));
        });
      }
      _scrollToBottom();
    });
  }

  void _toggleMyVote(ScheduleProposal p) {
    if (_expired || _agreed) return;
    setState(() {
      if (p.votes.contains(_meId)) {
        p.votes.remove(_meId);
      } else {
        p.votes.add(_meId);
      }
      if (p.votes.contains(_meId) && p.votes.contains(widget.opponent.id)) {
        _agreed = true;
        _agreedSlot = p;
      }
    });
  }

  // ── Confirm reservation → consume weekly opportunity ──
  Future<void> _confirmReservation(Venue venue) async {
    final match = context.read<MatchState>();
    await match.recordConfirmedReservation();
    setState(() {
      _confirmed = true;
      _messages.add(MatchMessage(
        senderId: 'system',
        senderName: 'System',
        text:
            'Reservation confirmed at ${venue.name} for ${_agreedSlot!.label}. See you there! 🀄',
        isSystem: true,
      ));
    });
    _scrollToBottom();
  }

  // ── Report failure to agree → counts toward 3 failed attempts ──
  Future<void> _reportFailed() async {
    final match = context.read<MatchState>();
    await match.recordFailedAttempt();
    if (!mounted) return;
    final used = !match.hasWeeklyOpportunity;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Scheduling unsuccessful',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          used
              ? 'That was your 3rd unsuccessful try this week. Your free weekly match is now used up — it resets next week, or go Pro for unlimited matches.'
              : 'No worries. You have ${match.failedRemaining} scheduling tries left this week.',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3A2E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.opponent.name,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            Text(
                _expired
                    ? 'Window expired'
                    : 'Closes in ${_fmt(_remaining)}',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: _expired
                        ? const Color(0xFFC62828)
                        : const Color(0xFF6B7A6E))),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_proposals.isNotEmpty) _proposalBar(),
            Expanded(child: _chatList()),
            if (_agreed && !_confirmed) _venuePicker(),
            if (_confirmed) _confirmedBanner(),
            if (!_confirmed) _composer(),
          ],
        ),
      ),
    );
  }

  Widget _proposalBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Proposed slots — tap to vote',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9AA89C))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _proposals.map((p) {
              final mine = p.votes.contains(_meId);
              final theirs = p.votes.contains(widget.opponent.id);
              final both = mine && theirs;
              return GestureDetector(
                onTap: () => _toggleMyVote(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: both
                        ? _green
                        : (mine ? const Color(0xFFE8F5E9) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: both ? _green : const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.label,
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: both
                                  ? Colors.white
                                  : const Color(0xFF2D3A2E))),
                      const SizedBox(width: 6),
                      Text('${p.votes.length}/2',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: both
                                  ? Colors.white
                                  : const Color(0xFF9AA89C))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[i];
        if (m.isSystem) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(m.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8D6E63))),
          );
        }
        final mine = m.senderId == _meId;
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: mine ? _green : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: mine ? null : Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Text(m.text,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: mine ? Colors.white : const Color(0xFF2D3A2E))),
          ),
        );
      },
    );
  }

  Widget _composer() {
    final disabled = _onCooldown || _expired || _agreed;
    String label;
    if (_expired) {
      label = 'Window expired';
    } else if (_agreed) {
      label = 'Slot agreed — pick a venue below';
    } else if (_onCooldown) {
      label = 'Propose again in ${_fmt(_cooldownLeft)}';
    } else {
      label = 'Propose a Day & Time';
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: disabled ? null : _openProposeSheet,
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text(label,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          if (!_agreed && !_expired)
            TextButton(
              onPressed: _reportFailed,
              child: Text("Can't agree? Report unsuccessful",
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9AA89C))),
            ),
        ],
      ),
    );
  }

  Widget _venuePicker() {
    final venues = MatchDemoData.venues();
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎉 Agreed on ${_agreedSlot?.label}! Pick a venue',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3A2E))),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: venues.map((v) => _venueRow(v)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueRow(Venue v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8F0E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name,
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                    '${v.district} · HK\$${v.pricePerHour.round()}/hr · ⭐${v.rating}',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF6B7A6E))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (v.hasStaff) _tag('On-site staff'),
                    if (v.transparentPricing) _tag('Transparent pricing'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmReservation(v),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Book',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32))),
    );
  }

  Widget _confirmedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFE8F5E9),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: _green, size: 32),
          const SizedBox(height: 8),
          Text('Reservation confirmed!',
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E7D32))),
          const SizedBox(height: 4),
          Text('${_agreedSlot?.label} · See you at the table',
              style: GoogleFonts.nunito(
                  fontSize: 12, color: const Color(0xFF6B7A6E))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _green),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Done',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, color: _green)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to propose a day + time slot.
class _ProposeSheet extends StatefulWidget {
  const _ProposeSheet({required this.onSubmit});
  final void Function(DayPref day, TimeBand time) onSubmit;

  @override
  State<_ProposeSheet> createState() => _ProposeSheetState();
}

class _ProposeSheetState extends State<_ProposeSheet> {
  static const Color _green = Color(0xFF4CAF50);
  DayPref? _day;
  TimeBand? _time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Propose a slot',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text('Day',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DayPref.values.map((d) {
              final sel = _day == d;
              return ChoiceChip(
                label: Text(d.short),
                selected: sel,
                onSelected: (_) => setState(() => _day = d),
                selectedColor: _green,
                labelStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : const Color(0xFF424242)),
                backgroundColor: const Color(0xFFF5F5F5),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Time',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TimeBand.values.map((t) {
              final sel = _time == t;
              return ChoiceChip(
                label: Text(t.label),
                selected: sel,
                onSelected: (_) => setState(() => _time = t),
                selectedColor: _green,
                labelStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : const Color(0xFF424242)),
                backgroundColor: const Color(0xFFF5F5F5),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_day != null && _time != null)
                  ? () => widget.onSubmit(_day!, _time!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Send Proposal',
                  style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
