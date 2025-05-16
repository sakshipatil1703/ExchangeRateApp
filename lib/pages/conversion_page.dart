import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversionPage extends StatefulWidget {
  const ConversionPage({super.key});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage>
    with TickerProviderStateMixin {
  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  double rate = 0.0;
  double inputAmount = 1.0;
  String result = '';

  final List<String> currencies = [
    'USD',
    'INR',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'AED'
  ];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _iconController;

  Future<void> getRate() async {
    final url = 'https://api.exchangerate-api.com/v4/latest/$fromCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rate = data['rates'][toCurrency];
          result = (inputAmount * rate).toStringAsFixed(2);
        });
      } else {
        throw Exception('Failed to load rate');
      }
    } catch (e) {
      setState(() {
        result = 'Error fetching data';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getRate();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Widget buildDropdown(String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        items: currencies
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.yellow.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _iconController,
                    child: Image.asset('assets/money_exchange.png', height: 80),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Currency Converter",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter amount",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        inputAmount = double.tryParse(value) ?? 1.0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: buildDropdown(fromCurrency, (value) {
                          setState(() => fromCurrency = value!);
                          getRate();
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.sync_alt, size: 28),
                      ),
                      Expanded(
                        child: buildDropdown(toCurrency, (value) {
                          setState(() => toCurrency = value!);
                          getRate();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: getRate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.shade200,
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: const Text(
                        'Convert',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Text(
                      result.isEmpty
                          ? "Converted amount will appear here"
                          : "$inputAmount $fromCurrency = $result $toCurrency",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
