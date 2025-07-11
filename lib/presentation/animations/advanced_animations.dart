import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';

/// Advanced animation controller for complex micro-interactions
class AdvancedAnimationController extends ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  bool _isAnimating = false;
  double _progress = 0.0;
  
  bool get isAnimating => _isAnimating;
  double get progress => _progress;
  
  void initialize(TickerProvider tickerProvider, Duration duration) {
    _controller = AnimationController(
      duration: duration,
      vsync: tickerProvider,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.addListener(() {
      _progress = _controller.value;
      notifyListeners();
    });
    
    _controller.addStatusListener((status) {
      _isAnimating = status == AnimationStatus.forward || 
                     status == AnimationStatus.reverse;
      notifyListeners();
    });
  }
  
  Future<void> forward() async {
    await _controller.forward();
  }
  
  Future<void> reverse() async {
    await _controller.reverse();
  }
  
  Future<void> reset() async {
    await _controller.reset();
  }
  
  Future<void> repeat({bool? reverse}) async {
    _controller.repeat(reverse: reverse ?? false);
  }
  
  void stop() {
    _controller.stop();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Advanced Lottie Animation Widget with enhanced controls
class AdvancedLottieAnimation extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool repeat;
  final bool reverse;
  final Duration? duration;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final bool enableInteraction;
  final AnimationController? controller;
  final BoxFit fit;
  final Alignment alignment;
  final bool enableHapticFeedback;
  
  const AdvancedLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.autoPlay = true,
    this.repeat = false,
    this.reverse = false,
    this.duration,
    this.onComplete,
    this.onTap,
    this.enableInteraction = true,
    this.controller,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.enableHapticFeedback = true,
  });

  @override
  State<AdvancedLottieAnimation> createState() => _AdvancedLottieAnimationState();
}

class _AdvancedLottieAnimationState extends State<AdvancedLottieAnimation> 
    with TickerProviderStateMixin {
  late AnimationController _internalController;
  AnimationController? get controller => widget.controller ?? _internalController;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.controller == null) {
      _internalController = AnimationController(
        duration: widget.duration ?? const Duration(milliseconds: 1000),
        vsync: this,
      );
      
      if (widget.autoPlay) {
        if (widget.repeat) {
          _internalController.repeat(reverse: widget.reverse);
        } else {
          _internalController.forward();
        }
      }
      
      _internalController.addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enableInteraction ? _handleTap : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Lottie.asset(
          widget.assetPath,
          controller: controller,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          reverse: widget.reverse,
          onLoaded: (composition) {
            if (widget.controller == null) {
              _internalController.duration = composition.duration;
              if (widget.autoPlay) {
                if (widget.repeat) {
                  _internalController.repeat(reverse: widget.reverse);
                } else {
                  _internalController.forward();
                }
              }
            }
          },
        ),
      ),
    );
  }
}

/// Advanced Rive Animation Widget with enhanced controls
class AdvancedRiveAnimation extends StatefulWidget {
  final String assetPath;
  final String? animationName;
  final String? stateMachineName;
  final double? width;
  final double? height;
  final bool autoPlay;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final bool enableInteraction;
  final BoxFit fit;
  final Alignment alignment;
  final bool enableHapticFeedback;
  final Map<String, dynamic>? inputs;
  
  const AdvancedRiveAnimation({
    super.key,
    required this.assetPath,
    this.animationName,
    this.stateMachineName,
    this.width,
    this.height,
    this.autoPlay = true,
    this.onComplete,
    this.onTap,
    this.enableInteraction = true,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.enableHapticFeedback = true,
    this.inputs,
  });

  @override
  State<AdvancedRiveAnimation> createState() => _AdvancedRiveAnimationState();
}

class _AdvancedRiveAnimationState extends State<AdvancedRiveAnimation> {
  late RiveAnimationController _riveController;
  Artboard? _artboard;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.stateMachineName != null) {
      _riveController = StateMachineController.fromArtboard(
        _artboard!,
        widget.stateMachineName!,
      )!;
    } else {
      _riveController = SimpleAnimation(
        widget.animationName ?? 'default',
        autoplay: widget.autoPlay,
      );
    }
    
    _loadRiveFile();
  }
  
  void _loadRiveFile() async {
    final data = await rootBundle.load(widget.assetPath);
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;
    
    if (widget.stateMachineName != null) {
      final controller = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachineName!,
      );
      
      if (controller != null) {
        artboard.addController(controller);
        _riveController = controller;
        
        // Set inputs if provided
        if (widget.inputs != null) {
          widget.inputs!.forEach((key, value) {
            final input = controller.findInput(key);
            if (input != null) {
              if (input is SMIBool) {
                input.value = value as bool;
              } else if (input is SMINumber) {
                input.value = value as double;
              } else if (input is SMITrigger) {
                if (value as bool) {
                  input.fire();
                }
              }
            }
          });
        }
      }
    } else {
      final controller = SimpleAnimation(
        widget.animationName ?? 'default',
        autoplay: widget.autoPlay,
      );
      artboard.addController(controller);
      _riveController = controller;
    }
    
    setState(() {
      _artboard = artboard;
    });
  }
  
  @override
  void dispose() {
    _riveController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enableInteraction ? _handleTap : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _artboard != null
          ? Rive(
              artboard: _artboard!,
              fit: widget.fit,
              alignment: widget.alignment,
            )
          : Container(),
      ),
    );
  }
}

/// Advanced Animated Container with multiple animation types
class AdvancedAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final Color? color;
  final bool enableHover;
  final bool enableScale;
  final bool enableRotation;
  final bool enableTranslation;
  final bool enableColorTransition;
  final VoidCallback? onTap;
  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;
  
  const AdvancedAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
    this.decoration,
    this.color,
    this.enableHover = true,
    this.enableScale = true,
    this.enableRotation = false,
    this.enableTranslation = false,
    this.enableColorTransition = true,
    this.onTap,
    this.onHover,
    this.onHoverExit,
  });

  @override
  State<AdvancedAnimatedContainer> createState() => _AdvancedAnimatedContainerState();
}

class _AdvancedAnimatedContainerState extends State<AdvancedAnimatedContainer> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _translationAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _translationAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.02),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.color ?? Colors.blue,
      end: (widget.color ?? Colors.blue).withOpacity(0.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovered) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _controller.forward();
      if (widget.onHover != null) {
        widget.onHover!();
      }
    } else {
      _controller.reverse();
      if (widget.onHoverExit != null) {
        widget.onHoverExit!();
      }
    }
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _isPressed = false;
        });
      });
      
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableScale
                ? _scaleAnimation.value * (_isPressed ? 0.95 : 1.0)
                : 1.0,
              child: Transform.rotate(
                angle: widget.enableRotation ? _rotationAnimation.value : 0.0,
                child: Transform.translate(
                  offset: widget.enableTranslation
                    ? _translationAnimation.value
                    : Offset.zero,
                  child: AnimatedContainer(
                    duration: widget.duration,
                    curve: widget.curve,
                    width: widget.width,
                    height: widget.height,
                    padding: widget.padding,
                    margin: widget.margin,
                    alignment: widget.alignment,
                    decoration: widget.decoration,
                    color: widget.enableColorTransition
                      ? _colorAnimation.value
                      : widget.color,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Advanced Animated Positioned widget for dynamic positioning
class AdvancedAnimatedPositioned extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final bool enableInteraction;
  final VoidCallback? onTap;
  final VoidCallback? onPositionChanged;
  
  const AdvancedAnimatedPositioned({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.enableInteraction = true,
    this.onTap,
    this.onPositionChanged,
  });

  @override
  State<AdvancedAnimatedPositioned> createState() => _AdvancedAnimatedPositionedState();
}

class _AdvancedAnimatedPositionedState extends State<AdvancedAnimatedPositioned> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: widget.duration,
      curve: widget.curve,
      left: widget.left,
      top: widget.top,
      right: widget.right,
      bottom: widget.bottom,
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTap: widget.enableInteraction ? _handleTap : null,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * _animation.value),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Advanced Staggered Animation Widget
class AdvancedStaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Axis direction;
  final bool enableScale;
  final bool enableFade;
  final bool enableSlide;
  final double slideOffset;
  final bool autoPlay;
  final VoidCallback? onComplete;
  
  const AdvancedStaggeredAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.delay = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.direction = Axis.vertical,
    this.enableScale = true,
    this.enableFade = true,
    this.enableSlide = true,
    this.slideOffset = 50.0,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<AdvancedStaggeredAnimation> createState() => _AdvancedStaggeredAnimationState();
}

class _AdvancedStaggeredAnimationState extends State<AdvancedStaggeredAnimation> 
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Animation<Offset>> _slideAnimations;
  
  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      );
    }).toList();
    
    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.direction == Axis.vertical
          ? Offset(0, widget.slideOffset)
          : Offset(widget.slideOffset, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();
    
    if (widget.autoPlay) {
      _startStaggeredAnimation();
    }
  }
  
  void _startStaggeredAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.delay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
    
    // Wait for all animations to complete
    await Future.delayed(
      widget.delay * widget.children.length + widget.duration,
    );
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableScale
                ? 0.8 + (0.2 * _animations[index].value)
                : 1.0,
              child: widget.enableSlide
                ? Transform.translate(
                    offset: _slideAnimations[index].value,
                    child: widget.enableFade
                      ? Opacity(
                          opacity: _animations[index].value,
                          child: widget.children[index],
                        )
                      : widget.children[index],
                  )
                : widget.enableFade
                  ? Opacity(
                      opacity: _animations[index].value,
                      child: widget.children[index],
                    )
                  : widget.children[index],
            );
          },
        ),
      ),
    );
  }
}

/// Hero Animation wrapper with advanced transitions
class AdvancedHeroAnimation extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final bool enableFade;
  final bool enableScale;
  final VoidCallback? onComplete;
  
  const AdvancedHeroAnimation({
    super.key,
    required this.tag,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.enableFade = true,
    this.enableScale = true,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        child: child,
      ),
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: enableScale
                ? 0.8 + (0.2 * animation.value)
                : 1.0,
              child: enableFade
                ? Opacity(
                    opacity: animation.value,
                    child: toHeroContext.widget,
                  )
                : toHeroContext.widget,
            );
          },
        );
      },
    );
  }
}

/// Morphing animation widget for shape transitions
class MorphingAnimation extends StatefulWidget {
  final Widget startWidget;
  final Widget endWidget;
  final Duration duration;
  final Curve curve;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onComplete;
  
  const MorphingAnimation({
    super.key,
    required this.startWidget,
    required this.endWidget,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.autoPlay = true,
    this.loop = false,
    this.onComplete,
  });

  @override
  State<MorphingAnimation> createState() => _MorphingAnimationState();
}

class _MorphingAnimationState extends State<MorphingAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
        if (widget.loop) {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed && widget.loop) {
        _controller.forward();
      }
    });
    
    if (widget.autoPlay) {
      _controller.forward();
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
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Opacity(
              opacity: 1.0 - _animation.value,
              child: Transform.scale(
                scale: 1.0 - (_animation.value * 0.1),
                child: widget.startWidget,
              ),
            ),
            Opacity(
              opacity: _animation.value,
              child: Transform.scale(
                scale: 0.9 + (_animation.value * 0.1),
                child: widget.endWidget,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Particle animation system for advanced effects
class ParticleAnimation extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  final Color particleColor;
  final double particleSize;
  final double? width;
  final double? height;
  final bool autoPlay;
  final VoidCallback? onComplete;
  
  const ParticleAnimation({
    super.key,
    this.particleCount = 50,
    this.duration = const Duration(milliseconds: 2000),
    this.particleColor = Colors.blue,
    this.particleSize = 4.0,
    this.width,
    this.height,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        color: widget.particleColor,
        size: widget.particleSize,
      ),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
    
    if (widget.autoPlay) {
      _controller.forward();
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
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 200,
          child: CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

/// Particle data class
class Particle {
  final Color color;
  final double size;
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double life;
  
  Particle({
    required this.color,
    required this.size,
  }) {
    x = (math.Random().nextDouble() * 2 - 1) * 100;
    y = (math.Random().nextDouble() * 2 - 1) * 100;
    vx = (math.Random().nextDouble() * 2 - 1) * 2;
    vy = (math.Random().nextDouble() * 2 - 1) * 2;
    life = 1.0;
  }
  
  void update(double progress) {
    x += vx;
    y += vy;
    life = 1.0 - progress;
  }
}

/// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  
  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      particle.update(progress);
      
      paint.color = particle.color.withOpacity(particle.life);
      
      canvas.drawCircle(
        Offset(
          size.width / 2 + particle.x,
          size.height / 2 + particle.y,
        ),
        particle.size * particle.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Import math for random number generation
import 'dart:math' as math;