import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/trading_models.dart';

class TradeExecutionResult {
  final bool success;
  final String message;
  final TradeTransaction? transaction;

  const TradeExecutionResult({
    required this.success,
    required this.message,
    this.transaction,
  });
}

class VirtualPortfolioService {
  final SharedPreferences? _prefs;
  VirtualPortfolio _portfolio;
  final List<TradeTransaction> _transactions = [];

  VirtualPortfolioService({SharedPreferences? prefs, String userId = 'default_user'})
      // ignore: prefer_initializing_formals
      : _prefs = prefs,
        _portfolio = VirtualPortfolio(
          portfolioId: 'port_$userId',
          userId: userId,
          cashBalance: AppConstants.initialVirtualCash,
          holdings: [],
          realizedPnL: 0.0,
          updatedAt: DateTime.now(),
        ) {
    _loadState();
  }

  VirtualPortfolio get portfolio => _portfolio;
  List<TradeTransaction> get transactions => List.unmodifiable(_transactions);

  void _loadState() {
    if (_prefs == null) return;
    try {
      final portfolioJsonStr = _prefs.getString(AppConstants.keyPortfolio);
      if (portfolioJsonStr != null) {
        final map = jsonDecode(portfolioJsonStr) as Map<String, dynamic>;
        final holdingsList = (map['holdings'] as List<dynamic>? ?? [])
            .map((h) => PortfolioHolding.fromJson(h as Map<String, dynamic>))
            .toList();

        _portfolio = VirtualPortfolio(
          portfolioId: map['portfolioId'] as String? ?? 'port_1',
          userId: map['userId'] as String? ?? 'default_user',
          cashBalance: (map['cashBalance'] as num?)?.toDouble() ?? AppConstants.initialVirtualCash,
          holdings: holdingsList,
          realizedPnL: (map['realizedPnL'] as num?)?.toDouble() ?? 0.0,
          updatedAt: DateTime.now(),
        );
      }

      final txJsonStr = _prefs.getString(AppConstants.keyTransactions);
      if (txJsonStr != null) {
        final list = jsonDecode(txJsonStr) as List<dynamic>;
        _transactions.clear();
        _transactions.addAll(
          list.map((t) => TradeTransaction.fromJson(t as Map<String, dynamic>)),
        );
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    if (_prefs == null) return;
    try {
      final portfolioMap = {
        'portfolioId': _portfolio.portfolioId,
        'userId': _portfolio.userId,
        'cashBalance': _portfolio.cashBalance,
        'realizedPnL': _portfolio.realizedPnL,
        'holdings': _portfolio.holdings.map((h) => h.toJson()).toList(),
      };
      await _prefs.setString(AppConstants.keyPortfolio, jsonEncode(portfolioMap));

      final txList = _transactions.map((t) => t.toJson()).toList();
      await _prefs.setString(AppConstants.keyTransactions, jsonEncode(txList));
    } catch (_) {}
  }

  /// Updates current live prices across all active holdings
  void updatePrices(Map<String, double> livePrices) {
    final updatedHoldings = _portfolio.holdings.map((h) {
      final latest = livePrices[h.symbol] ?? h.currentPrice;
      return h.copyWith(currentPrice: latest);
    }).toList();

    _portfolio = _portfolio.copyWith(
      holdings: updatedHoldings,
      updatedAt: DateTime.now(),
    );
  }

  /// Executes virtual BUY order
  Future<TradeExecutionResult> executeBuy({
    required String symbol,
    required String assetName,
    required int quantity,
    required double currentPrice,
  }) async {
    if (quantity <= 0) {
      return const TradeExecutionResult(
        success: false,
        message: 'Order quantity must be at least 1 share.',
      );
    }

    final totalCost = quantity * currentPrice;
    if (totalCost > _portfolio.cashBalance) {
      return TradeExecutionResult(
        success: false,
        message:
            'Insufficient virtual funds. Required \$${totalCost.toStringAsFixed(2)}, but you have \$${_portfolio.cashBalance.toStringAsFixed(2)} available.',
      );
    }

    // Update or add holding
    final List<PortfolioHolding> updatedHoldings = List.from(_portfolio.holdings);
    final existingIndex = updatedHoldings.indexWhere((h) => h.symbol.toUpperCase() == symbol.toUpperCase());

    if (existingIndex >= 0) {
      final existing = updatedHoldings[existingIndex];
      final newTotalQty = existing.quantity + quantity;
      final newAverageBuyPrice =
          ((existing.quantity * existing.averageBuyPrice) + totalCost) / newTotalQty;

      updatedHoldings[existingIndex] = existing.copyWith(
        quantity: newTotalQty,
        averageBuyPrice: double.parse(newAverageBuyPrice.toStringAsFixed(2)),
        currentPrice: currentPrice,
      );
    } else {
      updatedHoldings.add(
        PortfolioHolding(
          symbol: symbol,
          name: assetName,
          quantity: quantity,
          averageBuyPrice: currentPrice,
          currentPrice: currentPrice,
        ),
      );
    }

    final newCashBalance = _portfolio.cashBalance - totalCost;
    _portfolio = _portfolio.copyWith(
      cashBalance: double.parse(newCashBalance.toStringAsFixed(2)),
      holdings: updatedHoldings,
      updatedAt: DateTime.now(),
    );

    final transaction = TradeTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: _portfolio.userId,
      portfolioId: _portfolio.portfolioId,
      symbol: symbol,
      assetName: assetName,
      quantity: quantity,
      price: currentPrice,
      totalValue: totalCost,
      timestamp: DateTime.now(),
      type: TransactionType.buy,
    );

    _transactions.insert(0, transaction);
    await _saveState();

    return TradeExecutionResult(
      success: true,
      message: 'Successfully bought $quantity share(s) of $symbol for \$${totalCost.toStringAsFixed(2)}.',
      transaction: transaction,
    );
  }

  /// Executes virtual SELL order
  Future<TradeExecutionResult> executeSell({
    required String symbol,
    required int quantity,
    required double currentPrice,
  }) async {
    if (quantity <= 0) {
      return const TradeExecutionResult(
        success: false,
        message: 'Order quantity must be at least 1 share.',
      );
    }

    final List<PortfolioHolding> updatedHoldings = List.from(_portfolio.holdings);
    final existingIndex = updatedHoldings.indexWhere((h) => h.symbol.toUpperCase() == symbol.toUpperCase());

    if (existingIndex < 0) {
      return TradeExecutionResult(
        success: false,
        message: 'You do not own any shares of $symbol.',
      );
    }

    final existing = updatedHoldings[existingIndex];
    if (quantity > existing.quantity) {
      return TradeExecutionResult(
        success: false,
        message:
            'Insufficient shares. You requested to sell $quantity shares, but you only hold ${existing.quantity}.',
      );
    }

    final totalProceeds = quantity * currentPrice;
    final realizedGain = (currentPrice - existing.averageBuyPrice) * quantity;

    if (quantity == existing.quantity) {
      updatedHoldings.removeAt(existingIndex);
    } else {
      updatedHoldings[existingIndex] = existing.copyWith(
        quantity: existing.quantity - quantity,
        currentPrice: currentPrice,
      );
    }

    final newCashBalance = _portfolio.cashBalance + totalProceeds;
    final newRealizedPnL = _portfolio.realizedPnL + realizedGain;

    _portfolio = _portfolio.copyWith(
      cashBalance: double.parse(newCashBalance.toStringAsFixed(2)),
      holdings: updatedHoldings,
      realizedPnL: double.parse(newRealizedPnL.toStringAsFixed(2)),
      updatedAt: DateTime.now(),
    );

    final transaction = TradeTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: _portfolio.userId,
      portfolioId: _portfolio.portfolioId,
      symbol: symbol,
      assetName: existing.name,
      quantity: quantity,
      price: currentPrice,
      totalValue: totalProceeds,
      timestamp: DateTime.now(),
      type: TransactionType.sell,
    );

    _transactions.insert(0, transaction);
    await _saveState();

    return TradeExecutionResult(
      success: true,
      message: 'Successfully sold $quantity share(s) of $symbol for \$${totalProceeds.toStringAsFixed(2)}.',
      transaction: transaction,
    );
  }

  /// Resets virtual portfolio to initial $10,000 cash balance
  Future<void> resetPortfolio() async {
    _portfolio = VirtualPortfolio(
      portfolioId: _portfolio.portfolioId,
      userId: _portfolio.userId,
      cashBalance: AppConstants.initialVirtualCash,
      holdings: [],
      realizedPnL: 0.0,
      updatedAt: DateTime.now(),
    );
    _transactions.clear();
    await _saveState();
  }
}
