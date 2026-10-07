import 'package:flutter/material.dart';
import '../domain/learning_models.dart';

class LearningCurriculum {
  static final List<LearningLevel> levels = [
    // LEVEL 1: What is a Stock?
    const LearningLevel(
      id: 1,
      title: 'What is a Stock?',
      subtitle: 'Ownership, Equity & Shares',
      description: 'Discover how companies issue shares and what owning a piece of a business really means.',
      icon: Icons.pie_chart_outline,
      accentColor: Color(0xFF00E5FF),
      lessons: [
        Lesson(
          id: 'l1_1',
          levelId: '1',
          title: 'Understanding Company Ownership',
          summary: 'A stock is a fractional share of ownership in a real corporation.',
          estimatedMinutes: 3,
          xpReward: 50,
          coinReward: 25,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'What Actually is a Stock?',
              content: 'Imagine your favorite pizzeria wants to expand to 10 new locations. Instead of taking a massive loan, the owner divides the business into 1,000 equal slices called "shares" and sells them to the public.\n\nWhen you buy 1 share, you become a part-owner of the pizzeria.',
              diagramType: 'pizza_equity',
            ),
            LessonStep(
              type: StepType.interactiveExample,
              title: 'Why Do Share Prices Move?',
              content: 'Stock prices are not random numbers. If the pizzeria opens 5 new profitable stores, each slice of the company is worth more. If people stop eating pizza, the value drops.\n\nBuyers and sellers agree on the price every second.',
              diagramType: 'supply_demand',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Concept Check',
              content: 'Test what you just learned!',
              quiz: QuizQuestion(
                question: 'When you buy 10 shares of Apple Inc. (AAPL), what did you just acquire?',
                choices: [
                  QuizChoice(text: 'A loan that Apple must repay you with interest'),
                  QuizChoice(text: 'Fractional ownership in Apple and its future profits'),
                  QuizChoice(text: 'A free subscription to Apple Music'),
                  QuizChoice(text: 'A guarantee that the stock will only go up'),
                ],
                correctIndex: 1,
                explanation: 'Exactly! Owning shares makes you an equity shareholder with fractional ownership in the company assets and earnings.',
                hint: 'Think about the pizzeria slice analogy.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 2: NSE & BSE
    const LearningLevel(
      id: 2,
      title: 'NSE & BSE',
      subtitle: 'Exchanges & Benchmark Indices',
      description: 'Explore National Stock Exchange (NSE), Bombay Stock Exchange (BSE), Nifty 50, and Sensex.',
      icon: Icons.account_balance,
      accentColor: Color(0xFF00E676),
      lessons: [
        Lesson(
          id: 'l2_1',
          levelId: '2',
          title: 'How Stock Exchanges Work',
          summary: 'Exchanges are secure digital marketplaces matching buyers and sellers.',
          estimatedMinutes: 4,
          xpReward: 60,
          coinReward: 30,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'The Digital Market Hall',
              content: 'Just like an e-commerce platform connects buyers and sellers of electronics, a Stock Exchange connects millions of people buying and selling shares.\n\nIn India, the two primary exchanges are the National Stock Exchange (NSE) and the Bombay Stock Exchange (BSE).',
              diagramType: 'exchange_order_matching',
            ),
            LessonStep(
              type: StepType.concept,
              title: 'What is an Index like Nifty 50 or Sensex?',
              content: 'Instead of checking all 5,000 stocks every day, exchanges group the biggest, strongest companies into a thermometer called an "Index".\n\nNIFTY 50 tracks the 50 largest Indian companies, while SENSEX tracks the top 30 on BSE.',
              diagramType: 'index_thermometer',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Index Verification',
              content: 'Identify the role of a stock index.',
              quiz: QuizQuestion(
                question: 'If someone says "The market is up 1% today", what are they typically referring to?',
                choices: [
                  QuizChoice(text: 'Every single stock in the world went up 1%'),
                  QuizChoice(text: 'A major benchmark index like Nifty 50 or S&P 500 moved up 1%'),
                  QuizChoice(text: 'Bank interest rates increased by 1%'),
                  QuizChoice(text: 'Government taxes increased'),
                ],
                correctIndex: 1,
                explanation: 'Correct! Benchmark indices represent the general health and direction of the overall market.',
                hint: 'Think of an index like a health thermometer for the economy.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 3: Candlestick Charts
    const LearningLevel(
      id: 3,
      title: 'Candlestick Charts',
      subtitle: 'Reading Price Action & Wicks',
      description: 'Master green vs red candles, open, high, low, close, and wick anatomy.',
      icon: Icons.candlestick_chart,
      accentColor: Color(0xFFFFB703),
      lessons: [
        Lesson(
          id: 'l3_1',
          levelId: '3',
          title: 'Anatomy of a Candlestick',
          summary: 'Understand Open, High, Low, and Close (OHLC) in a single visual candle.',
          estimatedMinutes: 4,
          xpReward: 70,
          coinReward: 35,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'The 4 Crucial Price Points',
              content: 'A line chart only shows where a price closed. A candlestick reveals the entire battle during that timeframe:\n\n• OPEN: Price at period start\n• HIGH: Highest price reached\n• LOW: Lowest price touched\n• CLOSE: Price when period ended',
              diagramType: 'candle_anatomy',
            ),
            LessonStep(
              type: StepType.interactiveExample,
              title: 'Green vs Red Candles',
              content: '• GREEN CANDLE: Close was HIGHER than Open (Bulls won this round!)\n• RED CANDLE: Close was LOWER than Open (Bears pushed price down!)\n\nThe thin lines poking out the top and bottom are called Wicks or Shadows.',
              diagramType: 'bull_bear_candle',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Candlestick Check',
              content: 'Test your candle reading skills.',
              quiz: QuizQuestion(
                question: 'On a GREEN candlestick, where is the Closing price located relative to the Open?',
                choices: [
                  QuizChoice(text: 'The Close is higher than the Open'),
                  QuizChoice(text: 'The Close is lower than the Open'),
                  QuizChoice(text: 'The Close is always at \$0'),
                  QuizChoice(text: 'Candlesticks do not have a Close price'),
                ],
                correctIndex: 0,
                explanation: 'Spot on! On a green (bullish) candle, the price ended higher than it began, placing Close above Open.',
                hint: 'Green signifies positive price movement.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 4: Mutual Funds
    const LearningLevel(
      id: 4,
      title: 'Mutual Funds',
      subtitle: 'Pooled Money & Professional Managers',
      description: 'Learn how pooled investments, Net Asset Value (NAV), and diversification protect capital.',
      icon: Icons.groups_outlined,
      accentColor: Color(0xFF7C4DFF),
      lessons: [
        Lesson(
          id: 'l4_1',
          levelId: '4',
          title: 'The Power of Pooling Capital',
          summary: 'Mutual funds allow thousands of individuals to invest together with professional supervision.',
          estimatedMinutes: 3,
          xpReward: 60,
          coinReward: 30,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'What is a Mutual Fund?',
              content: 'If you only have \$50, buying expensive shares in 50 different companies is difficult. A mutual fund pools \$50 from 10,000 investors into a \$500,000 pot.\n\nA professional fund manager invests that pot into a diversified basket of assets.',
              diagramType: 'fund_pooling',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Mutual Fund Advantage',
              content: 'Identify the core benefit.',
              quiz: QuizQuestion(
                question: 'What is the primary advantage of investing in a mutual fund compared to buying one single stock?',
                choices: [
                  QuizChoice(text: 'Guaranteed 100% returns every month'),
                  QuizChoice(text: 'Instant diversification across dozens of companies, spreading out risk'),
                  QuizChoice(text: 'You never pay any fees or taxes'),
                  QuizChoice(text: 'You get to run the company yourself'),
                ],
                correctIndex: 1,
                explanation: 'Great answer! Diversification prevents one failing company from wiping out your entire savings.',
                hint: 'Think about not putting all eggs in one basket.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 5: ETFs
    const LearningLevel(
      id: 5,
      title: 'ETFs',
      subtitle: 'Exchange Traded Funds',
      description: 'Understand low expense ratios, index tracking, intraday liquidity, and SPY / QQQ / NIFTYBEES.',
      icon: Icons.layers_outlined,
      accentColor: Color(0xFF00E5FF),
      lessons: [
        Lesson(
          id: 'l5_1',
          levelId: '5',
          title: 'Mutual Fund Diversity with Stock Speed',
          summary: 'ETFs trade on stock exchanges like regular shares with low management fees.',
          estimatedMinutes: 3,
          xpReward: 65,
          coinReward: 30,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'What is an ETF?',
              content: 'An ETF (Exchange Traded Fund) combines the best of both worlds: like a mutual fund, it holds a basket of stocks (e.g. S&P 500 or Nifty 50); but like a stock, you can buy or sell it in seconds during regular trading hours.',
              diagramType: 'etf_structure',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'ETF Trading Mechanism',
              content: 'Test ETF understanding.',
              quiz: QuizQuestion(
                question: 'How do you buy or sell an ETF like SPY or NIFTYBEES?',
                choices: [
                  QuizChoice(text: 'You trade it directly on the stock exchange during market hours, just like a stock'),
                  QuizChoice(text: 'You must mail a paper check to the fund manager'),
                  QuizChoice(text: 'You can only trade once per calendar year'),
                  QuizChoice(text: 'ETFs cannot be sold once bought'),
                ],
                correctIndex: 0,
                explanation: 'Correct! ETFs trade seamlessly throughout the trading day with real-time continuous pricing.',
                hint: 'The name stands for Exchange Traded Fund.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 6: Swing Trading
    const LearningLevel(
      id: 6,
      title: 'Swing Trading',
      subtitle: 'Capturing Multi-Day Trends',
      description: 'Learn support, resistance, holding for days to weeks, and riding market momentum.',
      icon: Icons.show_chart,
      accentColor: Color(0xFF00E676),
      lessons: [
        Lesson(
          id: 'l6_1',
          levelId: '6',
          title: 'Riding the Waves of Price',
          summary: 'Swing traders hold positions from several days to a few weeks to catch swings in trend.',
          estimatedMinutes: 4,
          xpReward: 70,
          coinReward: 35,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'Support and Resistance Floors & Ceilings',
              content: '• SUPPORT: A price floor where buyers consistently step in to prevent further declines.\n• RESISTANCE: A price ceiling where sellers enter to take profits.\n\nSwing traders look to buy near strong support and exit near resistance.',
              diagramType: 'support_resistance',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Swing Trading Horizon',
              content: 'Check time horizon.',
              quiz: QuizQuestion(
                question: 'What is the typical holding duration for a swing trader?',
                choices: [
                  QuizChoice(text: '30 seconds to 2 minutes'),
                  QuizChoice(text: 'A few days to several weeks'),
                  QuizChoice(text: '20 to 30 years'),
                  QuizChoice(text: 'Only during overnight hours'),
                ],
                correctIndex: 1,
                explanation: 'Yes! Swing trading focuses on multi-day to multi-week momentum without the stress of second-by-second day trading.',
                hint: 'Between day trading and long-term investing.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 7: Intraday Basics
    const LearningLevel(
      id: 7,
      title: 'Intraday Basics',
      subtitle: 'Day Trading Rules & High Risks',
      description: 'Understand intraday margins, square-off times, volatility, and why 90% of day traders lose money.',
      icon: Icons.bolt,
      accentColor: Color(0xFFFF5252),
      lessons: [
        Lesson(
          id: 'l7_1',
          levelId: '7',
          title: 'The Reality of Intraday Trading',
          summary: 'All intraday positions must be closed before the closing bell on the exact same day.',
          estimatedMinutes: 4,
          xpReward: 80,
          coinReward: 40,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'Intraday Square-Off Rule',
              content: 'In intraday trading, you do not take delivery of the stock. Every position must be closed before the market closes for the day (e.g. 3:15 PM).\n\nIf you forget, your broker automatically squares off the trade at the market price, locking in any gain or loss.',
              diagramType: 'intraday_clock',
            ),
            LessonStep(
              type: StepType.concept,
              title: 'Critical Risk Warning',
              content: 'Independent regulatory data (like SEBI studies) shows over 90% of retail intraday traders lose capital due to transaction fees, emotions, and leverage.\n\nPaper trading is essential to build discipline without losing real capital.',
              diagramType: 'risk_warning_sign',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Intraday Rule Check',
              content: 'Confirm the intraday timeline.',
              quiz: QuizQuestion(
                question: 'What happens to an intraday position if the trader does not manually sell before the day ends?',
                choices: [
                  QuizChoice(text: 'The position is kept forever for free'),
                  QuizChoice(text: 'The broker automatically closes (squares off) the position at current market price'),
                  QuizChoice(text: 'The exchange doubles the position value'),
                  QuizChoice(text: 'Nothing happens'),
                ],
                correctIndex: 1,
                explanation: 'Accurate! Brokers auto-close all intraday orders at square-off cutoffs to prevent margin exposure.',
                hint: 'Positions cannot be carried overnight.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 8: Risk Management
    const LearningLevel(
      id: 8,
      title: 'Risk Management',
      subtitle: 'Stop Loss, Position Sizing & 1% Rule',
      description: 'The single most important skill in finance: protecting capital so you live to trade another day.',
      icon: Icons.shield_outlined,
      accentColor: Color(0xFF00E5FF),
      lessons: [
        Lesson(
          id: 'l8_1',
          levelId: '8',
          title: 'The 1% Risk Rule and Stop Losses',
          summary: 'Never risk more than 1% to 2% of your total account on any single trade.',
          estimatedMinutes: 5,
          xpReward: 90,
          coinReward: 45,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'Why Good Traders Focus on Defense',
              content: 'Amateur traders ask: "How much money can I make?"\nProfessional traders ask: "How much money could I lose if I am wrong?"\n\nA Stop Loss order is an automatic instruction to sell if the price drops to a designated safety limit, cutting losses before they turn catastrophic.',
              diagramType: 'stop_loss_shield',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Risk Rule Application',
              content: 'Calculate acceptable trade risk.',
              quiz: QuizQuestion(
                question: 'If you have a \$10,000 virtual balance and follow the 1% risk rule, what is the maximum amount you should risk losing on one trade?',
                choices: [
                  QuizChoice(text: '\$100 (1% of \$10,000)'),
                  QuizChoice(text: '\$5,000 (50% of \$10,000)'),
                  QuizChoice(text: '\$10,000 (100% all-in)'),
                  QuizChoice(text: '\$0 (Never take any trades)'),
                ],
                correctIndex: 0,
                explanation: 'Outstanding! Risking only 1% (\$100) means you could withstand 10 losing trades in a row and still have over 90% of your capital intact.',
                hint: 'Calculate 1 percent of 10,000.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 9: Technical Analysis
    const LearningLevel(
      id: 9,
      title: 'Technical Analysis',
      subtitle: 'Moving Averages, RSI & Trends',
      description: 'Learn mathematical trend indicators, Relative Strength Index (RSI), and overbought/oversold signals.',
      icon: Icons.trending_up,
      accentColor: Color(0xFFFFB703),
      lessons: [
        Lesson(
          id: 'l9_1',
          levelId: '9',
          title: 'Moving Averages & RSI Oscillator',
          summary: 'Technical indicators smooth out noise and measure the velocity of price movement.',
          estimatedMinutes: 4,
          xpReward: 85,
          coinReward: 40,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'Moving Averages (MA)',
              content: 'A 50-day Moving Average calculates the average closing price over the last 50 trading days. When the current price trades above the MA, the intermediate trend is considered bullish.\n\nWhen price crosses below, it signals potential weakness.',
              diagramType: 'moving_average_line',
            ),
            LessonStep(
              type: StepType.concept,
              title: 'RSI: The Momentum Meter',
              content: 'RSI (Relative Strength Index) scales from 0 to 100:\n\n• Above 70: OVERBOUGHT (Price may have moved up too fast, potential pullback)\n• Below 30: OVERSOLD (Heavy selling pressure, potential bargain rebound)',
              diagramType: 'rsi_gauge',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'RSI Analysis Question',
              content: 'Interpret an RSI reading.',
              quiz: QuizQuestion(
                question: 'If a stock has an RSI reading of 78, what does this technical indicator suggest?',
                choices: [
                  QuizChoice(text: 'The company is going bankrupt'),
                  QuizChoice(text: 'The asset is in overbought territory and might experience a cool-off or pullback'),
                  QuizChoice(text: 'The stock price will freeze at \$78'),
                  QuizChoice(text: 'The market is closed for the weekend'),
                ],
                correctIndex: 1,
                explanation: 'Correct! Readings above 70 indicate intense buying momentum that often leads to short-term consolidation.',
                hint: 'RSI > 70 indicates overbought conditions.',
              ),
            ),
          ],
        ),
      ],
    ),

    // LEVEL 10: Advanced Investing
    const LearningLevel(
      id: 10,
      title: 'Advanced Investing',
      subtitle: 'Valuation, P/E Ratios & Compound Interest',
      description: 'Master fundamentals, Price-to-Earnings (P/E), balance sheet strength, and compound interest.',
      icon: Icons.workspace_premium,
      accentColor: Color(0xFFFFD700),
      lessons: [
        Lesson(
          id: 'l10_1',
          levelId: '10',
          title: 'The Eighth Wonder: Compounding & Fundamentals',
          summary: 'Long-term wealth is built by investing in businesses with strong moats and letting returns compound over decades.',
          estimatedMinutes: 5,
          xpReward: 100,
          coinReward: 50,
          steps: [
            LessonStep(
              type: StepType.concept,
              title: 'Price vs Value',
              content: '"Price is what you pay. Value is what you get." — Warren Buffett\n\nThe P/E (Price-to-Earnings) ratio compares the company stock price to its annual earnings per share. It tells you how many dollars investors are willing to pay for each \$1 of earnings.',
              diagramType: 'pe_scale',
            ),
            LessonStep(
              type: StepType.concept,
              title: 'The Magic of Compound Interest',
              content: 'If you invest \$1,000 at an average 10% annual return:\n• In 10 years: \$2,593\n• In 20 years: \$6,727\n• In 30 years: \$17,449!\n\nTime in the market beats timing the market.',
              diagramType: 'compound_growth_curve',
            ),
            LessonStep(
              type: StepType.quiz,
              title: 'Mastery Graduation Question',
              content: 'Test your holistic investment philosophy.',
              quiz: QuizQuestion(
                question: 'What is the most proven mathematical factor in building sustainable long-term financial independence?',
                choices: [
                  QuizChoice(text: 'Predicting which random crypto coin will 100x overnight'),
                  QuizChoice(text: 'Early consistent investing in diversified productive assets allowing compound interest to compound over time'),
                  QuizChoice(text: 'Trading 200 times per day with maximum leverage'),
                  QuizChoice(text: 'Keeping all money under the mattress in cash'),
                ],
                correctIndex: 1,
                explanation: 'Congratulations! You have mastered the core foundations of financial literacy and responsible market decision-making.',
                hint: 'Think about compounding and diversification.',
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  static LearningLevel? getLevelById(int id) {
    try {
      return levels.firstWhere((lvl) => lvl.id == id);
    } catch (_) {
      return null;
    }
  }

  static Lesson? getLessonById(String lessonId) {
    for (final level in levels) {
      for (final lesson in level.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
