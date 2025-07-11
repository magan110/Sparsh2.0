import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/responsive_util.dart';

/// Advanced 3D Card with glass morphism and transform effects
class Advanced3DCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final bool enableGlassMorphism;
  final bool enableHoverEffect;
  final bool enable3DTransform;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final List<BoxShadow>? customShadows;
  final Gradient? gradient;

  const Advanced3DCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 20,
    this.elevation = 8,
    this.enableGlassMorphism = true,
    this.enableHoverEffect = true,
    this.enable3DTransform = true,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.customShadows,
    this.gradient,
  }) : super(key: key);

  @override
  State<Advanced3DCard> createState() => _Advanced3DCardState();
}

class _Advanced3DCardState extends State<Advanced3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.01,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin ?? ResponsiveUtil.scaledPadding(context, all: 8),
              child: Transform.scale(
                scale: widget.enable3DTransform ? _scaleAnimation.value : 1.0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: widget.enable3DTransform
                      ? Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_rotationAnimation.value)
                    ..rotateY(_rotationAnimation.value)
                      : Matrix4.identity(),
                  child: AnimatedContainer(
                    duration: widget.animationDuration,
                    padding: widget.padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
                    decoration: BoxDecoration(
                      color: widget.enableGlassMorphism 
                          ? (widget.backgroundColor ?? Colors.white).withOpacity(0.9)
                          : (widget.backgroundColor ?? Colors.white),
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: widget.borderColor != null
                          ? Border.all(color: widget.borderColor!, width: 1)
                          : null,
                      boxShadow: widget.customShadows ?? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _elevationAnimation.value,
                          spreadRadius: 2,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                        if (widget.enableGlassMorphism)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                      ],
                    ),
                    child: widget.enableGlassMorphism
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: widget.child,
                            ),
                          )
                        : widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}