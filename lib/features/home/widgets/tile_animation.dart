import 'package:flutter/material.dart';

class AnimatedTaskTile extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedTaskTile({
    super.key,
    required this.child,
    required this.index,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutBack,
  });

  @override
  State<AnimatedTaskTile> createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<AnimatedTaskTile> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _slideController = AnimationController(duration: widget.animationDuration, vsync: this);

    _scaleController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 2),
      vsync: this,
    );

    _fadeController = AnimationController(duration: widget.animationDuration, vsync: this);

    // Create animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: widget.animationCurve));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations with staggered delay based on index
    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    // Stagger animation based on index for a wave effect
    Future<void>.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
      ),
    );
  }
}
