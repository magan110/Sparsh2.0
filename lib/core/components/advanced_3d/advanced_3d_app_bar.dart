import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/responsive_util.dart';

/// Advanced 3D App Bar with glass morphism and modern styling
class Advanced3DAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool enableGlassMorphism;
  final bool centerTitle;
  final TextStyle? titleTextStyle;
  final double? titleSpacing;
  final double? leadingWidth;
  final double? toolbarHeight;
  final Gradient? gradient;

  const Advanced3DAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 8,
    this.enableGlassMorphism = true,
    this.centerTitle = true,
    this.titleTextStyle,
    this.titleSpacing,
    this.leadingWidth,
    this.toolbarHeight,
    this.gradient,
  }) : super(key: key);

  @override
  State<Advanced3DAppBar> createState() => _Advanced3DAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}

class _Advanced3DAppBarState extends State<Advanced3DAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: widget.preferredSize.height,
              decoration: BoxDecoration(
                color: widget.enableGlassMorphism
                    ? (widget.backgroundColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.9)
                    : (widget.backgroundColor ?? Theme.of(context).primaryColor),
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: widget.elevation,
                    spreadRadius: 2,
                    offset: Offset(0, widget.elevation / 2),
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
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: _buildAppBarContent(context),
                      ),
                    )
                  : _buildAppBarContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: ResponsiveUtil.scaledPadding(context, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Leading
            if (widget.leading != null)
              SizedBox(
                width: widget.leadingWidth ?? 56,
                child: widget.leading,
              )
            else if (widget.automaticallyImplyLeading && Navigator.canPop(context))
              SizedBox(
                width: widget.leadingWidth ?? 56,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: widget.foregroundColor ?? Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            else
              SizedBox(width: widget.leadingWidth ?? 56),

            // Title
            Expanded(
              child: widget.centerTitle
                  ? Center(
                      child: _buildTitle(context),
                    )
                  : _buildTitle(context),
            ),

            // Actions
            if (widget.actions != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions!,
              )
            else
              const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.title,
      style: widget.titleTextStyle ??
          TextStyle(
            color: widget.foregroundColor ?? Colors.white,
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }
}