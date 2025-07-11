import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/responsive_util.dart';

/// Advanced 3D Button with glass morphism and 3D transform effects
class Advanced3DButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final bool enableGlassMorphism;
  final bool enable3DEffect;
  final bool enablePulseEffect;
  final IconData? icon;
  final bool isLoading;
  final Widget? loadingWidget;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final Duration animationDuration;

  const Advanced3DButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = 25,
    this.elevation = 6,
    this.enableGlassMorphism = true,
    this.enable3DEffect = true,
    this.enablePulseEffect = false,
    this.icon,
    this.isLoading = false,
    this.loadingWidget,
    this.textStyle,
    this.padding,
    this.gradient,
    this.customShadows,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<Advanced3DButton> createState() => _Advanced3DButtonState();
}

class _Advanced3DButtonState extends State<Advanced3DButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    if (widget.enablePulseEffect) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered && widget.enable3DEffect) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _pulseController]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            child: Transform.scale(
              scale: widget.enable3DEffect
                  ? _scaleAnimation.value * 
                    (widget.enablePulseEffect ? _pulseAnimation.value : 1.0)
                  : 1.0,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                width: widget.width,
                height: widget.height ?? ResponsiveUtil.scaledSize(context, 55),
                padding: widget.padding ?? ResponsiveUtil.scaledPadding(
                  context,
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.enableGlassMorphism
                      ? (widget.backgroundColor ?? Theme.of(context).primaryColor)
                          .withOpacity(0.9)
                      : (widget.backgroundColor ?? Theme.of(context).primaryColor),
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.borderColor != null
                      ? Border.all(color: widget.borderColor!, width: 2)
                      : null,
                  boxShadow: widget.customShadows ?? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? Theme.of(context).primaryColor)
                          .withOpacity(0.3),
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
                          child: _buildButtonContent(),
                        ),
                      )
                    : _buildButtonContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    return Center(
      child: widget.isLoading
          ? widget.loadingWidget ?? SizedBox(
              width: ResponsiveUtil.scaledSize(context, 24),
              height: ResponsiveUtil.scaledSize(context, 24),
              child: CircularProgressIndicator(
                color: widget.foregroundColor ?? Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.foregroundColor ?? Colors.white,
                    size: ResponsiveUtil.scaledSize(context, 24),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                ],
                Text(
                  widget.text,
                  style: widget.textStyle ?? TextStyle(
                    color: widget.foregroundColor ?? Colors.white,
                    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
    );
  }
}