import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import '../core/design_system/components/arise_back_button.dart';
import '../core/presentation/widgets/phone_shell.dart';
import '../core/presentation/widgets/top_status_bar.dart';
import '../core/presentation/widgets/nav_bar.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/player_provider.dart';

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
import '../features/auth/application/auth_notifier.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

class AriseApp extends ConsumerStatefulWidget {
  const AriseApp({super.key});

  @override
  ConsumerState<AriseApp> createState() => _AriseAppState();
}

class _AriseAppState extends ConsumerState<AriseApp> {
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

    // Asynchronously restore session on launch without blocking UI render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARISE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PhoneShell(
        child: PhaseContentRouter(),
      ),
    );
  }
}

class PhaseContentRouter extends ConsumerWidget {
  const PhaseContentRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(navigationProvider.select((s) => s.phase));

    if (phase == AppPhase.auth) {
      return AuthScreen(
        onComplete: () => ref.read(navigationProvider.notifier).completeAuth(),
      );
    }

    if (phase == AppPhase.onboarding) {
      return OnboardingScreen(
        onComplete: (setupData) {
          ref.read(playerProvider.notifier).setPlayerData(setupData);
          ref.read(navigationProvider.notifier).completeOnboarding();
        },
      );
    }

    return const MainAppView();
  }
}

class MainAppView extends ConsumerWidget {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(navigationProvider.select((s) => s.activeTab));
    final overlay = ref.watch(navigationProvider.select((s) => s.overlay));
    final showLevelUp = ref.watch(navigationProvider.select((s) => s.showLevelUp));
    final showPenalty = ref.watch(navigationProvider.select((s) => s.showPenalty));

    final showTopBar = ['home', 'quests', 'status', 'journal', 'roadmap'].contains(activeTab);
    final navNotifier = ref.read(navigationProvider.notifier);
    final isBaseVisible = overlay == null && !showLevelUp && !showPenalty;

    return Stack(
      children: [
        // Main Tab content
        if (isBaseVisible) ...[
          if (activeTab == 'home')
            HomeScreen(
              onEnterFocus: () => navNotifier.navigateTo('focus'),
              onNavigate: navNotifier.navigateTo,
            ),
          if (activeTab == 'quests') const QuestListScreen(),
          if (activeTab == 'status')
            StatusScreen(
              onStatUp: (stat) => ref.read(playerProvider.notifier).incrementStat(stat),
            ),
          if (activeTab == 'journal') const JournalScreen(),
          if (activeTab == 'roadmap') const RoadmapScreen(),
        ],

        // Persistent Top Bar
        if (showTopBar && isBaseVisible)
          TopStatusBar(
            uplinkStable: true,
            onManaCoreClick: () => navNotifier.navigateTo('manacore'),
            onNotificationsClick: () => navNotifier.navigateTo('notifications'),
            onSettingsClick: () => navNotifier.navigateTo('settings'),
            onAiCoachClick: () => navNotifier.navigateTo('aicoach'),
            onPenaltyClick: () => navNotifier.setShowPenalty(true),
          ),

        // Persistent Nav Bar
        if (isBaseVisible)
          NavBar(
            activeTab: activeTab,
            onNavigate: navNotifier.navigateTo,
          ),

        // Overlays
        if (overlay == 'focus')
          FocusGateScreen(
            onExit: (success) => navNotifier.closeOverlay(),
          ),
        if (overlay == 'armory')
          _OverlayWrapper(
            onBack: navNotifier.closeOverlay,
            child: Consumer(
              builder: (context, ref, _) {
                final gold = ref.watch(playerProvider.select((p) => p.gold));
                return ArmoryScreen(gold: gold);
              },
            ),
          ),
        if (overlay == 'manacore')
          ManaCoreScreen(onBack: navNotifier.closeOverlay),
        if (overlay == 'guild')
          _OverlayWrapper(onBack: navNotifier.closeOverlay, child: const GuildScreen()),
        if (overlay == 'calendar')
          _OverlayWrapper(onBack: navNotifier.closeOverlay, child: const CalendarScreen()),
        if (overlay == 'settings')
          _OverlayWrapper(onBack: navNotifier.closeOverlay, child: SettingsScreen(onClose: navNotifier.closeOverlay)),
        if (overlay == 'aicoach')
          AICoachScreen(onBack: navNotifier.closeOverlay),
        if (overlay == 'boss')
          BossDetailScreen(
            onBack: navNotifier.closeOverlay,
            onFocusMode: () => navNotifier.navigateTo('focus'),
          ),
        if (overlay == 'notifications')
          NotificationsScreen(onBack: navNotifier.closeOverlay),

        // Popups
        if (showPenalty)
          PenaltyScreen(onAcknowledge: () => navNotifier.setShowPenalty(false)),
        if (showLevelUp)
          Consumer(
            builder: (context, ref, _) {
              final level = ref.watch(playerProvider.select((p) => p.level));
              return LevelUpScreen(
                oldLevel: level - 1,
                newLevel: level,
                onContinue: () => navNotifier.setShowLevelUp(false),
              );
            },
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
