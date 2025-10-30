import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _imageCached = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animation = Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imageCached) {
      precacheImage(const AssetImage('assets/takkeh_logo.png'), context);
      _imageCached = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, child) => Transform.scale(scale: _animation.value, child: child),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/takkeh_logo.png', width: 52, height: 52),
                const SizedBox(height: 20),
                const Text('Takkeh', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('مرحبًا بكم', style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
