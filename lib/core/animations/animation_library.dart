import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Central animation library for Sparsh2.0 app
/// Contains reusable animation components and constants

class SparshAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

/// 3D Card Flip Animation Widget
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final bool isFlipped;
  final VoidCallback? onTap;
  
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
    this.isFlipped = false,
    this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isShowingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _isShowingFront = !widget.isFlipped;
    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      _flip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isShowingFront) {
      _controller.forward();
      _isShowingFront = false;
    } else {
      _controller.reverse();
      _isShowingFront = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _flip();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * 3.14159),
            child: isShowingFront ? widget.front : widget.back,
          );
        },
      ),
    );
  }
}

/// Glass Morphism Container
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final double blur;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const GlassMorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.color,
    this.blur = 10,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? Colors.white).withValues(alpha: 0.1),
            (color ?? Colors.white).withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: (color ?? Colors.white).withValues(alpha: 0.1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Floating Action Button with 3D Effect
class Floating3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double size;
  final bool enableHoverEffect;
  
  const Floating3DButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.size = 56,
    this.enableHoverEffect = true,
  });

  @override
  State<Floating3DButton> createState() => _Floating3DButtonState();
}

class _Floating3DButtonState extends State<Floating3DButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _shadowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );
    
    _shadowAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _onHover(bool hovered) {
    if (!widget.enableHoverEffect) return;
    
    setState(() {
      _isHovered = hovered;
    });
    
    if (hovered) {
      _scaleController.forward();
      _rotationController.forward();
      _shadowController.forward();
    } else {
      _scaleController.reverse();
      _rotationController.reverse();
      _shadowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onHover(true),
        onTapUp: (_) => _onHover(false),
        onTapCancel: () => _onHover(false),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _rotationAnimation,
            _shadowAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotationAnimation.value)
                  ..rotateY(_rotationAnimation.value * 0.5),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor,
                        backgroundColor.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.3),
                        blurRadius: _shadowAnimation.value,
                        offset: Offset(0, _shadowAnimation.value * 0.5),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: _shadowAnimation.value * 0.5,
                        offset: Offset(0, _shadowAnimation.value * 0.25),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Parallax Container for scrolling effects
class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final double rate;
  final ScrollController? scrollController;
  
  const ParallaxContainer({
    super.key,
    required this.child,
    this.rate = 0.5,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController ?? ScrollController(),
      builder: (context, child) {
        final offset = (scrollController?.offset ?? 0) * rate;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: this.child,
        );
      },
    );
  }
}

/// Morphing Container for shape animations
class MorphingContainer extends StatefulWidget {
  final Widget child;
  final BorderRadius initialBorderRadius;
  final BorderRadius targetBorderRadius;
  final Duration duration;
  final bool isAnimated;
  
  const MorphingContainer({
    super.key,
    required this.child,
    required this.initialBorderRadius,
    required this.targetBorderRadius,
    this.duration = const Duration(milliseconds: 500),
    this.isAnimated = false,
  });

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<BorderRadius> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _borderAnimation = BorderRadiusTween(
      begin: widget.initialBorderRadius,
      end: widget.targetBorderRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(MorphingContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
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
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: _borderAnimation.value,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Staggered List Animation
class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  
  const StaggeredListView({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return child
            .animate()
            .fadeIn(
              delay: delay * index,
              duration: duration,
              curve: curve,
            )
            .slideX(
              begin: -0.2,
              delay: delay * index,
              duration: duration,
              curve: curve,
            );
      }).toList(),
    );
  }
}