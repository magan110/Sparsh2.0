import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/responsive_util.dart';

/// Glass Morphism Container with backdrop blur effects
class GlassMorphismContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double blurIntensity;
  final double opacity;
  final VoidCallback? onTap;
  final bool enableHoverEffect;
  final Duration animationDuration;
  final List<BoxShadow>? customShadows;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.blurIntensity = 10,
    this.opacity = 0.2,
    this.onTap,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.customShadows,
  }) : super(key: key);

  @override
  State<GlassMorphismContainer> createState() => _GlassMorphismContainerState();
}

class _GlassMorphismContainerState extends State<GlassMorphismContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity + 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: widget.blurIntensity,
      end: widget.blurIntensity + 5,
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
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin ?? ResponsiveUtil.scaledPadding(context, all: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.borderColor != null
                      ? Border.all(
                          color: widget.borderColor!.withOpacity(0.5),
                          width: 1,
                        )
                      : Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                  boxShadow: widget.customShadows ?? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Container(
                      padding: widget.padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
                      decoration: BoxDecoration(
                        color: (widget.backgroundColor ?? Colors.white)
                            .withOpacity(_opacityAnimation.value),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: widget.child,
                    ),
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