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
  const MatchRoomScreen({super.key, required this.opponents, this.existingRoom, this.roomId, this.roomData});

  final List<MatchCandidate> opponents;
  final Map<String, dynamic>? existingRoom;
  final String? roomId;
  final MatchRoomData? roomData;

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
  final _textController = TextEditingController();

  late DateTime _expiresAt;
  Timer? _ticker;
  Duration _remaining = _window;

  DateTime? _lastProposalAt;
  Timer? _cooldownTicker;
  Duration _cooldownLeft = Duration.zero;

  bool _agreed = false;
  bool _confirmed = false;
  DateTime? _agreedSlot;

  @override
  void initState() {
    super.initState();
    _expiresAt = DateTime.now().add(_window);
    _messages.add(MatchMessage(
      senderId: 'system',
      senderName: 'System',
      text:
          'You matched with ${widget.opponents[0].name}! You have 12 hours to agree on a day & time. Propose a slot below.',
      isSystem: true,
    ));
    _messages.add(MatchMessage(
      senderId: widget.opponents[0].id,
      senderName: widget.opponents[0].name,
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
    _textController.dispose();
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

  String _fmtSlot(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute == 0 ? '00' : '30';
    return '${months[dt.month-1]} ${dt.day}, $h:$m';
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  // ── Send text message ──
  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(MatchMessage(senderId: _meId, senderName: 'You', text: text));
    });
    _textController.clear();
    _scrollToBottom();
    // Bot reply
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final replies = ['Sounds good!', 'Got it 👍', 'Sure, let me check my schedule.', 'OK!', 'I am fine with that.'];
      final reply = replies[DateTime.now().millisecond % replies.length];
      final bot = widget.opponents.isNotEmpty ? widget.opponents.first : null;
      setState(() {
        _messages.add(MatchMessage(
          senderId: bot?.id ?? 'bot1',
          senderName: bot?.name ?? 'Opponent',
          text: reply,
        ));
      });
      _scrollToBottom();
    });
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
        onSubmit: (slot) {
          Navigator.of(context).pop();
          _addProposal(slot);
        },
      ),
    );
  }

  void _addProposal(DateTime slot) {
    final proposal = ScheduleProposal(
      id: 'p${_proposals.length}',
      day: DayPref.values[slot.weekday % 7],
      time: TimeBand.evening,
      proposedBy: _meId,
      votes: {_meId},
      slotDateTime: slot,
    );
    setState(() {
      _proposals.add(proposal);
      _messages.add(MatchMessage(
        senderId: _meId,
        senderName: 'You',
        text: 'Proposed: ${_fmtSlot(proposal.slotDateTime)}',
      ));
    });
    _startCooldown();
    _scrollToBottom();
    // Opponent reacts after a short delay: votes yes ~60% of the time.
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final accepts = widget.opponents[0].reliability > 0.78 ||
          DateTime.now().millisecond % 10 < 6;
      if (accepts) {
        setState(() {
          proposal.votes.add(widget.opponents[0].id);
          _messages.add(MatchMessage(
            senderId: widget.opponents[0].id,
            senderName: widget.opponents[0].name,
            text: 'That works for me! ✅ (${_fmtSlot(proposal.slotDateTime)})',
          ));
          _agreed = true;
          _agreedSlot = proposal.slotDateTime;
        });
      } else {
        setState(() {
          _messages.add(MatchMessage(
            senderId: widget.opponents[0].id,
            senderName: widget.opponents[0].name,
            text: 'Hmm, that time is tough for me. Another slot?',
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
      if (p.votes.contains(_meId) && p.votes.contains(widget.opponents[0].id)) {
        _agreed = true;
        _agreedSlot = p.slotDateTime;
      }
    });
  }

  // ── Confirm reservation → consume weekly opportunity ──
  Future<void> _confirmReservation(Venue venue) async {
    final match = context.read<MatchState>();
    await match.recordConfirmedReservation();
    final slot = _agreedSlot ?? DateTime.now();
    final newDelete = slot.add(const Duration(hours: 24));
    await match.updateRoom(widget.roomId ?? '', {
      'confirmed': true,
      'confirmedDay': slot.toIso8601String(),
      'confirmedTime': _fmtSlot(slot),
      'venueName': venue.name,
      'deleteAt': newDelete.toIso8601String(),
    });
    setState(() {
      _confirmed = true;
      _messages.add(MatchMessage(
        senderId: 'system',
        senderName: 'System',
        text:
            'Reservation confirmed at ${venue.name} for ${_fmtSlot(slot)}. See you there! 🀄',
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
            Text(widget.opponents[0].name,
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
              final theirs = p.votes.contains(widget.opponents[0].id);
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
          // ── Text chat input (#9) ──
          if (!_confirmed) Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF9E9E9E)),
                    filled: true,
                    fillColor: const Color(0xFFF5F9F3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(fontSize: 14),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendText,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(
                    color: _green, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (!_confirmed) const SizedBox(height: 10),
          // ── Propose button ──
          if (!_agreed && !_expired) SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: disabled ? null : _openProposeSheet,
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          if (!_agreed && !_expired)
            TextButton(
              onPressed: _reportFailed,
              child: Text("Can't agree? Report unsuccessful",
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF9AA89C))),
            ),
        ],
      ),
    );
  }

  Widget _venuePicker() {
    final venues = MatchDemoData.venues();
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_agreedSlot != null
              ? 'Agreed on ${_fmtSlot(_agreedSlot)}! Pick a venue'
              : 'Pick a venue',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3A2E))),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...venues.map((v) => _venueRow(v)),
                // ── Other venue option ──
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Choose your own venue',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFE65100))),
                            const SizedBox(height: 2),
                            Text('Pick a place not on our list',
                                style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    color: const Color(0xFFBF360C))),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showOtherVenueWarning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text('Select',
                            style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOtherVenueWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 28),
            const SizedBox(width: 8),
            Text('Heads up!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Ludi cannot guarantee pricing transparency or on-site staff support for venues outside our partner network. You proceed at your own risk.\n\nAre you sure you want to continue?',
          style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF424242)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Go back',
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmReservationCustom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('I understand, proceed',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReservationCustom() async {
    final match = context.read<MatchState>();
    await match.recordConfirmedReservation();
    final slot = _agreedSlot ?? DateTime.now();
    final newDelete = slot.add(const Duration(hours: 24));
    await match.updateRoom(widget.roomId ?? '', {
      'confirmed': true,
      'confirmedDay': slot.toIso8601String(),
      'venueName': 'Custom venue',
      'deleteAt': newDelete.toIso8601String(),
    });
    setState(() {
      _confirmed = true;
      _messages.add(MatchMessage(
        senderId: 'system',
        senderName: 'System',
        text: 'Reservation confirmed at a custom venue for ${_fmtSlot(slot)}. See you there!',
        isSystem: true,
      ));
    });
    _scrollToBottom();
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
          Text('${_fmtSlot(_agreedSlot)} · See you at the table',
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
  final void Function(DateTime slot) onSubmit;
  @override
  State<_ProposeSheet> createState() => _ProposeSheetState();
}

class _ProposeSheetState extends State<_ProposeSheet> {
  static const Color _green = Color(0xFF4CAF50);
  DateTime? _selectedDate;
  String? _selectedTime; // "HH:mm"
  bool _showNextMonth = false;

  static const _timeSlots = [
    '08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30',
    '12:00','12:30','13:00','13:30','14:00','14:30','15:00','15:30',
    '16:00','16:30','17:00','17:30','18:00','18:30','19:00','19:30',
    '20:00','20:30','21:00','21:30','22:00','22:30','23:00','23:30',
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month + 2, now.day),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate == null
        ? 'Tap to pick a date'
        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Propose a slot', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text('Date', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedDate != null ? _green : const Color(0xFFE0E0E0)),
              ),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: _selectedDate != null ? _green : const Color(0xFF9E9E9E)),
                const SizedBox(width: 8),
                Text(dateStr, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Time (30-min precision)', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _timeSlots.map((t) {
              final sel = _selectedTime == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? _green : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? _green : Colors.transparent),
                  ),
                  child: Text(t, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF424242))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTime != null) ? () {
                final parts = _selectedTime!.split(':');
                widget.onSubmit(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, int.parse(parts[0]), int.parse(parts[1])));
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green, disabledBackgroundColor: const Color(0xFFC8E6C9),
                foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
              child: Text('Send Proposal', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
