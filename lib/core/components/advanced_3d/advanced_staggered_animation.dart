import 'package:flutter/material.dart';
import '../../utils/responsive_util.dart';

/// Advanced Staggered Animation for form fields and UI elements
class AdvancedStaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final double offset;
  final Axis direction;
  final bool autoStart;
  final AnimationController? controller;

  const AdvancedStaggeredAnimation({
    Key? key,
    required this.children,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 100),
    this.offset = 50.0,
    this.direction = Axis.vertical,
    this.autoStart = true,
    this.controller,
  }) : super(key: key);

  @override
  State<AdvancedStaggeredAnimation> createState() => _AdvancedStaggeredAnimationState();
}

class _AdvancedStaggeredAnimationState extends State<AdvancedStaggeredAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;
  
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    
    _controller = widget.controller ?? AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _initializeAnimations();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _controller.forward();
        }
      });
    }
  }

  void _initializeAnimations() {
    _fadeAnimations = [];
    _slideAnimations = [];
    _scaleAnimations = [];

    for (int i = 0; i < widget.children.length; i++) {
      final double startTime = (i * widget.delay.inMilliseconds) / widget.duration.inMilliseconds;
      final double endTime = ((i * widget.delay.inMilliseconds) + 600) / widget.duration.inMilliseconds;
      
      // Ensure endTime doesn't exceed 1.0
      final double clampedEndTime = endTime.clamp(0.0, 1.0);
      
      // Fade Animation
      _fadeAnimations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startTime,
              clampedEndTime,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      // Slide Animation
      Offset slideOffset;
      switch (widget.direction) {
        case Axis.vertical:
          slideOffset = Offset(0, widget.offset);
          break;
        case Axis.horizontal:
          slideOffset = Offset(widget.offset, 0);
          break;
      }

      _slideAnimations.add(
        Tween<Offset>(
          begin: slideOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startTime,
              clampedEndTime,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      // Scale Animation
      _scaleAnimations.add(
        Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startTime,
              clampedEndTime,
              curve: Curves.easeOutBack,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void restart() {
    if (!_isDisposed) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: widget.children.asMap().entries.map((entry) {
            final int index = entry.key;
            final Widget child = entry.value;
            
            if (index >= _fadeAnimations.length) {
              return child;
            }

            return Transform.translate(
              offset: _slideAnimations[index].value,
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: FadeTransition(
                  opacity: _fadeAnimations[index],
                  child: child,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Advanced Animated Container with multiple animation effects
class AdvancedAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool enableSlideAnimation;
  final bool enableScaleAnimation;
  final bool enableFadeAnimation;
  final bool enableRotationAnimation;
  final bool autoStart;
  final VoidCallback? onAnimationComplete;
  final Axis slideDirection;
  final double slideOffset;
  final double initialScale;
  final double finalScale;
  final double rotationAngle;

  const AdvancedAnimatedContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
    this.enableSlideAnimation = true,
    this.enableScaleAnimation = true,
    this.enableFadeAnimation = true,
    this.enableRotationAnimation = false,
    this.autoStart = true,
    this.onAnimationComplete,
    this.slideDirection = Axis.vertical,
    this.slideOffset = 50.0,
    this.initialScale = 0.8,
    this.finalScale = 1.0,
    this.rotationAngle = 0.1,
  }) : super(key: key);

  @override
  State<AdvancedAnimatedContainer> createState() => _AdvancedAnimatedContainerState();
}

class _AdvancedAnimatedContainerState extends State<AdvancedAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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
      curve: widget.curve,
    ));

    Offset slideOffset;
    switch (widget.slideDirection) {
      case Axis.vertical:
        slideOffset = Offset(0, widget.slideOffset);
        break;
      case Axis.horizontal:
        slideOffset = Offset(widget.slideOffset, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: widget.finalScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _rotationAnimation = Tween<double>(
      begin: widget.rotationAngle,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void restart() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: widget.child,
        );

        if (widget.enableRotationAnimation) {
          animatedChild = Transform.rotate(
            angle: _rotationAnimation.value,
            child: animatedChild,
          );
        }

        if (widget.enableScaleAnimation) {
          animatedChild = Transform.scale(
            scale: _scaleAnimation.value,
            child: animatedChild,
          );
        }

        if (widget.enableSlideAnimation) {
          animatedChild = Transform.translate(
            offset: _slideAnimation.value,
            child: animatedChild,
          );
        }

        if (widget.enableFadeAnimation) {
          animatedChild = FadeTransition(
            opacity: _fadeAnimation,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
    );
  }
}