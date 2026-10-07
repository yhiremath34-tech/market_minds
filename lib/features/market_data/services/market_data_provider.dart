import '../domain/market_models.dart';

abstract class MarketDataProvider {
  Future<List<StockQuote>> getAllQuotes();
  Future<StockQuote?> getQuote(String symbol);
  Future<List<CandleData>> getCandlestickData(String symbol, TimeFrame timeFrame);
  Future<List<StockQuote>> searchAssets(String query, {AssetCategory? category});
  Future<MarketStatus> getMarketStatus();
  Future<List<StockQuote>> getTopGainers();
  Future<List<StockQuote>> getTopLosers();
}
