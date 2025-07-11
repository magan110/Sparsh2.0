import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';

/// Custom animated app bar with blur effects
class GlassAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double blur;
  final bool enableGradient;
  
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.blur = 10,
    this.enableGradient = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<GlassAppBar> createState() => _GlassAppBarState();
}

class _GlassAppBarState extends State<GlassAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.enableGradient ? SparshTheme.appBarGradient : null,
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: AppBar(
            title: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white,
                    ],
                    stops: [
                      _glowAnimation.value - 0.3,
                      _glowAnimation.value,
                      _glowAnimation.value + 0.3,
                    ].map((e) => e.clamp(0.0, 1.0)).toList(),
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
            centerTitle: widget.centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: widget.leading,
            actions: widget.actions,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Floating panel with shadow animations
class FloatingPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool enableHover;
  final VoidCallback? onTap;
  
  const FloatingPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.enableHover = true,
    this.onTap,
  });

  @override
  State<FloatingPanel> createState() => _FloatingPanelState();
}

class _FloatingPanelState extends State<FloatingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _shadowAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovered) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = hovered;
    });
    
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding,
                margin: widget.margin,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: _shadowAnimation.value,
                      offset: Offset(0, _shadowAnimation.value * 0.5),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Gradient background with animated patterns
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final bool enableParticles;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 10),
    this.enableParticles = false,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
    
    _particles = List.generate(20, (index) => Particle());
    
    _gradientController.repeat(reverse: true);
    if (widget.enableParticles) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_gradientAnimation, _particleController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                (_gradientAnimation.value * 0.5).clamp(0.0, 1.0),
                (0.5 + _gradientAnimation.value * 0.5).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: Stack(
            children: [
              if (widget.enableParticles)
                ...(_particles.map((particle) => particle.build(_particleController.value))),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  
  Particle() {
    x = Random().nextDouble();
    y = Random().nextDouble();
    size = Random().nextDouble() * 4 + 1;
    color = Colors.white.withValues(alpha: Random().nextDouble() * 0.3);
    speed = Random().nextDouble() * 0.5 + 0.1;
  }
  
  Widget build(double animationValue) {
    final currentY = (y + animationValue * speed) % 1.0;
    
    return Positioned(
      left: x * 400,
      top: currentY * 800,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Custom loading animations
class LoadingAnimation extends StatelessWidget {
  final LoadingType type;
  final Color? color;
  final double size;
  final Duration duration;
  
  const LoadingAnimation({
    super.key,
    this.type = LoadingType.pulse,
    this.color,
    this.size = 50,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? SparshTheme.primaryBlue;
    
    switch (type) {
      case LoadingType.pulse:
        return _PulseLoading(color: loadingColor, size: size, duration: duration);
      case LoadingType.ripple:
        return _RippleLoading(color: loadingColor, size: size, duration: duration);
      case LoadingType.threeDots:
        return _ThreeDotsLoading(color: loadingColor, size: size, duration: duration);
      case LoadingType.spinner:
        return _SpinnerLoading(color: loadingColor, size: size, duration: duration);
    }
  }
}

enum LoadingType { pulse, ripple, threeDots, spinner }

class _PulseLoading extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _PulseLoading({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _animation.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _RippleLoading extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _RippleLoading({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_RippleLoading> createState() => _RippleLoadingState();
}

class _RippleLoadingState extends State<_RippleLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(duration: widget.duration, vsync: this);
    _controller2 = AnimationController(duration: widget.duration, vsync: this);
    
    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1);
    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller2);
    
    _controller1.repeat();
    Future.delayed(Duration(milliseconds: widget.duration.inMilliseconds ~/ 2), () {
      _controller2.repeat();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation1.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.color.withValues(alpha: 1.0 - _animation1.value),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation2.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.color.withValues(alpha: 1.0 - _animation2.value),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThreeDotsLoading extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _ThreeDotsLoading({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<_ThreeDotsLoading>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => 
      AnimationController(duration: widget.duration, vsync: this));
    
    _animations = _controllers.map((controller) => 
      Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )).toList();
    
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size / 5;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _animations[index].value,
              child: Container(
                width: dotSize,
                height: dotSize,
                margin: EdgeInsets.symmetric(horizontal: dotSize / 4),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _animations[index].value),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SpinnerLoading extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _SpinnerLoading({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_SpinnerLoading> createState() => _SpinnerLoadingState();
}

class _SpinnerLoadingState extends State<_SpinnerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 1.0],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: EdgeInsets.all(widget.size * 0.1),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer effect for loading placeholders
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 1.0).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1.0).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Animated icons with micro-interactions
class AnimatedMicroIcon extends StatefulWidget {
  final IconData icon;
  final IconData? alternateIcon;
  final double size;
  final Color? color;
  final VoidCallback? onTap;
  final bool enableBounce;
  final bool enableRotation;
  
  const AnimatedMicroIcon({
    super.key,
    required this.icon,
    this.alternateIcon,
    this.size = 24,
    this.color,
    this.onTap,
    this.enableBounce = true,
    this.enableRotation = false,
  });

  @override
  State<AnimatedMicroIcon> createState() => _AnimatedMicroIconState();
}

class _AnimatedMicroIconState extends State<AnimatedMicroIcon>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isAlternate = false;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.enableBounce) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
    
    if (widget.enableRotation) {
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    }
    
    if (widget.alternateIcon != null) {
      setState(() {
        _isAlternate = !_isAlternate;
      });
    }
    
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? SparshTheme.textPrimary;
    final currentIcon = _isAlternate ? (widget.alternateIcon ?? widget.icon) : widget.icon;
    
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * pi,
              child: Icon(
                currentIcon,
                size: widget.size,
                color: iconColor,
              ),
            ),
          );
        },
      ),
    );
  }
}