# SPARSH App Theme Documentation

## Overview
This document describes the unified theme system extracted from the SPARSH Flutter application. The theme consolidates all design patterns, colors, and styling used throughout the application into a single, maintainable system.

## Theme Structure

### 1. Color Palette

#### Primary Colors
- `primaryBlue` (#1976D2) - Main brand color
- `primaryBlueLight` (#42A5F5) - Lighter variant
- `primaryBlueAccent` (#2196F3) - Accent color
- `primaryBlueShade700` (#1976D2) - Darker variant
- `primaryBlueShade400` (#42A5F5) - Medium variant

#### Secondary Colors
- `deepPurple` (#673AB7) - Used in some screens
- `deepPurpleShade700` (#512DA8) - Darker purple
- `deepPurpleShade400` (#7E57C2) - Medium purple
- `purple` (#9C27B0) - Purple variant
- `purpleShade300` (#BA68C8) - Light purple

#### Background Colors
- `scaffoldBackground` (#F5F7FB) - Main app background
- `cardBackground` (#F8F9FA) - Card backgrounds
- `lightBlueBackground` (#F1FFFF) - Light blue backgrounds
- `lightGreenBackground` (#E8F5E9) - Light green backgrounds
- `lightPurpleBackground` (#F3E5F5) - Light purple backgrounds
- `lighterPurpleBackground` (#E1BEE7) - Very light purple

#### Text Colors
- `textPrimary` (#263238) - Primary text color
- `textSecondary` (#90A4AE) - Secondary text color
- `textBlack` - Black text
- `textBlack87` - 87% opacity black
- `textGrey` (#6C757D) - Grey text

#### Status Colors
- `successGreen` - Success states
- `warningOrange` - Warning states
- `errorRed` - Error states
- `infoBlue` - Information states

#### Seat Colors (Movie Booking)
- `seatAvailable` - Available seats
- `seatSelected` - Selected seats
- `seatBooked` - Booked seats

### 2. Gradients

#### Primary Gradients
- `primaryGradient` - Blue gradient (primaryBlue to primaryBlueLight)
- `deepPurpleGradient` - Purple gradient (deepPurpleShade400 to deepPurpleShade700)
- `purpleGradient` - Purple gradient (purpleShade300 to purple)
- `blueAccentGradient` - Blue accent gradient (primaryBlueAccent to light blue)
- `orangeGradient` - Orange gradient (light orange to deep orange)
- `greenGradient` - Green gradient (light green to green)

#### UI Gradients
- `appBarGradient` - App bar background gradient
- `drawerHeaderGradient` - Drawer header background gradient

### 3. Typography

The app uses Google Fonts (Poppins) with the following text styles:

- `heading1` - 26px, bold, black
- `heading2` - 18px, bold, black
- `body` - 14px, black
- `bodyBold` - 14px, bold, black
- `small` - 12px, black
- `smallBold` - 12px, bold, black
- `italic` - 12px, italic, black

### 4. Spacing

Standard spacing values:
- `xs` - 4.0
- `sm` - 8.0
- `md` - 16.0
- `lg` - 24.0
- `xl` - 32.0
- `xxl` - 48.0

### 5. Border Radius

Standard border radius values:
- `small` - 8.0
- `medium` - 10.0
- `large` - 12.0
- `xl` - 25.0
- `xxl` - 50.0

### 6. Shadows

Predefined shadow styles:
- `small` - Light shadow (4px blur)
- `medium` - Medium shadow (8px blur)
- `large` - Heavy shadow (12px blur)
- `card` - Card-specific shadow with spread

## Usage Examples

### 1. Applying the Theme

```dart
import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARSH',
      theme: SparshTheme.lightTheme,
      home: HomeScreen(),
    );
  }
}
```

### 2. Using Colors

```dart
Container(
  color: SparshTheme.primaryBlue,
  child: Text(
    'Hello World',
    style: TextStyle(color: Colors.white),
  ),
)
```

### 3. Using Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: SparshTheme.primaryGradient,
  ),
  child: Text('Gradient Background'),
)
```

### 4. Using Typography

```dart
Text(
  'Heading',
  style: SparshTypography.heading1,
)

Text(
  'Body text',
  style: SparshTypography.body,
)
```

### 5. Using Spacing

```dart
Padding(
  padding: EdgeInsets.all(SparshSpacing.md),
  child: Text('Content'),
)
```

### 6. Using Border Radius

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(SparshBorderRadius.medium),
    color: Colors.white,
  ),
  child: Text('Rounded Container'),
)
```

### 7. Using Shadows

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: SparshShadows.medium,
  ),
  child: Text('Shadowed Container'),
)
```

## Theme Components

### App Bar
- Uses `appBarGradient` for background
- White text and icons
- Centered title with bold typography
- Elevation: 4

### Cards
- White background
- 3px elevation
- 10px border radius
- Medium shadow

### Buttons
- Primary blue background
- White text
- 8px border radius
- 2px elevation

### Input Fields
- Grey fill color
- 10px border radius
- Outlined border style
- 20px horizontal, 18px vertical padding

### Dialogs
- White background
- 12px border radius
- Rounded corners

### Bottom Navigation
- White background
- Primary blue selected color
- Grey unselected color
- 8px elevation

### Drawer
- White background
- `drawerHeaderGradient` for header
- 16px elevation

## Migration Guide

To migrate existing screens to use the unified theme:

1. Replace hardcoded colors with theme constants:
   ```dart
   // Before
   color: Colors.blue
   
   // After
   color: SparshTheme.primaryBlue
   ```

2. Replace hardcoded gradients with theme gradients:
   ```dart
   // Before
   gradient: LinearGradient(colors: [Colors.blue, Colors.blue])
   
   // After
   gradient: SparshTheme.appBarGradient
   ```

3. Replace hardcoded text styles with typography constants:
   ```dart
   // Before
   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
   
   // After
   style: SparshTypography.heading1
   ```

4. Replace hardcoded spacing with spacing constants:
   ```dart
   // Before
   padding: EdgeInsets.all(16.0)
   
   // After
   padding: EdgeInsets.all(SparshSpacing.md)
   ```

## Best Practices

1. **Always use theme constants** instead of hardcoded values
2. **Use semantic color names** (e.g., `successGreen` instead of `Colors.green`)
3. **Maintain consistency** across all screens
4. **Use the predefined spacing** and border radius values
5. **Apply shadows consistently** using the predefined shadow styles
6. **Test on different screen sizes** to ensure responsiveness

## Future Enhancements

1. **Dark Theme Support** - The theme structure supports dark theme implementation
2. **Custom Color Schemes** - Easy to add new color schemes for different brands
3. **Animation Themes** - Could add predefined animation curves and durations
4. **Responsive Typography** - Could add responsive text scaling
5. **Accessibility** - Could add high contrast and accessibility-focused themes 