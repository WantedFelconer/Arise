import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/arise_back_button.dart';
import '../../../../core/design_system/components/arise_pressable.dart';
import '../../../../core/design_system/components/decrypt_text.dart';
import '../../../../core/design_system/components/diamond_divider.dart';
import '../../../../core/design_system/components/glass_card.dart';
import '../../../../core/design_system/components/ornate_panel.dart';
import '../../../../core/design_system/components/pressable_card.dart';
import '../../../../core/design_system/components/uplink_chip.dart';

class AICoachScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AICoachScreen({super.key, required this.onBack});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final List<Map<String, String>> _messages = [
    {
      'from': 'ai',
      'text': 'UPLINK ESTABLISHED. I am the System. Your growth is my directive. Today\'s analysis is ready. You\'ve completed 62% of your weekly objectives — strong, but your Vitality stack is underperforming. Shall I recalibrate your quest load?',
    },
    {
      'from': 'user',
      'text': 'Yes. Plan my week around shipping the app.',
    },
  ];

  final _controller = TextEditingController();
  bool _isThinking = false;
  bool _planVisible = false;
  bool _planAccepted = false;

  static const actionChips = [
    '[ DEPLOY QUESTS ]', '[ PLAN MY WEEK ]', '[ ANALYZE MY STATS ]', '[ MOTIVATE ME ]', '[ ADJUST DIFFICULTY ]'
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'from': 'user', 'text': text.trim()});
      _controller.clear();
      _isThinking = true;
    });

    final isPlanReq = text.toLowerCase().contains('plan') || text.toLowerCase().contains('week');

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'from': 'ai',
            'text': isPlanReq
                ? 'Acknowledged. Processing optimal quest allocation based on your chronotype, streak data, and deadline proximity. Tactical briefing incoming...'
                : 'Understood, Hunter. The System has processed your directive. Your next objective has been recalibrated. Push forward.',
          });
          _isThinking = false;
        });

        if (isPlanReq) {
          Timer(const Duration(milliseconds: 2000), () {
            if (mounted) setState(() => _planVisible = true);
          });
        }
      }
    });
  }

  void _acceptPlan() {
    setState(() {
      _planAccepted = true;
      _planVisible = false;
      _messages.add({
        'from': 'ai',
        'text': 'QUEST TREE DEPLOYED. Five objectives locked into your registry. Daily vitality stack is running. The week belongs to you, Hunter. Do not squander it.',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidEdge,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AriseBackButton(onPressed: widget.onBack),
                  Column(
                    children: [
                      Text('[ SYSTEM AI ]', style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                      Text('AI COACH', style: AppTypography.orbitron(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  const UplinkChip(stable: true),
                ],
              ),
            ),

            // Orb Avatar
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manaCyan.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.manaCyan, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.manaCyan, blurRadius: 24)],
                ),
                alignment: Alignment.center,
                child: const Text('◈', style: TextStyle(fontSize: 24, color: AppColors.manaCyan)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isThinking ? '[ PROCESSING... ]' : (_planAccepted ? '[ QUEST TREE DEPLOYED ]' : '[ SYSTEM ONLINE ]'),
              style: AppTypography.monoStat(fontSize: 9, color: AppColors.manaCyan),
            ),
            const SizedBox(height: 12),

            // Chat Scroll
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length + (_planVisible && !_planAccepted ? 1 : 0),
                itemBuilder: (context, idx) {
                  if (idx < _messages.length) {
                    final msg = _messages[idx];
                    final isAi = msg['from'] == 'ai';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          if (isAi)
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.manaCyan.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: const Text('◈', style: TextStyle(fontSize: 12, color: AppColors.manaCyan)),
                            ),
                          Flexible(
                            child: GlassCard(
                              borderColor: isAi ? AppColors.manaCyan.withValues(alpha: 0.2) : AppColors.terminalGreen.withValues(alpha: 0.2),
                              padding: const EdgeInsets.all(12),
                              child: isAi
                                  ? DecryptText(text: msg['text']!, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.textPrimary))
                                  : Text(msg['text']!, style: AppTypography.rajdhani(fontSize: 13, color: AppColors.terminalGreen)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tactical Briefing Plan Card
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: OrnatePanel(
                      cornerSize: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('[ TACTICAL BRIEF — WEEK PLAN ]', style: AppTypography.monoStat(fontSize: 9, color: AppColors.textSecondary)),
                          Text('OPTIMAL QUEST SEQUENCE', style: AppTypography.orbitron(fontSize: 12, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          _PlanRow(rank: 'S', title: 'FINALIZE CORE FEATURES', exp: 400, time: 'MON–WED'),
                          _PlanRow(rank: 'A', title: 'QA & BUG CRUSHING', exp: 250, time: 'THU'),
                          _PlanRow(rank: 'A', title: 'LAUNCH & MARKETING PUSH', exp: 300, time: 'FRI'),
                          const DiamondDivider(),
                          Row(
                            children: [
                              Expanded(
                                child: PressableCard(
                                  onTap: () => setState(() => _planVisible = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('EDIT', style: AppTypography.orbitron(fontSize: 9, color: AppColors.textSecondary)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PressableCard(
                                  onTap: _acceptPlan,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Color(0x663EE6F5), blurRadius: 16)],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('ACCEPT & DEPLOY', style: AppTypography.orbitron(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: actionChips.length,
                itemBuilder: (context, idx) {
                  final chip = actionChips[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: PressableCard(
                      onTap: () => _sendMessage(chip.replaceAll(RegExp(r'[\[\]]'), '').trim()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.glassPanel,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                        ),
                        child: Text(chip, style: AppTypography.monoStat(fontSize: 9, color: AppColors.manaCyan)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Input Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTypography.monoStat(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '> Enter directive...',
                          hintStyle: TextStyle(color: AppColors.textDisabled),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    ArisePressable(
                      onTap: () => _sendMessage(_controller.text),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_upward, color: AppColors.manaCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String rank;
  final String title;
  final int exp;
  final String time;

  const _PlanRow({required this.rank, required this.title, required this.exp, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(rank, style: AppTypography.orbitron(fontSize: 12, color: AppColors.expFrom)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.orbitron(fontSize: 10, color: AppColors.textPrimary)),
                  Text(time, style: AppTypography.monoStat(fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text('+$exp', style: AppTypography.monoStat(fontSize: 9, color: AppColors.expFrom)),
          ],
        ),
      ),
    );
  }
}
