import 'package:flutter/material.dart';
import 'conversion_page.dart';
import 'all_rates_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Widget styledButton({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) {
        _buttonController.reverse();
        onPressed();
      },
      onTapCancel: () => _buttonController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(3, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: Icon(icon, color: Colors.white),
            label: Text(text),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF8C2404), Color(0xFF3C1102)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Exchange Rate App',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/currency.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: buttonWidth,
                      child: styledButton(
                        text: 'Currency Conversion',
                        icon: Icons.currency_exchange_rounded,
                        colors: [Color(0xFFFB8C00), Color(0xFFFFB300)],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ConversionPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: buttonWidth,
                      child: styledButton(
                        text: 'Show All Rates',
                        icon: Icons.table_chart_outlined,
                        colors: [Color(0xFF43A047), Color(0xFF00ACC1)],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AllRatePage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Exchange smartly, travel wisely!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
