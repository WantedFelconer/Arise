import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';
import '../shared/models/player_data.dart';
import '../core/design_system/components/arise_back_button.dart';
import '../core/presentation/widgets/phone_shell.dart';
import '../core/presentation/widgets/top_status_bar.dart';
import '../core/presentation/widgets/nav_bar.dart';

// Screens
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/quests/presentation/screens/quest_list_screen.dart';
import '../features/character/presentation/screens/status_screen.dart';
import '../features/journal/presentation/screens/journal_screen.dart';
import '../features/roadmap/presentation/screens/roadmap_screen.dart';
import '../features/gate/presentation/screens/focus_gate_screen.dart';
import '../features/penalty/presentation/screens/penalty_screen.dart';
import '../features/levelup/presentation/screens/levelup_screen.dart';
import '../features/armory/presentation/screens/armory_screen.dart';
import '../features/manacore/presentation/screens/mana_core_screen.dart';
import '../features/guild/presentation/screens/guild_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../features/boss/presentation/screens/boss_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

class AriseApp extends StatefulWidget {
  const AriseApp({super.key});

  @override
  State<AriseApp> createState() => _AriseAppState();
}

enum AppPhase { auth, onboarding, main }

class _AriseAppState extends State<AriseApp> {
  AppPhase _phase = AppPhase.auth;
  PlayerData _player = PlayerData.defaultPlayer;
  String _activeTab = 'home';
  String? _overlay;
  bool _showLevelUp = false;
  bool _showPenalty = false;

  void _handleAuthComplete() {
    setState(() => _phase = AppPhase.onboarding);
  }

  void _handleOnboardingComplete(PlayerData setup) {
    setState(() {
      _player = setup;
      _phase = AppPhase.main;
      _showLevelUp = true;
    });
  }

  void _handleStatUp(String stat) {
    if (_player.remainingPoints <= 0) return;
    setState(() {
      _player = _player.copyWith(
        remainingPoints: _player.remainingPoints - 1,
        str: stat == 'STR' ? _player.str + 1 : _player.str,
        agi: stat == 'AGI' ? _player.agi + 1 : _player.agi,
        vit: stat == 'VIT' ? _player.vit + 1 : _player.vit,
        intStat: stat == 'INT' ? _player.intStat + 1 : _player.intStat,
        per: stat == 'PER' ? _player.per + 1 : _player.per,
      );
    });
  }

  void _navigateTo(String screen) {
    if (['home', 'quests', 'status', 'journal', 'roadmap'].contains(screen)) {
      setState(() {
        _activeTab = screen;
        _overlay = null;
      });
    } else {
      setState(() => _overlay = screen);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF030712),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARISE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: PhoneShell(
        child: _buildPhaseContent(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    if (_phase == AppPhase.auth) {
      return AuthScreen(onComplete: _handleAuthComplete);
    }

    if (_phase == AppPhase.onboarding) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    // MAIN APP
    final showTopBar = ['home', 'quests', 'status', 'journal', 'roadmap'].contains(_activeTab);
    final topSafeArea = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Main Tab content
        if (_overlay == null && !_showLevelUp && !_showPenalty) ...[
          if (_activeTab == 'home')
            HomeScreen(
              player: _player,
              onEnterFocus: () => setState(() => _overlay = 'focus'),
              onNavigate: _navigateTo,
            ),
          if (_activeTab == 'quests') const QuestListScreen(),
          if (_activeTab == 'status') StatusScreen(player: _player, onStatUp: _handleStatUp),
          if (_activeTab == 'journal') const JournalScreen(),
          if (_activeTab == 'roadmap') const RoadmapScreen(),
        ],

        // Persistent Top Bar
        if (showTopBar && _overlay == null && !_showLevelUp && !_showPenalty)
          TopStatusBar(
            hp: _player.hp,
            maxHp: _player.maxHp,
            mp: _player.mp,
            maxMp: _player.maxMp,
            level: _player.level,
            streak: _player.streak,
            uplinkStable: true,
            onManaCoreClick: () => setState(() => _overlay = 'manacore'),
            onNotificationsClick: () => setState(() => _overlay = 'notifications'),
            onSettingsClick: () => setState(() => _overlay = 'settings'),
            onAiCoachClick: () => setState(() => _overlay = 'aicoach'),
            onPenaltyClick: () => setState(() => _showPenalty = true),
          ),

        // Persistent Nav Bar
        if (_overlay == null && !_showLevelUp && !_showPenalty)
          NavBar(
            activeTab: _activeTab,
            onNavigate: _navigateTo,
          ),

        // Overlays
        if (_overlay == 'focus')
          FocusGateScreen(
            onExit: (success) {
              setState(() => _overlay = null);
            },
          ),
        if (_overlay == 'armory')
          _OverlayWrapper(onBack: () => setState(() => _overlay = null), child: ArmoryScreen(gold: _player.gold)),
        if (_overlay == 'manacore')
          ManaCoreScreen(onBack: () => setState(() => _overlay = null)),
        if (_overlay == 'guild')
          _OverlayWrapper(onBack: () => setState(() => _overlay = null), child: const GuildScreen()),
        if (_overlay == 'calendar')
          _OverlayWrapper(onBack: () => setState(() => _overlay = null), child: const CalendarScreen()),
        if (_overlay == 'settings')
          _OverlayWrapper(onBack: () => setState(() => _overlay = null), child: SettingsScreen(onClose: () => setState(() => _overlay = null))),
        if (_overlay == 'aicoach')
          AICoachScreen(onBack: () => setState(() => _overlay = null)),
        if (_overlay == 'boss')
          BossDetailScreen(onBack: () => setState(() => _overlay = null), onFocusMode: () => setState(() => _overlay = 'focus')),
        if (_overlay == 'notifications')
          NotificationsScreen(onBack: () => setState(() => _overlay = null)),

        // Popups
        if (_showPenalty)
          PenaltyScreen(onAcknowledge: () => setState(() => _showPenalty = false)),
        if (_showLevelUp)
          LevelUpScreen(
            oldLevel: _player.level - 1,
            newLevel: _player.level,
            onContinue: () => setState(() => _showLevelUp = false),
          ),
      ],
    );
  }
}

class _OverlayWrapper extends StatelessWidget {
  final VoidCallback onBack;
  final Widget child;

  const _OverlayWrapper({required this.onBack, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030712),
      child: Stack(
        children: [
          child,
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.0,
            left: 16,
            child: AriseBackButton(onPressed: onBack),
          ),
        ],
      ),
    );
  }
}
