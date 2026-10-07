enum TimeFrame {
  oneDay('1D'),
  oneWeek('1W'),
  oneMonth('1M'),
  threeMonths('3M'),
  oneYear('1Y');

  final String label;
  const TimeFrame(this.label);
}

enum AssetCategory {
  all('All'),
  stocks('Stocks'),
  etfs('ETFs'),
  mutualFunds('Mutual Funds'),
  indices('Indices');

  final String label;
  const AssetCategory(this.label);
}

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close >= open;
}

class StockQuote {
  final String symbol;
  final String name;
  final AssetCategory category;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double volume;
  final double marketCap;
  final double peRatio;
  final String description;
  final List<double> sparkline;
  final bool isWatchlisted;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.category,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.description,
    required this.sparkline,
    this.isWatchlisted = false,
  });

  StockQuote copyWith({
    String? symbol,
    String? name,
    AssetCategory? category,
    double? price,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? volume,
    double? marketCap,
    double? peRatio,
    String? description,
    List<double>? sparkline,
    bool? isWatchlisted,
  }) {
    return StockQuote(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      volume: volume ?? this.volume,
      marketCap: marketCap ?? this.marketCap,
      peRatio: peRatio ?? this.peRatio,
      description: description ?? this.description,
      sparkline: sparkline ?? this.sparkline,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    );
  }
}

class MarketStatus {
  final bool isOpen;
  final String session;
  final String message;

  const MarketStatus({
    required this.isOpen,
    required this.session,
    required this.message,
  });
}
