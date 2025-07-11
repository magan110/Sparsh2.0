import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/responsive_util.dart';

/// Advanced Staggered Animation System
class AdvancedStaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Axis direction;
  final bool enableScale;
  final bool enableFade;
  final bool enableSlide;
  final double slideDistance;

  const AdvancedStaggeredAnimation({
    Key? key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.delay = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.direction = Axis.vertical,
    this.enableScale = true,
    this.enableFade = true,
    this.enableSlide = true,
    this.slideDistance = 50.0,
  }) : super(key: key);

  @override
  State<AdvancedStaggeredAnimation> createState() =>
      _AdvancedStaggeredAnimationState();
}

class _AdvancedStaggeredAnimationState extends State<AdvancedStaggeredAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
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

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.enableScale ? 0.0 : 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.enableFade ? 0.0 : 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.enableSlide
            ? (widget.direction == Axis.vertical
                ? Offset(0, widget.slideDistance / 100)
                : Offset(widget.slideDistance / 100, 0))
            : Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.delay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
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
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: widget.children[index],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Advanced 3D Transform Utilities
class Advanced3DTransform extends StatefulWidget {
  final Widget child;
  final bool enableHover;
  final bool enableTap;
  final Duration animationDuration;
  final Curve animationCurve;
  final double maxRotationX;
  final double maxRotationY;
  final double maxScale;
  final double perspective;
  final VoidCallback? onTap;

  const Advanced3DTransform({
    Key? key,
    required this.child,
    this.enableHover = true,
    this.enableTap = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.maxRotationX = 0.1,
    this.maxRotationY = 0.1,
    this.maxScale = 1.05,
    this.perspective = 0.001,
    this.onTap,
  }) : super(key: key);

  @override
  State<Advanced3DTransform> createState() => _Advanced3DTransformState();
}

class _Advanced3DTransformState extends State<Advanced3DTransform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationXAnimation;
  late Animation<double> _rotationYAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationXAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxRotationX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _rotationYAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxRotationY,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
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
    if (isHovered && !_isTapped) {
      _controller.forward();
    } else if (!isHovered && !_isTapped) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (!widget.enableTap) return;
    setState(() {
      _isTapped = !_isTapped;
    });
    if (_isTapped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onTap?.call();
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
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateX(_rotationXAnimation.value)
                ..rotateY(_rotationYAnimation.value)
                ..scale(_scaleAnimation.value),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

/// Responsive Grid Layout Component
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int getColumns() {
      if (ResponsiveUtil.isDesktop(context)) {
        return desktopColumns ?? 3;
      } else if (ResponsiveUtil.isTablet(context)) {
        return tabletColumns ?? 2;
      } else {
        return mobileColumns ?? 1;
      }
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getColumns(),
          crossAxisSpacing: ResponsiveUtil.scaledSize(context, spacing),
          mainAxisSpacing: ResponsiveUtil.scaledSize(context, runSpacing),
          childAspectRatio: 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Responsive Builder for Screen-Size Aware Widgets
class ResponsiveBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget Function(BuildContext, ScreenType)? builder;

  const ResponsiveBuilder({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      ScreenType screenType;
      if (ResponsiveUtil.isDesktop(context)) {
        screenType = ScreenType.desktop;
      } else if (ResponsiveUtil.isTablet(context)) {
        screenType = ScreenType.tablet;
      } else {
        screenType = ScreenType.mobile;
      }
      return builder!(context, screenType);
    }

    if (ResponsiveUtil.isDesktop(context)) {
      return desktop ?? tablet ?? mobile ?? Container();
    } else if (ResponsiveUtil.isTablet(context)) {
      return tablet ?? mobile ?? Container();
    } else {
      return mobile ?? Container();
    }
  }
}

enum ScreenType { mobile, tablet, desktop }

/// Advanced Loading Animation Component
class AdvancedLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? text;
  final TextStyle? textStyle;
  final bool showText;

  const AdvancedLoadingAnimation({
    Key? key,
    this.size = 50.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.text,
    this.textStyle,
    this.showText = true,
  }) : super(key: key);

  @override
  State<AdvancedLoadingAnimation> createState() =>
      _AdvancedLoadingAnimationState();
}

class _AdvancedLoadingAnimationState extends State<AdvancedLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 3.14159,
                child: Container(
                  width: ResponsiveUtil.scaledSize(context, widget.size),
                  height: ResponsiveUtil.scaledSize(context, widget.size),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color ?? Theme.of(context).primaryColor,
                        (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtil.scaledSize(context, widget.size / 2),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: ResponsiveUtil.scaledSize(context, widget.size * 0.6),
                      height: ResponsiveUtil.scaledSize(context, widget.size * 0.6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.scaledSize(context, widget.size * 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showText) ...[
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            widget.text ?? 'Loading...',
            style: widget.textStyle ??
                TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                  fontWeight: FontWeight.w500,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
          ),
        ],
      ],
    );
  }
}

/// Advanced Progress Indicator with Animation
class AdvancedProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const AdvancedProgressIndicator({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPercentage = true,
    this.percentageStyle,
  }) : super(key: key);

  @override
  State<AdvancedProgressIndicator> createState() =>
      _AdvancedProgressIndicatorState();
}

class _AdvancedProgressIndicatorState extends State<AdvancedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AdvancedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: ResponsiveUtil.scaledSize(context, widget.height),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.grey[200],
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(
                      ResponsiveUtil.scaledSize(context, widget.height / 2),
                    ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.progressColor ?? Theme.of(context).primaryColor,
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(
                          ResponsiveUtil.scaledSize(context, widget.height / 2),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showPercentage) ...[
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: widget.percentageStyle ??
                    TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
              );
            },
          ),
        ],
      ],
    );
  }
}