import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/responsive_util.dart';

/// Advanced 3D Text Form Field with glass morphism and 3D effects
class Advanced3DTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool enableGlassMorphism;
  final bool enable3DEffect;
  final EdgeInsets? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final List<BoxShadow>? customShadows;

  const Advanced3DTextFormField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.borderRadius = 15,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.enableGlassMorphism = true,
    this.enable3DEffect = true,
    this.contentPadding,
    this.hintStyle,
    this.labelStyle,
    this.textStyle,
    this.customShadows,
  }) : super(key: key);

  @override
  State<Advanced3DTextFormField> createState() => _Advanced3DTextFormFieldState();
}

class _Advanced3DTextFormFieldState extends State<Advanced3DTextFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isFocused = false;
  bool _isHovered = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade100,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
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
          child: Transform.scale(
            scale: widget.enable3DEffect ? _scaleAnimation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: widget.enableGlassMorphism
                    ? (widget.backgroundColor ?? _colorAnimation.value)?.withOpacity(0.9)
                    : (widget.backgroundColor ?? _colorAnimation.value),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: _isFocused
                      ? (widget.focusedBorderColor ?? Theme.of(context).primaryColor)
                      : (widget.borderColor ?? Colors.grey.shade300),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: widget.customShadows ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    spreadRadius: 1,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                  if (widget.enableGlassMorphism)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: widget.enableGlassMorphism
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: _buildTextFormField(),
                      ),
                    )
                  : _buildTextFormField(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField() {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      style: widget.textStyle ?? TextStyle(
        fontSize: ResponsiveUtil.scaledFontSize(context, 16),
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle: widget.hintStyle ?? TextStyle(
          color: Colors.grey.shade400,
          fontSize: ResponsiveUtil.scaledFontSize(context, 14),
        ),
        labelStyle: widget.labelStyle ?? TextStyle(
          color: _isFocused ? Theme.of(context).primaryColor : Colors.grey.shade600,
          fontSize: ResponsiveUtil.scaledFontSize(context, 14),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _isFocused ? Theme.of(context).primaryColor : Colors.grey.shade600,
                size: ResponsiveUtil.scaledSize(context, 24),
              )
            : null,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: widget.contentPadding ??
            ResponsiveUtil.scaledPadding(
              context,
              horizontal: 16,
              vertical: 16,
            ),
      ),
    );
  }
}