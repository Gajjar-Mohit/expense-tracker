class Currency {
  final String currency;
  final String symbol;
  Currency({required this.currency, required this.symbol});
  static List<Currency> get currencies {
    final List<Map<String, dynamic>> json = [
     {"currency": "INR", "symbol": "Rs"},
    ];

    return json
        .map((c) => Currency(currency: c['currency'], symbol: c['symbol']))
        .toList();
  }
}
