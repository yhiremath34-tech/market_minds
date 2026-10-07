import 'dart:math';
import '../domain/market_models.dart';
import 'market_data_provider.dart';

class MockMarketDataProvider implements MarketDataProvider {
  static final Random _rng = Random(42);

  // Seed asset database
  final List<StockQuote> _quotes = [
    const StockQuote(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      category: AssetCategory.stocks,
      price: 189.84,
      change: 2.45,
      changePercent: 1.31,
      open: 187.50,
      high: 190.20,
      low: 186.90,
      volume: 52400000,
      marketCap: 2950000000000,
      peRatio: 31.4,
      description: 'Designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and services.',
      sparkline: [184, 185, 184.5, 186, 187.2, 188.1, 189.84],
    ),
    const StockQuote(
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      category: AssetCategory.stocks,
      price: 128.60,
      change: 4.80,
      changePercent: 3.88,
      open: 124.00,
      high: 129.50,
      low: 123.80,
      volume: 89000000,
      marketCap: 3150000000000,
      peRatio: 48.2,
      description: 'Pioneer of GPU-accelerated computing and undisputed hardware backbone for modern Artificial Intelligence.',
      sparkline: [118, 120, 122.5, 121, 125, 127.4, 128.60],
    ),
    const StockQuote(
      symbol: 'TSLA',
      name: 'Tesla, Inc.',
      category: AssetCategory.stocks,
      price: 242.15,
      change: -3.75,
      changePercent: -1.52,
      open: 246.00,
      high: 247.30,
      low: 240.50,
      volume: 64200000,
      marketCap: 770000000000,
      peRatio: 64.8,
      description: 'Designs, develops, manufactures, and sells electric vehicles, energy generation and storage systems.',
      sparkline: [255, 252, 248, 245, 246, 243, 242.15],
    ),
    const StockQuote(
      symbol: 'MSFT',
      name: 'Microsoft Corporation',
      category: AssetCategory.stocks,
      price: 435.20,
      change: 1.85,
      changePercent: 0.43,
      open: 433.00,
      high: 436.50,
      low: 432.10,
      volume: 21300000,
      marketCap: 3230000000000,
      peRatio: 35.6,
      description: 'Develops and supports software, services, devices, and solutions including Azure cloud and Microsoft 365.',
      sparkline: [428, 430, 431, 432.5, 434, 433.8, 435.20],
    ),
    const StockQuote(
      symbol: 'AMZN',
      name: 'Amazon.com, Inc.',
      category: AssetCategory.stocks,
      price: 186.40,
      change: 2.10,
      changePercent: 1.14,
      open: 184.50,
      high: 187.20,
      low: 184.10,
      volume: 38400000,
      marketCap: 1940000000000,
      peRatio: 42.1,
      description: 'Focuses on retail, cloud computing via AWS, online advertising, digital streaming, and AI initiatives.',
      sparkline: [181, 182.5, 183, 185, 184.2, 185.8, 186.40],
    ),
    const StockQuote(
      symbol: 'SPY',
      name: 'SPDR S&P 500 ETF Trust',
      category: AssetCategory.etfs,
      price: 545.80,
      change: 3.20,
      changePercent: 0.59,
      open: 543.00,
      high: 546.50,
      low: 542.80,
      volume: 45000000,
      marketCap: 520000000000,
      peRatio: 26.2,
      description: 'Tracks the benchmark Standard & Poor 500 index comprising the 500 largest publicly traded American companies.',
      sparkline: [538, 540, 541.5, 543, 542.8, 544.5, 545.80],
    ),
    const StockQuote(
      symbol: 'QQQ',
      name: 'Invesco QQQ Trust (Nasdaq 100)',
      category: AssetCategory.etfs,
      price: 478.25,
      change: 5.10,
      changePercent: 1.08,
      open: 473.50,
      high: 479.40,
      low: 472.90,
      volume: 32000000,
      marketCap: 260000000000,
      peRatio: 30.5,
      description: 'Tracks the tech-heavy Nasdaq-100 Index, representing top global innovation leaders.',
      sparkline: [468, 470, 472, 474.5, 473, 476, 478.25],
    ),
    const StockQuote(
      symbol: 'GLD',
      name: 'SPDR Gold Shares ETF',
      category: AssetCategory.etfs,
      price: 218.40,
      change: -0.65,
      changePercent: -0.30,
      open: 219.00,
      high: 219.50,
      low: 217.90,
      volume: 6800000,
      marketCap: 64000000000,
      peRatio: 0,
      description: 'Provides investors with an innovative and cost-effective way to track physical gold bullion as an inflation hedge.',
      sparkline: [221, 220, 219.5, 219, 218.8, 218.9, 218.40],
    ),
    const StockQuote(
      symbol: 'NIFTYBEES',
      name: 'Nippon India Nifty 50 ETF',
      category: AssetCategory.etfs,
      price: 274.50,
      change: 1.80,
      changePercent: 0.66,
      open: 273.00,
      high: 275.20,
      low: 272.80,
      volume: 12000000,
      marketCap: 18500000000,
      peRatio: 22.8,
      description: 'Exchange-traded fund tracking the premier blue-chip benchmark index of the National Stock Exchange of India (NSE).',
      sparkline: [269, 270.5, 271, 272.5, 273, 273.8, 274.50],
    ),
    const StockQuote(
      symbol: 'VFINX',
      name: 'Vanguard 500 Index Fund',
      category: AssetCategory.mutualFunds,
      price: 498.15,
      change: 2.85,
      changePercent: 0.58,
      open: 495.50,
      high: 498.90,
      low: 495.00,
      volume: 15400000,
      marketCap: 450000000000,
      peRatio: 25.4,
      description: 'The original low-cost mutual fund created by Jack Bogle, providing diversified access to 500 large cap corporations.',
      sparkline: [490, 492, 494, 495, 496.2, 497.1, 498.15],
    ),
  ];

  @override
  Future<List<StockQuote>> getAllQuotes() async {
    return List.from(_quotes);
  }

  @override
  Future<StockQuote?> getQuote(String symbol) async {
    final match = _quotes.where((q) => q.symbol.toUpperCase() == symbol.toUpperCase());
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<StockQuote>> searchAssets(String query, {AssetCategory? category}) async {
    return _quotes.where((q) {
      final matchesQuery = q.symbol.toLowerCase().contains(query.toLowerCase()) ||
          q.name.toLowerCase().contains(query.toLowerCase());
      final matchesCat = category == null || category == AssetCategory.all || q.category == category;
      return matchesQuery && matchesCat;
    }).toList();
  }

  @override
  Future<MarketStatus> getMarketStatus() async {
    return const MarketStatus(
      isOpen: true,
      session: 'Regular Trading Hours',
      message: 'Simulated Real-Time Paper Feed Active',
    );
  }

  @override
  Future<List<StockQuote>> getTopGainers() async {
    final list = List<StockQuote>.from(_quotes);
    list.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return list.take(4).toList();
  }

  @override
  Future<List<StockQuote>> getTopLosers() async {
    final list = List<StockQuote>.from(_quotes);
    list.sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return list.take(4).toList();
  }

  @override
  Future<List<CandleData>> getCandlestickData(String symbol, TimeFrame timeFrame) async {
    final quote = await getQuote(symbol) ?? _quotes.first;
    final int count;
    final Duration interval;

    switch (timeFrame) {
      case TimeFrame.oneDay:
        count = 24;
        interval = const Duration(minutes: 15);
        break;
      case TimeFrame.oneWeek:
        count = 30;
        interval = const Duration(hours: 4);
        break;
      case TimeFrame.oneMonth:
        count = 30;
        interval = const Duration(days: 1);
        break;
      case TimeFrame.threeMonths:
        count = 45;
        interval = const Duration(days: 2);
        break;
      case TimeFrame.oneYear:
        count = 52;
        interval = const Duration(days: 7);
        break;
    }

    final List<CandleData> candles = [];
    final now = DateTime.now();
    double currentPrice = quote.price * (1.0 - (quote.changePercent / 100));

    for (int i = count; i >= 0; i--) {
      final time = now.subtract(interval * i);
      final volatility = currentPrice * 0.015;
      final change = (_rng.nextDouble() - 0.48) * volatility;
      final open = currentPrice;
      final close = currentPrice + change;
      final high = max(open, close) + (_rng.nextDouble() * volatility * 0.6);
      final low = min(open, close) - (_rng.nextDouble() * volatility * 0.6);
      final volume = 500000 + _rng.nextDouble() * 2000000;

      candles.add(CandleData(
        time: time,
        open: double.parse(open.toStringAsFixed(2)),
        high: double.parse(high.toStringAsFixed(2)),
        low: double.parse(low.toStringAsFixed(2)),
        close: double.parse(close.toStringAsFixed(2)),
        volume: volume,
      ));
      currentPrice = close;
    }

    return candles;
  }
}
