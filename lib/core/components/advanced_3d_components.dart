import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../utils/responsive_util.dart';

/// Advanced 3D Card Component with Transform and Matrix4
class Advanced3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool enableHover;
  final bool enableGlassMorphism;
  final double elevation;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enable3DTransform;
  final double rotationAngle;
  final double perspective;

  const Advanced3DCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.enableHover = true,
    this.enableGlassMorphism = false,
    this.elevation = 8.0,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enable3DTransform = true,
    this.rotationAngle = 0.1,
    this.perspective = 0.001,
  }) : super(key: key);

  @override
  State<Advanced3DCard> createState() => _Advanced3DCardState();
}

class _Advanced3DCardState extends State<Advanced3DCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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
      curve: widget.animationCurve,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rotationAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHover) return;
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
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: widget.enable3DTransform
                  ? Matrix4.identity()
                    ..setEntry(3, 2, widget.perspective)
                    ..rotateX(_rotationAnimation.value)
                    ..rotateY(_rotationAnimation.value * 0.5)
                    ..scale(_scaleAnimation.value)
                  : Matrix4.identity()..scale(_scaleAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.enableGlassMorphism
                      ? (widget.backgroundColor ?? SparshTheme.cardBackground)
                          .withOpacity(0.1)
                      : widget.backgroundColor ?? SparshTheme.cardBackground,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(ResponsiveUtil.scaledSize(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: SparshTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: widget.elevation * _scaleAnimation.value,
                      offset: Offset(0, widget.elevation * _scaleAnimation.value * 0.5),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: SparshTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: widget.elevation * 2,
                        offset: Offset(0, widget.elevation),
                      ),
                  ],
                  border: widget.enableGlassMorphism
                      ? Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        )
                      : null,
                ),
                child: widget.enableGlassMorphism
                    ? ClipRRect(
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(ResponsiveUtil.scaledSize(context, 16)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: widget.padding ??
                                ResponsiveUtil.scaledPadding(context, all: 16),
                            child: widget.child,
                          ),
                        ),
                      )
                    : Container(
                        padding: widget.padding ??
                            ResponsiveUtil.scaledPadding(context, all: 16),
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

/// Advanced 3D AppBar with Glass Morphism Effects
class Advanced3DAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool enableGlassMorphism;
  final double elevation;
  final bool centerTitle;
  final double? leadingWidth;
  final bool enable3DEffect;

  const Advanced3DAppBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.enableGlassMorphism = true,
    this.elevation = 0,
    this.centerTitle = true,
    this.leadingWidth,
    this.enable3DEffect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enableGlassMorphism
            ? (backgroundColor ?? SparshTheme.cardBackground).withOpacity(0.1)
            : backgroundColor ?? SparshTheme.cardBackground,
        boxShadow: enable3DEffect
            ? [
                BoxShadow(
                  color: SparshTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
        border: enableGlassMorphism
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              )
            : null,
      ),
      child: enableGlassMorphism
          ? ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  title: title,
                  leading: leading,
                  actions: actions,
                  backgroundColor: Colors.transparent,
                  elevation: elevation,
                  centerTitle: centerTitle,
                  leadingWidth: leadingWidth,
                ),
              ),
            )
          : AppBar(
              title: title,
              leading: leading,
              actions: actions,
              backgroundColor: backgroundColor ?? SparshTheme.cardBackground,
              elevation: elevation,
              centerTitle: centerTitle,
              leadingWidth: leadingWidth,
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Advanced 3D Floating Action Button
class Advanced3DFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enable3DTransform;
  final Duration animationDuration;
  final double size;

  const Advanced3DFloatingActionButton({
    Key? key,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 8.0,
    this.enable3DTransform = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.size = 56.0,
  }) : super(key: key);

  @override
  State<Advanced3DFloatingActionButton> createState() =>
      _Advanced3DFloatingActionButtonState();
}

class _Advanced3DFloatingActionButtonState
    extends State<Advanced3DFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.enable3DTransform
                ? Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotationAnimation.value)
                  ..rotateY(_rotationAnimation.value * 0.5)
                  ..scale(_scaleAnimation.value)
                : Matrix4.identity()..scale(_scaleAnimation.value),
            child: Container(
              width: ResponsiveUtil.scaledSize(context, widget.size),
              height: ResponsiveUtil.scaledSize(context, widget.size),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? SparshTheme.primaryBlue,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtil.scaledSize(context, widget.size / 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: SparshTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: (widget.elevation ?? 8.0) * _scaleAnimation.value,
                    offset: Offset(0, (widget.elevation ?? 8.0) * _scaleAnimation.value * 0.5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: widget.onPressed,
                backgroundColor: Colors.transparent,
                foregroundColor: widget.foregroundColor ?? Colors.white,
                elevation: 0,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Glass Morphism Container
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double sigmaX;
  final double sigmaY;
  final double borderOpacity;
  final double backgroundOpacity;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.borderOpacity = 0.2,
    this.backgroundOpacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: (backgroundColor ?? SparshTheme.cardBackground)
            .withOpacity(backgroundOpacity),
        borderRadius: borderRadius ??
            BorderRadius.circular(ResponsiveUtil.scaledSize(context, 16)),
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ??
            BorderRadius.circular(ResponsiveUtil.scaledSize(context, 16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            padding: padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Advanced Animated Container with Smooth Transitions
class AdvancedAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool enableScaleAnimation;
  final bool enableFadeAnimation;
  final bool enableSlideAnimation;
  final Offset? slideOffset;

  const AdvancedAnimatedContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.enableScaleAnimation = true,
    this.enableFadeAnimation = true,
    this.enableSlideAnimation = false,
    this.slideOffset,
  }) : super(key: key);

  @override
  State<AdvancedAnimatedContainer> createState() =>
      _AdvancedAnimatedContainerState();
}

class _AdvancedAnimatedContainerState extends State<AdvancedAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.enableScaleAnimation ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _fadeAnimation = Tween<double>(
      begin: widget.enableFadeAnimation ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _slideAnimation = Tween<Offset>(
      begin: widget.enableSlideAnimation
          ? (widget.slideOffset ?? const Offset(0, 0.5))
          : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
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
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: widget.borderRadius,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Advanced 3D List Tile with Hover Effects
class Advanced3DListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enable3DEffect;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const Advanced3DListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enableHover = true,
    this.enable3DEffect = true,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<Advanced3DListTile> createState() => _Advanced3DListTileState();
}

class _Advanced3DListTileState extends State<Advanced3DListTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: ResponsiveUtil.scaledPadding(context, 
                horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? SparshTheme.cardBackground,
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(ResponsiveUtil.scaledSize(context, 12)),
                boxShadow: widget.enable3DEffect
                    ? [
                        BoxShadow(
                          color: SparshTheme.primaryBlue.withOpacity(0.1),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value * 0.5),
                        ),
                      ]
                    : null,
              ),
              child: ListTile(
                leading: widget.leading,
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: widget.trailing,
                onTap: widget.onTap,
                contentPadding: widget.padding ??
                    ResponsiveUtil.scaledPadding(context, 
                      horizontal: 16, vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }
}