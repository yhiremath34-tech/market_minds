enum TransactionType { buy, sell }

class PortfolioHolding {
  final String symbol;
  final String name;
  final int quantity;
  final double averageBuyPrice;
  final double currentPrice;

  const PortfolioHolding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
  });

  double get totalInvested => quantity * averageBuyPrice;
  double get currentMarketValue => quantity * currentPrice;
  double get unrealizedPnL => currentMarketValue - totalInvested;
  double get returnPercentage => totalInvested > 0 ? (unrealizedPnL / totalInvested) * 100 : 0.0;

  PortfolioHolding copyWith({
    String? symbol,
    String? name,
    int? quantity,
    double? averageBuyPrice,
    double? currentPrice,
  }) {
    return PortfolioHolding(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
      'currentPrice': currentPrice,
    };
  }

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
    );
  }
}

class TradeTransaction {
  final String transactionId;
  final String userId;
  final String portfolioId;
  final String symbol;
  final String assetName;
  final int quantity;
  final double price;
  final double totalValue;
  final DateTime timestamp;
  final TransactionType type;

  const TradeTransaction({
    required this.transactionId,
    required this.userId,
    required this.portfolioId,
    required this.symbol,
    required this.assetName,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'portfolioId': portfolioId,
      'symbol': symbol,
      'assetName': assetName,
      'quantity': quantity,
      'price': price,
      'totalValue': totalValue,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory TradeTransaction.fromJson(Map<String, dynamic> json) {
    return TradeTransaction(
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      portfolioId: json['portfolioId'] as String,
      symbol: json['symbol'] as String,
      assetName: json['assetName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] == 'buy' ? TransactionType.buy : TransactionType.sell,
    );
  }
}

class VirtualPortfolio {
  final String portfolioId;
  final String userId;
  final double cashBalance;
  final List<PortfolioHolding> holdings;
  final double realizedPnL;
  final DateTime updatedAt;

  const VirtualPortfolio({
    required this.portfolioId,
    required this.userId,
    required this.cashBalance,
    required this.holdings,
    this.realizedPnL = 0.0,
    required this.updatedAt,
  });

  double get totalHoldingsValue =>
      holdings.fold(0.0, (sum, item) => sum + item.currentMarketValue);

  double get totalInvested =>
      holdings.fold(0.0, (sum, item) => sum + item.totalInvested);

  double get totalUnrealizedPnL => totalHoldingsValue - totalInvested;

  double get totalPortfolioValue => cashBalance + totalHoldingsValue;

  double get totalPnL => totalUnrealizedPnL + realizedPnL;

  double get totalReturnPercentage {
    // Relative to initial capital ($10,000)
    const initialCapital = 10000.0;
    return ((totalPortfolioValue - initialCapital) / initialCapital) * 100;
  }

  VirtualPortfolio copyWith({
    String? portfolioId,
    String? userId,
    double? cashBalance,
    List<PortfolioHolding>? holdings,
    double? realizedPnL,
    DateTime? updatedAt,
  }) {
    return VirtualPortfolio(
      portfolioId: portfolioId ?? this.portfolioId,
      userId: userId ?? this.userId,
      cashBalance: cashBalance ?? this.cashBalance,
      holdings: holdings ?? this.holdings,
      realizedPnL: realizedPnL ?? this.realizedPnL,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
