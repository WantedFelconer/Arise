import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppPhase { auth, onboarding, main }

class NavigationState {
  final AppPhase phase;
  final String activeTab;
  final String? overlay;
  final bool showLevelUp;
  final bool showPenalty;

  const NavigationState({
    this.phase = AppPhase.auth,
    this.activeTab = 'home',
    this.overlay,
    this.showLevelUp = false,
    this.showPenalty = false,
  });

  NavigationState copyWith({
    AppPhase? phase,
    String? activeTab,
    String? overlay,
    bool clearOverlay = false,
    bool? showLevelUp,
    bool? showPenalty,
  }) {
    return NavigationState(
      phase: phase ?? this.phase,
      activeTab: activeTab ?? this.activeTab,
      overlay: clearOverlay ? null : (overlay ?? this.overlay),
      showLevelUp: showLevelUp ?? this.showLevelUp,
      showPenalty: showPenalty ?? this.showPenalty,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setPhase(AppPhase phase) {
    state = state.copyWith(phase: phase);
  }

  void navigateTo(String screen) {
    if (['home', 'quests', 'status', 'journal', 'roadmap'].contains(screen)) {
      state = state.copyWith(
        activeTab: screen,
        clearOverlay: true,
      );
    } else {
      state = state.copyWith(overlay: screen);
    }
  }

  void closeOverlay() {
    state = state.copyWith(clearOverlay: true);
  }

  void setShowLevelUp(bool value) {
    state = state.copyWith(showLevelUp: value);
  }

  void setShowPenalty(bool value) {
    state = state.copyWith(showPenalty: value);
  }

  void completeAuth() {
    state = state.copyWith(phase: AppPhase.onboarding);
  }

  void completeOnboarding() {
    state = state.copyWith(
      phase: AppPhase.main,
      showLevelUp: true,
    );
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
