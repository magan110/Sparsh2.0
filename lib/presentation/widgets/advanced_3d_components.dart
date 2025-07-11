import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';

/// Advanced 3D Card with Transform and BackdropFilter effects
class Advanced3DCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enableGlassMorphism;
  final double glassOpacity;
  final double blurStrength;
  final double perspective;
  final bool enable3DTransform;
  final Duration animationDuration;
  final Curve animationCurve;
  
  const Advanced3DCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 8.0,
    this.borderRadius = 16.0,
    this.gradient,
    this.onTap,
    this.enableHover = true,
    this.enableGlassMorphism = false,
    this.glassOpacity = 0.2,
    this.blurStrength = 10.0,
    this.perspective = 0.001,
    this.enable3DTransform = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<Advanced3DCard> createState() => _Advanced3DCardState();
}

class _Advanced3DCardState extends State<Advanced3DCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _rotationXAnimation;
  late Animation<double> _rotationYAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;
  bool _isTapped = false;
  
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: widget.animationCurve,
    ));
    
    _tapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
    
    _rotationXAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(_hoverAnimation);
    
    _rotationYAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(_hoverAnimation);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(_hoverAnimation);
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovered) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      _tapController.forward().then((_) {
        _tapController.reverse();
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
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) => _tapController.reverse(),
        onTapCancel: () => _tapController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, _tapAnimation]),
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              child: Transform(
                alignment: Alignment.center,
                transform: widget.enable3DTransform ? Matrix4.identity()
                  ..setEntry(3, 2, widget.perspective)
                  ..rotateX(_rotationXAnimation.value)
                  ..rotateY(_rotationYAnimation.value)
                  ..scale(_scaleAnimation.value - (_tapAnimation.value * 0.02))
                  : Matrix4.identity(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtil.scaledSize(context, widget.borderRadius),
                    ),
                    gradient: widget.gradient,
                    color: widget.gradient == null 
                      ? (widget.backgroundColor ?? Colors.white)
                      : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1 + (_hoverAnimation.value * 0.1)),
                        blurRadius: widget.elevation + (_hoverAnimation.value * 5),
                        offset: Offset(0, widget.elevation / 2 + (_hoverAnimation.value * 2)),
                        spreadRadius: _hoverAnimation.value * 2,
                      ),
                      if (widget.enableGlassMorphism)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: widget.enableGlassMorphism
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.scaledSize(context, widget.borderRadius),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: widget.blurStrength,
                            sigmaY: widget.blurStrength,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(widget.glassOpacity),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtil.scaledSize(context, widget.borderRadius),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            padding: widget.padding,
                            child: widget.child,
                          ),
                        ),
                      )
                    : Container(
                        padding: widget.padding,
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

/// Advanced 3D Floating Action Button
class Advanced3DFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double size;
  final ShapeBorder? shape;
  final Gradient? gradient;
  final bool enablePulse;
  final bool enableGlow;
  final Duration animationDuration;
  
  const Advanced3DFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 8.0,
    this.size = 56.0,
    this.shape,
    this.gradient,
    this.enablePulse = true,
    this.enableGlow = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<Advanced3DFloatingActionButton> createState() => _Advanced3DFloatingActionButtonState();
}

class _Advanced3DFloatingActionButtonState extends State<Advanced3DFloatingActionButton> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_pulseAnimation);
    
    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.onPressed != null) {
      _pressController.forward().then((_) {
        _pressController.reverse();
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: ResponsiveUtil.scaledSize(context, widget.size),
            height: ResponsiveUtil.scaledSize(context, widget.size),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? SparshTheme.primaryBlue)
                      .withOpacity(0.3),
                  blurRadius: widget.elevation + (_pulseAnimation.value * 5),
                  offset: Offset(0, widget.elevation / 2),
                  spreadRadius: _pulseAnimation.value * 2,
                ),
                if (widget.enableGlow)
                  BoxShadow(
                    color: (widget.backgroundColor ?? SparshTheme.primaryBlue)
                        .withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 20,
                    offset: Offset.zero,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.gradient ?? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.backgroundColor ?? SparshTheme.primaryBlue,
                        (widget.backgroundColor ?? SparshTheme.primaryBlue)
                            .withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Center(
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

/// Advanced 3D App Bar with perspective and depth
class Advanced3DAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double elevation;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool enableGlassMorphism;
  final double perspective;
  final bool enable3DTransform;
  final double? height;
  
  const Advanced3DAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation = 8.0,
    this.backgroundColor,
    this.gradient,
    this.enableGlassMorphism = false,
    this.perspective = 0.001,
    this.enable3DTransform = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        gradient: gradient ?? SparshTheme.appBarGradient,
        color: gradient == null ? (backgroundColor ?? SparshTheme.primaryBlue) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: enable3DTransform
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, perspective)
              ..rotateX(0.02),
            child: _buildAppBarContent(context),
          )
        : _buildAppBarContent(context),
    );
  }
  
  Widget _buildAppBarContent(BuildContext context) {
    return SafeArea(
      child: enableGlassMorphism
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: _buildAppBarRow(context),
            ),
          )
        : _buildAppBarRow(context),
    );
  }
  
  Widget _buildAppBarRow(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: leading!,
          )
        else if (automaticallyImplyLeading && Navigator.of(context).canPop())
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        Expanded(
          child: Center(
            child: title,
          ),
        ),
        if (actions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);
}

/// Advanced 3D Transform widget with Matrix4 transformations
class Advanced3DTransform extends StatefulWidget {
  final Widget child;
  final double perspective;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double scaleX;
  final double scaleY;
  final double scaleZ;
  final double translateX;
  final double translateY;
  final double translateZ;
  final Alignment alignment;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  
  const Advanced3DTransform({
    super.key,
    required this.child,
    this.perspective = 0.001,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.scaleZ = 1.0,
    this.translateX = 0.0,
    this.translateY = 0.0,
    this.translateZ = 0.0,
    this.alignment = Alignment.center,
    this.enableAnimation = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<Advanced3DTransform> createState() => _Advanced3DTransformState();
}

class _Advanced3DTransformState extends State<Advanced3DTransform> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    
    if (widget.enableAnimation) {
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Matrix4 _buildTransformMatrix() {
    return Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..rotateX(widget.rotationX * (widget.enableAnimation ? _animation.value : 1.0))
      ..rotateY(widget.rotationY * (widget.enableAnimation ? _animation.value : 1.0))
      ..rotateZ(widget.rotationZ * (widget.enableAnimation ? _animation.value : 1.0))
      ..scale(
        widget.scaleX * (widget.enableAnimation ? _animation.value : 1.0),
        widget.scaleY * (widget.enableAnimation ? _animation.value : 1.0),
        widget.scaleZ * (widget.enableAnimation ? _animation.value : 1.0),
      )
      ..translate(
        widget.translateX * (widget.enableAnimation ? _animation.value : 1.0),
        widget.translateY * (widget.enableAnimation ? _animation.value : 1.0),
        widget.translateZ * (widget.enableAnimation ? _animation.value : 1.0),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: widget.alignment,
          transform: _buildTransformMatrix(),
          child: widget.child,
        );
      },
    );
  }
}

/// Glass morphism container with BackdropFilter
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blurStrength;
  final double opacity;
  final Color? color;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  
  const GlassMorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blurStrength = 10.0,
    this.opacity = 0.2,
    this.color,
    this.border,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color?.withOpacity(opacity) ?? Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              gradient: gradient?.let((g) => g.createShader(Rect.zero)) != null
                ? gradient
                : null,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Advanced 3D List Tile with depth and perspective
class Advanced3DListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;
  final bool enableHover;
  final bool enable3DTransform;
  final double perspective;
  final double elevation;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double borderRadius;
  
  const Advanced3DListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.enableHover = true,
    this.enable3DTransform = true,
    this.perspective = 0.001,
    this.elevation = 4.0,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = 12.0,
  });

  @override
  State<Advanced3DListTile> createState() => _Advanced3DListTileState();
}

class _Advanced3DListTileState extends State<Advanced3DListTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.enable3DTransform ? Matrix4.identity()
              ..setEntry(3, 2, widget.perspective)
              ..rotateX(0.02 * _animation.value)
              ..scale(1.0 + (0.02 * _animation.value))
              : Matrix4.identity(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.gradient,
                color: widget.gradient == null 
                  ? (widget.backgroundColor ?? Colors.white)
                  : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1 + (_animation.value * 0.05)),
                    blurRadius: widget.elevation + (_animation.value * 3),
                    offset: Offset(0, widget.elevation / 2 + (_animation.value * 2)),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                    padding: widget.contentPadding ?? const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 16.0),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.title != null) widget.title!,
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4.0),
                                widget.subtitle!,
                              ],
                            ],
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 16.0),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Extension for additional utility functions
extension on Object? {
  T? let<T>(T Function(Object) block) {
    if (this != null) {
      return block(this!);
    }
    return null;
  }
}