import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const CurrencyHomePage(),
    );
  }
}

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({super.key});

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  final TextEditingController _amountController = TextEditingController();

  final List<String> _currencies = ['USD', 'EUR', 'LBP', 'GBP'];

  String _fromCurrency = 'USD';
  String _toCurrency = 'LBP';

  double? _result;

  /// Last 3 conversions (only in memory, NO database).
  final List<String> _history = [];

  /// Fixed example rates relative to 1 USD.
  final Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.9,
    'LBP': 89000.0,
    'GBP': 0.8,
  };

  void _convert() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return;

    final amount = double.tryParse(text);
    if (amount == null) {
      setState(() => _result = null);
      return;
    }

    // Convert from selected currency → USD → target currency.
    final usdValue = amount / _rates[_fromCurrency]!;
    final converted = usdValue * _rates[_toCurrency]!;

    setState(() {
      _result = converted;

      final record =
          '$amount $_fromCurrency = ${converted.toStringAsFixed(2)} $_toCurrency';

      _history.insert(0, record);
      if (_history.length > 3) {
        _history.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top card with input and dropdowns
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Enter amount (e.g. 100)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('From'),
                              const SizedBox(height: 4),
                              _buildDropdown(
                                value: _fromCurrency,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _fromCurrency = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('To'),
                              const SizedBox(height: 4),
                              _buildDropdown(
                                value: _toCurrency,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _toCurrency = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _convert,
                      child: const Text('Convert'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result == null
                          ? 'Result will appear here'
                          : 'Result: ${_result!.toStringAsFixed(2)} $_toCurrency',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Last Conversions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Text(
                'No conversions yet.',
                style: TextStyle(color: Colors.black54),
              )
                  : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _history[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: _currencies
            .map(
              (c) => DropdownMenuItem(
            value: c,
            child: Text(c),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
