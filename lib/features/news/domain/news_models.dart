enum NewsCategory {
  all('All'),
  markets('Markets'),
  stocks('Stocks'),
  economy('Economy'),
  learning('Learning'),
  investingBasics('Investing Basics');

  final String label;
  const NewsCategory(this.label);
}

class NewsArticle {
  final String id;
  final String title;
  final NewsCategory category;
  final String summary;
  final String educationalTakeaway;
  final DateTime publishedAt;
  final String readTime;
  final String sourceName;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.educationalTakeaway,
    required this.publishedAt,
    required this.readTime,
    this.sourceName = 'Market Minds Educational Wire',
  });

  static List<NewsArticle> getSampleArticles() {
    final now = DateTime.now();
    return [
      NewsArticle(
        id: 'news_1',
        title: 'Central Banks Hold Interest Rates Steady: What It Means for Beginners',
        category: NewsCategory.economy,
        summary: 'Monetary policy committees maintained base rates to balance inflation goals while supporting commercial enterprise growth.',
        educationalTakeaway: 'When interest rates remain steady, borrowing costs for corporations stay predictable, which often provides stability to stock valuations.',
        publishedAt: now.subtract(const Duration(hours: 3)),
        readTime: '3 min read',
      ),
      NewsArticle(
        id: 'news_2',
        title: 'Why Semiconductor Demand Continues to Shape Tech Index Movements',
        category: NewsCategory.stocks,
        summary: 'NVIDIA and cloud hyperscalers report steady AI infrastructure commitments, driving semiconductor supply chains.',
        educationalTakeaway: 'Tech hardware companies often lead market rallies because their chips power every software service we use daily.',
        publishedAt: now.subtract(const Duration(hours: 8)),
        readTime: '4 min read',
      ),
      NewsArticle(
        id: 'news_3',
        title: 'Demystifying the "P/E Ratio": Are High Valuations a Warning or a Growth Signal?',
        category: NewsCategory.investingBasics,
        summary: 'Comparing historical price-to-earnings multiples across defensive consumer staples and high-growth cloud innovators.',
        educationalTakeaway: 'A high P/E ratio means investors expect rapid earnings growth in the future. If the company fails to deliver, the stock may drop.',
        publishedAt: now.subtract(const Duration(days: 1)),
        readTime: '5 min read',
      ),
      NewsArticle(
        id: 'news_4',
        title: 'The Psychology of Selling: Why Most Traders Panic at Market Bottoms',
        category: NewsCategory.learning,
        summary: 'Behavioral finance shows humans feel the pain of a loss twice as intensely as the pleasure of an equivalent gain.',
        educationalTakeaway: 'Loss aversion causes beginners to panic-sell during temporary market dips. Sticking to a predefined risk plan prevents emotional mistakes.',
        publishedAt: now.subtract(const Duration(days: 2)),
        readTime: '4 min read',
      ),
    ];
  }
}
