import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import 'auth/domain/user_model.dart';
import 'gamification/domain/achievement_models.dart';
import 'learning/data/learning_curriculum.dart';
import 'market_data/domain/market_models.dart';
import 'market_data/services/mock_market_data_provider.dart';
import 'paper_trading/domain/trading_models.dart';
import 'paper_trading/services/virtual_portfolio_service.dart';
import 'profile/domain/certificate_model.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null; // Initialized in main.dart
});

// Market Data Provider
final marketDataProvider = Provider<MockMarketDataProvider>((ref) {
  return MockMarketDataProvider();
});

// App State Container
class AppState {
  final UserModel? user;
  final bool isAgeVerified;
  final bool isOnboardingCompleted;
  final VirtualPortfolio portfolio;
  final List<TradeTransaction> transactions;
  final List<StockQuote> quotes;
  final Set<String> watchlist;
  final Set<String> completedLessons;
  final List<Achievement> achievements;
  final List<FinancialCertificate> certificates;
  final bool isOffline;
  final bool isLoading;
  final String? errorMessage;

  const AppState({
    required this.user,
    required this.isAgeVerified,
    required this.isOnboardingCompleted,
    required this.portfolio,
    required this.transactions,
    required this.quotes,
    required this.watchlist,
    required this.completedLessons,
    required this.achievements,
    required this.certificates,
    this.isOffline = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AppState copyWith({
    UserModel? user,
    bool? isAgeVerified,
    bool? isOnboardingCompleted,
    VirtualPortfolio? portfolio,
    List<TradeTransaction>? transactions,
    List<StockQuote>? quotes,
    Set<String>? watchlist,
    Set<String>? completedLessons,
    List<Achievement>? achievements,
    List<FinancialCertificate>? certificates,
    bool? isOffline,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppState(
      user: user ?? this.user,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      portfolio: portfolio ?? this.portfolio,
      transactions: transactions ?? this.transactions,
      quotes: quotes ?? this.quotes,
      watchlist: watchlist ?? this.watchlist,
      completedLessons: completedLessons ?? this.completedLessons,
      achievements: achievements ?? this.achievements,
      certificates: certificates ?? this.certificates,
      isOffline: isOffline ?? this.isOffline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// App State Notifier
class AppStateNotifier extends Notifier<AppState> {
  late MockMarketDataProvider _marketData;
  late VirtualPortfolioService _portfolioService;
  SharedPreferences? _prefs;

  @override
  AppState build() {
    _marketData = ref.watch(marketDataProvider);
    _prefs = ref.watch(sharedPreferencesProvider);
    _portfolioService = VirtualPortfolioService(prefs: _prefs);

    // Initial default state
    final initialState = AppState(
      user: UserModel.createDefault(),
      isAgeVerified: false,
      isOnboardingCompleted: false,
      portfolio: VirtualPortfolio(
        portfolioId: 'port_default',
        userId: 'default_user',
        cashBalance: AppConstants.initialVirtualCash,
        holdings: const [],
        realizedPnL: 0.0,
        updatedAt: DateTime.now(),
      ),
      transactions: const [],
      quotes: const [],
      watchlist: const {'AAPL', 'NVDA', 'SPY'},
      completedLessons: const {},
      achievements: Achievement.getInitialAchievements(),
      certificates: const [],
    );

    // Load persisted state asynchronously
    Future.microtask(() => _init());

    return initialState;
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _portfolioService = VirtualPortfolioService(prefs: _prefs);

    // Load persisted state if SharedPreferences is active
    bool isAgeVerified = false;
    bool isOnboardingCompleted = false;
    Set<String> completedLessons = {};
    UserModel user = UserModel.createDefault();

    final prefs = _prefs;
    if (prefs != null) {
      isAgeVerified = prefs.getBool(AppConstants.keyAgeVerified) ?? false;
      isOnboardingCompleted = prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
      final savedLessons = prefs.getStringList(AppConstants.keyCompletedLessons);
      if (savedLessons != null) {
        completedLessons = savedLessons.toSet();
      }
      final savedXp = prefs.getInt(AppConstants.keyUserXP);
      if (savedXp != null) {
        user = user.copyWith(xp: savedXp, rank: AppConstants.getRankForXp(savedXp).name);
      }
    }

    final quotes = await _marketData.getAllQuotes();
    _portfolioService.updatePrices({for (var q in quotes) q.symbol: q.price});

    state = state.copyWith(
      user: user,
      isAgeVerified: isAgeVerified,
      isOnboardingCompleted: isOnboardingCompleted,
      portfolio: _portfolioService.portfolio,
      transactions: _portfolioService.transactions,
      quotes: quotes,
      completedLessons: completedLessons,
      isLoading: false,
    );
  }

  // Age Verification
  Future<void> verifyAge(bool isEligible) async {
    await _prefs?.setBool(AppConstants.keyAgeVerified, isEligible);
    state = state.copyWith(isAgeVerified: isEligible);
  }

  // Complete Onboarding
  Future<void> completeOnboarding() async {
    await _prefs?.setBool(AppConstants.keyOnboardingComplete, true);
    state = state.copyWith(isOnboardingCompleted: true);
  }

  // Login / Register / Guest Demo
  void login({required String email, required String displayName}) {
    final updated = state.user?.copyWith(
          email: email,
          displayName: displayName,
          isGuest: false,
        ) ??
        UserModel.createDefault(name: displayName, email: email, isGuest: false);
    state = state.copyWith(user: updated);
  }

  void logout() {
    state = state.copyWith(
      user: UserModel.createDefault(name: 'Guest Trader', email: '', isGuest: true),
    );
  }

  // Watchlist Toggle
  void toggleWatchlist(String symbol) {
    final updated = Set<String>.from(state.watchlist);
    if (updated.contains(symbol)) {
      updated.remove(symbol);
    } else {
      updated.add(symbol);
    }
    state = state.copyWith(watchlist: updated);
  }

  // Trade Execution: BUY
  Future<TradeExecutionResult> buyStock({
    required String symbol,
    required String assetName,
    required int quantity,
    required double currentPrice,
  }) async {
    final result = await _portfolioService.executeBuy(
      symbol: symbol,
      assetName: assetName,
      quantity: quantity,
      currentPrice: currentPrice,
    );

    if (result.success) {
      // Check first trade achievement
      _unlockAchievement('first_trade');
      // Award XP for executing a disciplined trade
      addXp(25);

      state = state.copyWith(
        portfolio: _portfolioService.portfolio,
        transactions: _portfolioService.transactions,
      );
    }
    return result;
  }

  // Trade Execution: SELL
  Future<TradeExecutionResult> sellStock({
    required String symbol,
    required int quantity,
    required double currentPrice,
  }) async {
    final result = await _portfolioService.executeSell(
      symbol: symbol,
      quantity: quantity,
      currentPrice: currentPrice,
    );

    if (result.success) {
      addXp(20);
      state = state.copyWith(
        portfolio: _portfolioService.portfolio,
        transactions: _portfolioService.transactions,
      );
    }
    return result;
  }

  // Reset Virtual Portfolio
  Future<void> resetPortfolio() async {
    await _portfolioService.resetPortfolio();
    state = state.copyWith(
      portfolio: _portfolioService.portfolio,
      transactions: _portfolioService.transactions,
    );
  }

  // Gamification: Add XP & Coins
  void addXp(int amount) {
    if (state.user == null) return;
    final newXp = state.user!.xp + amount;
    final newRank = AppConstants.getRankForXp(newXp);
    final updated = state.user!.copyWith(
      xp: newXp,
      rank: newRank.name,
      level: (newXp ~/ 300) + 1,
    );
    _prefs?.setInt(AppConstants.keyUserXP, newXp);
    state = state.copyWith(user: updated);
  }

  void addCoins(int amount) {
    if (state.user == null) return;
    final updated = state.user!.copyWith(coins: state.user!.coins + amount);
    state = state.copyWith(user: updated);
  }

  // Learning Completion
  Future<void> completeLesson(String lessonId, int xpReward, int coinReward) async {
    final updatedSet = Set<String>.from(state.completedLessons)..add(lessonId);
    await _prefs?.setStringList(AppConstants.keyCompletedLessons, updatedSet.toList());

    addXp(xpReward);
    addCoins(coinReward);

    _unlockAchievement('first_lesson');

    // Check if all 10 levels completed
    if (updatedSet.length >= LearningCurriculum.levels.length) {
      _unlockAchievement('market_master');
      // Generate Graduation Certificate
      final cert = FinancialCertificate.createGraduation(
        studentName: state.user?.displayName ?? 'Young Investor',
      );
      state = state.copyWith(
        completedLessons: updatedSet,
        certificates: [...state.certificates, cert],
      );
    } else {
      state = state.copyWith(completedLessons: updatedSet);
    }
  }

  void _unlockAchievement(String achievementId) {
    final updated = state.achievements.map((a) {
      if (a.id == achievementId && !a.isUnlocked) {
        addXp(a.xpReward);
        addCoins(a.coinReward);
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();
    state = state.copyWith(achievements: updated);
  }

  void toggleOffline(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

