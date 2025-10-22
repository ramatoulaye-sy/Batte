import 'package:flutter/material.dart';

/// Widget pour animer l'apparition du formulaire d'inscription
/// Utilise un AnimatedSize + FadeIn pour une transition fluide
class AnimatedFormReveal extends StatefulWidget {
  final bool show;
  final Widget child;
  final Duration duration;
  
  const AnimatedFormReveal({
    Key? key,
    required this.show,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  }) : super(key: key);

  @override
  State<AnimatedFormReveal> createState() => _AnimatedFormRevealState();
}

class _AnimatedFormRevealState extends State<AnimatedFormReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1), // Légèrement au-dessus
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFormReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: widget.show
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: widget.child,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
