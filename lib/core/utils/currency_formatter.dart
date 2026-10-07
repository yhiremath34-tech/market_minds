import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00');
  static final NumberFormat _integerFormat = NumberFormat('#,##0');

  static String format(double value) {
    return _currencyFormat.format(value);
  }

  static String formatCompact(double value) {
    return _compactFormat.format(value);
  }

  static String formatNumber(double value) {
    return _numberFormat.format(value);
  }

  static String formatInteger(int value) {
    return _integerFormat.format(value);
  }

  static String formatPnL(double amount) {
    final prefix = amount >= 0 ? '+\$' : '-\$';
    return '$prefix${_numberFormat.format(amount.abs())}';
  }

  static String formatPercentage(double percent) {
    final prefix = percent >= 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }
}
