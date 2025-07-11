import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';

/// Modern animated form field with floating labels and smooth animations
class AnimatedFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final Color? focusColor;
  final Color? fillColor;
  
  const AnimatedFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.focusColor,
    this.fillColor,
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _errorController;
  late Animation<double> _focusAnimation;
  late Animation<double> _errorAnimation;
  
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );
    
    _errorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorController, curve: Curves.elasticOut),
    );
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _focusController.forward();
      } else {
        _focusController.reverse();
        _validateField();
      }
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _errorController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller?.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
      
      if (_hasError) {
        _errorController.forward();
      } else {
        _errorController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.focusColor ?? SparshTheme.primaryBlue;
    final fillColor = widget.fillColor ?? Colors.white;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_focusAnimation, _errorAnimation]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused 
                        ? focusColor.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: _isFocused ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                onChanged: widget.onChanged,
                style: SparshTypography.body,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: SparshTheme.borderGrey,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: SparshTheme.borderGrey,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: focusColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: SparshTheme.errorRed,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: SparshTheme.errorRed,
                      width: 2,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: _isFocused ? focusColor : SparshTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: focusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  hintStyle: SparshTypography.bodySmall.copyWith(
                    color: SparshTheme.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _errorText ?? '',
                  style: SparshTypography.bodySmall.copyWith(
                    color: SparshTheme.errorRed,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideX(begin: -0.2, duration: 200.ms),
              ),
          ],
        );
      },
    );
  }
}

/// Animated Search Dropdown with modern design
class AnimatedSearchDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final T? selectedItem;
  final String? hintText;
  final Widget? prefixIcon;
  final bool enabled;
  
  const AnimatedSearchDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.selectedItem,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  State<AnimatedSearchDropdown<T>> createState() => _AnimatedSearchDropdownState<T>();
}

class _AnimatedSearchDropdownState<T> extends State<AnimatedSearchDropdown<T>>
    with TickerProviderStateMixin {
  late AnimationController _dropdownController;
  late Animation<double> _dropdownAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _dropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropdownController, curve: Curves.easeOut),
    );
    
    _filteredItems = widget.items;
    
    if (widget.selectedItem != null) {
      _searchController.text = widget.itemAsString(widget.selectedItem!);
    }
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_isOpen) {
        _openDropdown();
      }
    });
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openDropdown() {
    setState(() {
      _isOpen = true;
      _filteredItems = widget.items;
    });
    _dropdownController.forward();
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
    });
    _dropdownController.reverse();
    _focusNode.unfocus();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.itemAsString(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectItem(T item) {
    setState(() {
      _searchController.text = widget.itemAsString(item);
    });
    widget.onChanged(item);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.enabled ? _openDropdown : null,
          child: AbsorbPointer(
            absorbing: !_isOpen,
            child: AnimatedFormField(
              label: widget.label,
              hintText: widget.hintText,
              controller: _searchController,
              prefixIcon: widget.prefixIcon,
              suffixIcon: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              onChanged: _filterItems,
              enabled: widget.enabled,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _dropdownAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _dropdownAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
                        title: Text(
                          widget.itemAsString(item),
                          style: SparshTypography.body,
                        ),
                        onTap: () => _selectItem(item),
                        hoverColor: SparshTheme.primaryBlue.withValues(alpha: 0.1),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Animated Switch with modern design
class AnimatedSwitch extends StatefulWidget {
  final bool value;
  final void Function(bool) onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;
  final bool enabled;
  
  const AnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.enabled = true,
  });

  @override
  State<AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _positionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? SparshTheme.borderGrey,
      end: widget.activeColor ?? SparshTheme.primaryBlue,
    ).animate(_controller);
    
    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: SparshTypography.body.copyWith(
              color: widget.enabled ? SparshTheme.textPrimary : SparshTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 50,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: _colorAnimation.value,
                  boxShadow: [
                    BoxShadow(
                      color: _colorAnimation.value?.withValues(alpha: 0.3) ?? Colors.transparent,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _positionAnimation.value * 24 + 2,
                      top: 2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Animated Checkbox with modern design
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final void Function(bool?) onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final String? label;
  final bool enabled;
  
  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
    this.label,
    this.enabled = true,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOut),
    );
    
    if (widget.value) {
      _scaleController.value = 1.0;
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _scaleController.forward();
        _checkController.forward();
      } else {
        _scaleController.reverse();
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? SparshTheme.primaryBlue;
    final checkColor = widget.checkColor ?? Colors.white;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _checkAnimation]),
            builder: (context, child) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: widget.value ? activeColor : Colors.transparent,
                  border: Border.all(
                    color: widget.value ? activeColor : SparshTheme.borderGrey,
                    width: 2,
                  ),
                  boxShadow: widget.value ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: widget.value
                    ? Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: checkColor,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
            child: Text(
              widget.label!,
              style: SparshTypography.body.copyWith(
                color: widget.enabled ? SparshTheme.textPrimary : SparshTheme.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Multi-step form with animated progress indicator
class MultiStepForm extends StatefulWidget {
  final List<Widget> steps;
  final List<String> stepTitles;
  final void Function(int)? onStepChanged;
  final void Function()? onCompleted;
  
  const MultiStepForm({
    super.key,
    required this.steps,
    required this.stepTitles,
    this.onStepChanged,
    this.onCompleted,
  });

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0 / widget.steps.length,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      widget.onStepChanged?.call(_currentStep);
    } else {
      widget.onCompleted?.call();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      widget.onStepChanged?.call(_currentStep);
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / widget.steps.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${widget.steps.length}',
                    style: SparshTypography.labelMedium.copyWith(
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.stepTitles[_currentStep],
                    style: SparshTypography.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: (_currentStep + 1) / widget.steps.length,
                    backgroundColor: SparshTheme.borderLightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(SparshTheme.primaryBlue),
                    minHeight: 6,
                  );
                },
              ),
            ],
          ),
        ),
        
        // Form content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.steps.length,
            itemBuilder: (context, index) {
              return widget.steps[index]
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideX(begin: 0.2, duration: 300.ms, delay: 100.ms);
            },
          ),
        ),
        
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == widget.steps.length - 1 ? 'Complete' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}