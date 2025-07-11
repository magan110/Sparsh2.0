import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Beautiful Theme Showcase Component
/// Demonstrates the professional design system with all enhanced features
class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('SPARSH Design System'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: SparshTheme.appBarGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Color Palette Section
            _buildColorPaletteSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Typography Section
            _buildTypographySection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Gradient Section
            _buildGradientSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Component Section
            _buildComponentSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Button Section
            _buildButtonSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Card Section
            _buildCardSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Input Section
            _buildInputSection(),
            const SizedBox(height: SparshSpacing.xl),
            
            // Status Colors Section
            _buildStatusColorsSection(),
            const SizedBox(height: SparshSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(SparshSpacing.lg),
      decoration: BoxDecoration(
        gradient: SparshTheme.primaryGradient,
        borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
        boxShadow: SparshShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPARSH Design System',
            style: SparshTypography.heading1.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          Text(
            'Professional, Modern & Beautiful',
            style: SparshTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: SparshSpacing.md),
          Row(
            children: [
              _buildFeatureChip('Modern Colors', Icons.palette),
              const SizedBox(width: SparshSpacing.sm),
              _buildFeatureChip('Professional Typography', Icons.text_fields),
              const SizedBox(width: SparshSpacing.sm),
              _buildFeatureChip('Beautiful Gradients', Icons.gradient),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SparshSpacing.sm,
        vertical: SparshSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SparshBorderRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: SparshIconSize.sm),
          const SizedBox(width: SparshSpacing.xs),
          Text(
            label,
            style: SparshTypography.labelMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteSection() {
    return _buildSection(
      'Color Palette',
      Icons.palette,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorRow('Primary Blue', SparshTheme.primaryBlue),
          _buildColorRow('Primary Blue Light', SparshTheme.primaryBlueLight),
          _buildColorRow('Primary Blue Accent', SparshTheme.primaryBlueAccent),
          _buildColorRow('Deep Purple', SparshTheme.infoBlue),
          _buildColorRow('Purple', SparshTheme.infoBlue),
          _buildColorRow('Success Green', SparshTheme.successGreen),
          _buildColorRow('Warning Orange', SparshTheme.warningOrange),
          _buildColorRow('Error Red', SparshTheme.errorRed),
        ],
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SparshSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
              boxShadow: SparshShadows.sm,
            ),
          ),
          const SizedBox(width: SparshSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: SparshTypography.bodyBold),
                Text(
                  '#${color.value.toRadixString(16).toUpperCase().substring(2)}',
                  style: SparshTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySection() {
    return _buildSection(
      'Typography',
      Icons.text_fields,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heading 1 - Display Large', style: SparshTypography.heading1),
          const SizedBox(height: SparshSpacing.sm),
          Text('Heading 2 - Display Medium', style: SparshTypography.heading2),
          const SizedBox(height: SparshSpacing.sm),
          Text('Heading 3 - Display Small', style: SparshTypography.heading3),
          const SizedBox(height: SparshSpacing.sm),
          Text('Heading 4 - Headline Large', style: SparshTypography.heading4),
          const SizedBox(height: SparshSpacing.sm),
          Text('Heading 5 - Headline Medium', style: SparshTypography.heading5),
          const SizedBox(height: SparshSpacing.sm),
          Text('Heading 6 - Headline Small', style: SparshTypography.heading6),
          const SizedBox(height: SparshSpacing.sm),
          Text('Body Large - Main content text', style: SparshTypography.bodyLarge),
          const SizedBox(height: SparshSpacing.sm),
          Text('Body - Regular text', style: SparshTypography.body),
          const SizedBox(height: SparshSpacing.sm),
          Text('Body Bold - Emphasized text', style: SparshTypography.bodyBold),
          const SizedBox(height: SparshSpacing.sm),
          Text('Body Small - Secondary text', style: SparshTypography.bodySmall),
          const SizedBox(height: SparshSpacing.sm),
          Text('Caption - Small helper text', style: SparshTypography.caption),
        ],
      ),
    );
  }

  Widget _buildGradientSection() {
    return _buildSection(
      'Beautiful Gradients',
      Icons.gradient,
      Column(
        children: [
          _buildGradientCard('Primary Gradient', SparshTheme.primaryGradient),
          const SizedBox(height: SparshSpacing.sm),
          _buildGradientCard('Purple Gradient', SparshTheme.blueAccentGradient),
          const SizedBox(height: SparshSpacing.sm),
          _buildGradientCard('Green Gradient', SparshTheme.greenGradient),
          const SizedBox(height: SparshSpacing.sm),
          _buildGradientCard('Orange Gradient', SparshTheme.orangeGradient),
          const SizedBox(height: SparshSpacing.sm),
          _buildGradientCard('Red Gradient', SparshTheme.redGradient),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String name, LinearGradient gradient) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.md,
      ),
      child: Center(
        child: Text(
          name,
          style: SparshTypography.bodyBold.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildComponentSection() {
    return _buildSection(
      'Components',
      Icons.widgets,
      Column(
        children: [
          _buildComponentCard('Cards', Icons.credit_card),
          const SizedBox(height: SparshSpacing.sm),
          _buildComponentCard('Buttons', Icons.touch_app),
          const SizedBox(height: SparshSpacing.sm),
          _buildComponentCard('Input Fields', Icons.input),
          const SizedBox(height: SparshSpacing.sm),
          _buildComponentCard('Chips', Icons.label),
        ],
      ),
    );
  }

  Widget _buildComponentCard(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(SparshSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SparshSpacing.sm),
            decoration: BoxDecoration(
              color: SparshTheme.primaryBlueShade100,
              borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
            ),
            child: Icon(
              icon,
              color: SparshTheme.primaryBlue,
              size: SparshIconSize.md,
            ),
          ),
          const SizedBox(width: SparshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: SparshTypography.bodyBold),
                Text(
                  'Modern and professional design',
                  style: SparshTypography.caption,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: SparshTheme.textTertiary,
            size: SparshIconSize.sm,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return _buildSection(
      'Buttons',
      Icons.touch_app,
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Icon Button'),
                ),
              ),
              const SizedBox(width: SparshSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return _buildSection(
      'Cards',
      Icons.credit_card,
      Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(SparshSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SparshSpacing.sm),
                        decoration: BoxDecoration(
                          color: SparshTheme.successLight,
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: SparshTheme.successGreen,
                          size: SparshIconSize.md,
                        ),
                      ),
                      const SizedBox(width: SparshSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Success Card', style: SparshTypography.bodyBold),
                            Text('Beautiful card design', style: SparshTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SparshSpacing.sm),
                  Text(
                    'This is an example of a modern card component with subtle shadows and rounded corners.',
                    style: SparshTypography.body,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          Card(
            child: Container(
              padding: const EdgeInsets.all(SparshSpacing.md),
              decoration: BoxDecoration(
                gradient: SparshTheme.cardGradient,
                borderRadius: BorderRadius.circular(SparshBorderRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: SparshTheme.warningOrange,
                    size: SparshIconSize.lg,
                  ),
                  const SizedBox(width: SparshSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gradient Card', style: SparshTypography.bodyBold),
                        Text('With beautiful gradient background', style: SparshTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return _buildSection(
      'Input Fields',
      Icons.input,
      Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: SparshSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(Icons.visibility),
            ),
            obscureText: true,
          ),
          const SizedBox(height: SparshSpacing.sm),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Country',
              prefixIcon: Icon(Icons.location_on),
            ),
            items: const [
              DropdownMenuItem(value: 'us', child: Text('United States')),
              DropdownMenuItem(value: 'uk', child: Text('United Kingdom')),
              DropdownMenuItem(value: 'ca', child: Text('Canada')),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColorsSection() {
    return _buildSection(
      'Status Colors',
      Icons.info,
      Column(
        children: [
          _buildStatusCard('Success', 'Operation completed successfully', SparshTheme.successGreen, SparshTheme.successLight, Icons.check_circle),
          const SizedBox(height: SparshSpacing.sm),
          _buildStatusCard('Warning', 'Please review your input', SparshTheme.warningOrange, SparshTheme.warningLight, Icons.warning),
          const SizedBox(height: SparshSpacing.sm),
          _buildStatusCard('Error', 'Something went wrong', SparshTheme.errorRed, SparshTheme.errorLight, Icons.error),
          const SizedBox(height: SparshSpacing.sm),
          _buildStatusCard('Info', 'Here is some information', SparshTheme.infoBlue, SparshTheme.infoLight, Icons.info),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String message, Color color, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(SparshSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: SparshIconSize.lg),
          const SizedBox(width: SparshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SparshTypography.bodyBold.copyWith(color: color)),
                Text(message, style: SparshTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SparshSpacing.sm),
              decoration: BoxDecoration(
                color: SparshTheme.primaryBlueShade100,
                borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
              ),
              child: Icon(
                icon,
                color: SparshTheme.primaryBlue,
                size: SparshIconSize.md,
              ),
            ),
            const SizedBox(width: SparshSpacing.sm),
            Text(title, style: SparshTypography.heading4),
          ],
        ),
        const SizedBox(height: SparshSpacing.md),
        content,
      ],
    );
  }
} 