import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _paletteIndexKey = 'selectedPaletteIndex';
  static const String _customColorKey = 'selectedCustomColor';
  static const String _gradientColorsKey = 'gradientColors';
  
  int selectedPaletteIndex = 0;
  Color selectedCustomColor = Colors.blue;
  List<Color> _gradientColors = [Colors.purple, Colors.blue];

  ThemeManager._internal() {
    _loadTheme();
  }

  static final ThemeManager _instance = ThemeManager._internal();
  
  factory ThemeManager() {
    return _instance;
  }

  static ThemeManager get instance => _instance;

  List<Color> get gradientColors => List.from(_gradientColors);

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      selectedPaletteIndex = prefs.getInt(_paletteIndexKey) ?? 0;
      final colorValue = prefs.getInt(_customColorKey);
      if (colorValue != null) {
        selectedCustomColor = Color(colorValue);
      }
      
      final gradientStrings = prefs.getStringList(_gradientColorsKey);
      if (gradientStrings != null && gradientStrings.length >= 2) {
        _gradientColors = gradientStrings
            .map((str) => Color(int.parse(str)))
            .toList();
      } else {

        _gradientColors = [Colors.purple, Colors.blue];
      }
    } catch (e) {

      selectedPaletteIndex = 0;
      selectedCustomColor = Colors.blue;
      _gradientColors = [Colors.purple, Colors.blue];
    }
  }

  Future<void> setTheme(int paletteIndex, Color customColor, {List<Color>? gradientColors}) async {
    selectedPaletteIndex = paletteIndex;
    selectedCustomColor = customColor;
    
    if (gradientColors != null && gradientColors.length >= 2) {
      _gradientColors = List.from(gradientColors);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paletteIndexKey, paletteIndex);
    await prefs.setInt(_customColorKey, customColor.value);
    
    if (gradientColors != null && gradientColors.length >= 2) {
      final colorStrings = gradientColors.map((c) => c.value.toString()).toList();
      await prefs.setStringList(_gradientColorsKey, colorStrings);
    }
 
    notifyListeners();
  }

  Future<void> setGradientColors(List<Color> colors) async {
    if (colors.length < 2) {
      throw ArgumentError('At least 2 colors are required for gradient');
    }
    
    _gradientColors = List.from(colors);
    
    final prefs = await SharedPreferences.getInstance();
    final colorStrings = colors.map((c) => c.value.toString()).toList();
    await prefs.setStringList(_gradientColorsKey, colorStrings);
    
    notifyListeners();
  }

  bool isColorLight(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  Color getTextColorForBackground(Color backgroundColor) {
    return isColorLight(backgroundColor) ? Colors.black : Colors.white;
  }

  bool isGradientLight(List<Color> colors) {
    if (colors.isEmpty) return true;
    
    double totalLuminance = 0;
    for (final color in colors) {
      totalLuminance += color.computeLuminance();
    }
    final averageLuminance = totalLuminance / colors.length;
    
    return averageLuminance > 0.5;
  }

  Color getTextColorForGradient(List<Color> colors) {
    return isGradientLight(colors) ? Colors.black : Colors.white;
  }

  Color getThemeColor(Color baseMoodColor) {
    switch (selectedPaletteIndex) {
      case 0: // Bright & Vibrant
        return _brightenColor(baseMoodColor, 0.2);
      case 1: // Dark & Moody
        return _darkenColor(baseMoodColor, 0.3);
      case 2: // Pastel Dream
        return _pastelizeColor(baseMoodColor);
      case 3: // Warm Sunset
        return _warmColor(baseMoodColor);
      case 4: // Cool Ocean
        return _coolColor(baseMoodColor);
      case 5: // Neon Glow
        return _neonColor(baseMoodColor);
      case 6: // Earth Tones
        return _earthToneColor(baseMoodColor);
      case 7: // Gradient Magic 
        return _gradientColors.first;
      case 8: // Custom Color
        return selectedCustomColor;
      default:
        return baseMoodColor;
    }
  }

  Gradient getThemeGradient(Color baseMoodColor) {
    if (selectedPaletteIndex == 7 && _gradientColors.length >= 2) {
      return LinearGradient(
        colors: _gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final themeColor = getThemeColor(baseMoodColor);
    
    switch (selectedPaletteIndex) {
      case 3: // Warm Sunset
        return LinearGradient(
          colors: [
            themeColor,
            Color.lerp(themeColor, Colors.orange, 0.5) ?? Colors.orange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4: // Cool Ocean
        return LinearGradient(
          colors: [
            themeColor,
            Color.lerp(themeColor, Colors.cyan, 0.5) ?? Colors.cyan,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5: // Neon Glow
        return LinearGradient(
          colors: [
            themeColor,
            Color.lerp(themeColor, Colors.pink, 0.5) ?? Colors.pink,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        // For other themes
        return LinearGradient(
          colors: [
            themeColor,
            _darkenColor(themeColor, 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // Get appropriate text color for current theme based on background
  Color getThemeTextColor(Color baseMoodColor) {
    if (selectedPaletteIndex == 7 && _gradientColors.length >= 2) {
      return getTextColorForGradient(_gradientColors);
    }
    
    final themeColor = getThemeColor(baseMoodColor);
    return getTextColorForBackground(themeColor);
  }

  Color getContrastingTextColor(Color backgroundColor) {
    return getTextColorForBackground(backgroundColor);
  }

  Color _brightenColor(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  Color _darkenColor(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  Color _pastelizeColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      ((color.red + 255) ~/ 2),
      ((color.green + 255) ~/ 2),
      ((color.blue + 255) ~/ 2),
    );
  }

  Color _warmColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 1.2).clamp(0, 255).toInt(),
      (color.green * 0.9).clamp(0, 255).toInt(),
      (color.blue * 0.8).clamp(0, 255).toInt(),
    );
  }

  Color _coolColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.8).clamp(0, 255).toInt(),
      (color.green * 0.9).clamp(0, 255).toInt(),
      (color.blue * 1.2).clamp(0, 255).toInt(),
    );
  }

  Color _neonColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 1.5).clamp(0, 255).toInt(),
      (color.green * 1.5).clamp(0, 255).toInt(),
      (color.blue * 1.5).clamp(0, 255).toInt(),
    );
  }

  Color _earthToneColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.7 + 50).clamp(0, 255).toInt(),
      (color.green * 0.6 + 40).clamp(0, 255).toInt(),
      (color.blue * 0.5 + 30).clamp(0, 255).toInt(),
    );
  }

  Color _vibrantColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 1.3).clamp(0, 255).toInt(),
      (color.green * 1.1).clamp(0, 255).toInt(),
      (color.blue * 0.9).clamp(0, 255).toInt(),
    );
  }
  
  Future<void> resetToDefault() async {
    await setTheme(0, Colors.blue);
    _gradientColors = [Colors.purple, Colors.blue];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_gradientColorsKey, [
      Colors.purple.value.toString(),
      Colors.blue.value.toString()
    ]);
    notifyListeners();
  }

  List<Color> getComplementaryColors(Color baseColor) {
    return [
      baseColor,
      Color.fromARGB(
        255,
        255 - baseColor.red,
        255 - baseColor.green,
        255 - baseColor.blue,
      ), // Complementary
      Color.fromARGB(
        255,
        (baseColor.red + 128) % 256,
        baseColor.green,
        (baseColor.blue + 128) % 256,
      ), // Analogous
      Color.fromARGB(
        255,
        (baseColor.red * 0.5).toInt(),
        (baseColor.green * 1.2).clamp(0, 255).toInt(),
        (baseColor.blue * 0.7).clamp(0, 255).toInt(),
      ), // Triadic
    ];
  }

  Map<String, List<Color>> getPredefinedGradients() {
    return {
      'Sunset': [Color(0xFFFF6B6B), Color(0xFFFECA57)],
      'Ocean': [Color(0xFF4A90E2), Color(0xFF50E3C2)],
      'Forest': [Color(0xFF56AB2F), Color(0xFFA8E063)],
      'Berry': [Color(0xFFDA4453), Color(0xFF89216B)],
      'Sky': [Color(0xFF3498DB), Color(0xFF2C3E50)],
      'Warm': [Color(0xFFFF8A00), Color(0xFFFFC400)],
      'Cool': [Color(0xFF8344AD), Color(0xFF4A90E2)],
      'Nature': [Color(0xFF34A853), Color(0xFFB7DD29)],
    };
  }
}