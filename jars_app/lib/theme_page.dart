import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart'; 

class ThemePage extends StatefulWidget {
  final int selectedPalette;
  final Color baseMoodColor;
  final List<Color>? gradientColors;

  const ThemePage({
    super.key,
    required this.selectedPalette,
    required this.baseMoodColor,
    this.gradientColors,
  });

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late int selectedPalette;
  late Color selectedCustomColor;
  late List<Color> selectedGradientColors;
  late ThemeManager themeManager;

  final List<String> paletteNames = [
    "Bright & Vibrant",
    "Dark & Moody",
    "Pastel Dream",
    "Warm Sunset",
    "Cool Ocean",
    "Neon Glow",
    "Earth Tones",
    "Gradient Magic",
    "Custom Color"
  ];

  final List<PaletteData> palettes = [
    PaletteData(
      name: "Bright & Vibrant",
      colors: [
        Colors.redAccent,
        Colors.orangeAccent,
        Colors.yellow.shade700,
        Colors.greenAccent,
        Colors.blueAccent,
        Colors.purpleAccent,
      ],
      isGradient: false,
    ),
    PaletteData(
      name: "Dark & Moody",
      colors: [
        Colors.grey.shade900,
        Colors.blueGrey.shade800,
        Colors.purple.shade800,
        Colors.indigo.shade900,
        Colors.brown.shade800,
        Colors.deepPurple.shade800,
      ],
      isGradient: false,
    ),
    PaletteData(
      name: "Pastel Dream",
      colors: [
        const Color(0xFFFFD6E7),
        const Color(0xFFC5E6FF),
        const Color(0xFFC7FFD6),
        const Color(0xFFFFF6CD),
        const Color(0xFFE6D0FF),
        const Color(0xFFFFE4C9),
      ],
      isGradient: false,
    ),
    PaletteData(
      name: "Warm Sunset",
      colors: [
        const Color(0xFFFF6B6B),
        const Color(0xFFFF8E53),
        const Color(0xFFFFD166),
        const Color(0xFF6BCEFF),
        const Color(0xFF4A6FA5),
      ],
      isGradient: true,
    ),
    PaletteData(
      name: "Cool Ocean",
      colors: [
        const Color(0xFF2E3192),
        const Color(0xFF1BFFFF),
        const Color(0xFF00A8C5),
        const Color(0xFFA8FF78),
        const Color(0xFF78FFD6),
      ],
      isGradient: true,
    ),
    PaletteData(
      name: "Neon Glow",
      colors: [
        const Color(0xFF00FF9D),
        const Color(0xFF00F5FF),
        const Color(0xFFFF00E4),
        const Color(0xFFFFF500),
        const Color(0xFFFF0058),
      ],
      isGradient: true,
    ),
    PaletteData(
      name: "Earth Tones",
      colors: [
        const Color(0xFF8B4513),
        const Color(0xFFA0522D),
        const Color(0xFFCD853F),
        const Color(0xFFDEB887),
        const Color(0xFFF4A460),
        const Color(0xFFD2B48C),
      ],
      isGradient: false,
    ),
    PaletteData(
      name: "Gradient Magic",
      colors: [
        const Color(0xFF834D9B),
        const Color(0xFFD04ED6),
        const Color(0xFFF27121),
        const Color(0xFFE94057),
        const Color(0xFF8A2387),
      ],
      isGradient: true,
    ),
  ];

  final List<Color> customColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey.shade800,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    themeManager = ThemeManager.instance;
    selectedPalette = widget.selectedPalette;
    selectedCustomColor = widget.baseMoodColor;
    
    // Initialize gradient colors
    if (widget.gradientColors != null && widget.gradientColors!.length >= 2) {
      selectedGradientColors = List.from(widget.gradientColors!);
    } else {
      selectedGradientColors = [Colors.purple, Colors.blue];
    }
  }

  void _showGradientEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return GradientEditor(
          gradientColors: selectedGradientColors,
          predefinedGradients: themeManager.getPredefinedGradients(),
          onGradientChanged: (colors) {
            setState(() {
              selectedGradientColors = colors;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _getSelectedColor();
    final isColorLight = themeManager.isColorLight(selectedColor);
    final bottomTextColor = isColorLight ? Colors.black : Colors.white;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Choose Theme",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Color Themes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Choose a color palette that matches your mood",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Predefined palettes
                ...palettes.map((palette) {
                  final index = palettes.indexOf(palette);
                  final isGradientMagic = palette.name == "Gradient Magic";
                  
                  return Column(
                    children: [
                      _PaletteCard(
                        palette: palette,
                        isSelected: selectedPalette == index,
                        gradientColors: isGradientMagic ? selectedGradientColors : null,
                        onTap: () {
                          setState(() {
                            selectedPalette = index;
                          });
                        },
                      ),
                      
                      // Gradient editor button for Gradient Magic
                      if (isGradientMagic && selectedPalette == index)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: ListTile(
                              onTap: _showGradientEditor,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: selectedGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Edit Gradient Colors",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              subtitle: Text(
                                "Tap to customize",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Custom color section
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "Custom Color",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedCustomColor,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "C",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeManager.getContrastingTextColor(selectedCustomColor),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Selected Color",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedPalette == 8
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: selectedPalette == 8
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: customColors.map((color) {
                            final isSelected = selectedPalette == 8 && 
                                selectedCustomColor.value == color.value;
                            final textColor = themeManager.getContrastingTextColor(color);
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPalette = 8;
                                  selectedCustomColor = color;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: isSelected ? Colors.blue : Colors.white,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 18,
                                        color: textColor,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 2,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  themeManager.setTheme(
                    selectedPalette,
                    selectedPalette == 8 ? selectedCustomColor : widget.baseMoodColor,
                    gradientColors: selectedPalette == 7 ? selectedGradientColors : null,
                  );
                  
                  Navigator.pop(
                    context,
                    {
                      'paletteIndex': selectedPalette,
                      'selectedColor': selectedPalette == 8
                          ? selectedCustomColor
                          : selectedPalette == 7
                              ? selectedGradientColors.first
                              : widget.baseMoodColor,
                      'gradientColors': selectedPalette == 7 
                          ? selectedGradientColors 
                          : null,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  "Apply Theme",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bottomTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSelectedColor() {
    if (selectedPalette == 8) {
      return selectedCustomColor;
    } else if (selectedPalette == 7) {
      return selectedGradientColors.first;
    }
    // Get the theme color from the theme manager based on base mood color
    return themeManager.getThemeColor(widget.baseMoodColor);
  }
}

class PaletteData {
  final String name;
  final List<Color> colors;
  final bool isGradient;

  PaletteData({
    required this.name,
    required this.colors,
    required this.isGradient,
  });
}

class _PaletteCard extends StatelessWidget {
  final PaletteData palette;
  final bool isSelected;
  final List<Color>? gradientColors;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;
    final displayColors = palette.name == "Gradient Magic" && gradientColors != null
        ? gradientColors!
        : palette.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      palette.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.blue,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                gradient: palette.isGradient
                    ? LinearGradient(
                        colors: displayColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: palette.isGradient ? null : Colors.white,
              ),
              child: palette.isGradient
                  ? Center(
                      child: Text(
                        palette.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: palette.name == "Gradient Magic" && gradientColors != null
                              ? themeManager.getTextColorForGradient(gradientColors!)
                              : themeManager.getTextColorForGradient(displayColors),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: displayColors.map((color) {
                        final textColor = themeManager.getContrastingTextColor(color);
                        return Expanded(
                          child: Container(
                            color: color,
                            child: Center(
                              child: Text(
                                "A",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  shadows: textColor == Colors.white
                                      ? [
                                          Shadow(
                                            blurRadius: 2,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            
            if (!palette.isGradient)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displayColors.map((color) {
                    final textColor = themeManager.getContrastingTextColor(color);
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "A",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Gradient Editor
class GradientEditor extends StatefulWidget {
  final List<Color> gradientColors;
  final Map<String, List<Color>> predefinedGradients;
  final ValueChanged<List<Color>> onGradientChanged;

  const GradientEditor({
    super.key,
    required this.gradientColors,
    required this.predefinedGradients,
    required this.onGradientChanged,
  });

  @override
  State<GradientEditor> createState() => _GradientEditorState();
}

class _GradientEditorState extends State<GradientEditor> {
  late List<Color> currentColors;
  late ThemeManager themeManager;

  @override
  void initState() {
    super.initState();
    themeManager = ThemeManager.instance;
    currentColors = List.from(widget.gradientColors);
  }

  void _updateColor(int index, Color color) {
    setState(() {
      currentColors[index] = color;
    });
    widget.onGradientChanged(currentColors);
  }

  void _selectPredefinedGradient(String name, List<Color> colors) {
    setState(() {
      currentColors = List.from(colors);
    });
    widget.onGradientChanged(currentColors);
  }

  List<Color> _getSuggestedColors(Color baseColor) {
    return themeManager.getComplementaryColors(baseColor);
  }

  @override
  Widget build(BuildContext context) {
    final gradientTextColor = themeManager.getTextColorForGradient(currentColors);
    
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Edit Gradient",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.grey.shade700,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Gradient Preview
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: currentColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Gradient Preview",
                  style: TextStyle(
                    color: gradientTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Color Pickers
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Start Color",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ColorPickerCircle(
                      color: currentColors[0],
                      onColorChanged: (color) => _updateColor(0, color),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "End Color",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ColorPickerCircle(
                      color: currentColors[1],
                      onColorChanged: (color) => _updateColor(1, color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Predefined Gradients
          Text(
            "Predefined Gradients",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.predefinedGradients.entries.map((entry) {
                final gradientColors = entry.value;
                final textColor = themeManager.getTextColorForGradient(gradientColors);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _selectPredefinedGradient(entry.key, entry.value),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: currentColors[0] == gradientColors[0] &&
                                      currentColors[1] == gradientColors[1]
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              entry.key[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Suggested Colors based on start color
          Text(
            "Suggested Colors",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getSuggestedColors(currentColors[0]).map((color) {
              final textColor = themeManager.getContrastingTextColor(color);
              return GestureDetector(
                onTap: () => _updateColor(1, color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColors[1] == color 
                          ? Colors.blue 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "A",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Done",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Color Picker Circle Widget
class _ColorPickerCircle extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerCircle({
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;
    final textColor = themeManager.getContrastingTextColor(color);
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Pick a color",
                style: TextStyle(
                  color: Colors.grey.shade800,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: _SimpleColorPicker(
                  selectedColor: color,
                  onColorChanged: onColorChanged,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.colorize,
              color: textColor,
              size: 24,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Edit",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor,
                shadows: [
                  Shadow(
                    blurRadius: 1,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Color Picker
class _SimpleColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const _SimpleColorPicker({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<_SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<_SimpleColorPicker> {
  late Color _currentColor;
  late ThemeManager themeManager;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.redAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.limeAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.blueAccent,
    Colors.indigo,
    Colors.purple,
    Colors.purpleAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.white,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    themeManager = ThemeManager.instance;
    _currentColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colorOptions.map((color) {
        final textColor = themeManager.getContrastingTextColor(color);
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _currentColor.value == color.value 
                    ? Colors.blue 
                    : Colors.grey.shade300,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                "A",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}