import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllRatePage extends StatefulWidget {
  @override
  _AllRatePageState createState() => _AllRatePageState();
}

class _AllRatePageState extends State<AllRatePage> {
  final List<String> currencies = ['USD', 'INR', 'EUR', 'GBP', 'JPY', 'AUD', 'AED'];
  Map<String, Map<String, double>> allRates = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllRates();
  }

  Future<void> fetchAllRates() async {
    Map<String, Map<String, double>> tempRates = {};

    try {
      for (String base in currencies) {
        final url = 'https://api.exchangerate-api.com/v4/latest/$base';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Map<String, double> ratesForBase = {};
          for (var target in currencies) {
            if (target != base) {
              ratesForBase[target] = (data['rates'][target] ?? 0.0).toDouble();
            }
          }
          tempRates[base] = ratesForBase;
        } else {
          throw Exception('Failed to fetch rates for $base');
        }
      }

      setState(() {
        allRates = tempRates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data';
        isLoading = false;
      });
    }
  }

  Widget buildRateTable(String base, Map<String, double> rates) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          'Base: $base',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF00695C),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Table(
              border: TableBorder.all(color: Colors.teal.shade100),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Rate (for 1 unit)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...rates.entries.map((entry) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.value.toStringAsFixed(2)),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // faint greenish background
      appBar: AppBar(
        title: const Text('All Currency Rates'),
        backgroundColor: const Color(0xFF00695C), // dark green appbar
        elevation: 4,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.redAccent),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: allRates.length,
        itemBuilder: (context, index) {
          String base = currencies[index];
          return buildRateTable(base, allRates[base]!);
        },
      ),
    );
  }
}
