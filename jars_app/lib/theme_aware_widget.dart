import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';

class ThemeAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? backgroundColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ThemeAwareText({
    super.key,
    required this.text,
    this.style,
    this.backgroundColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;

    Color? textColor;
    if (backgroundColor != null) {
      textColor = themeManager.getContrastingTextColor(backgroundColor!);
    }
    
    return Text(
      text,
      style: style?.copyWith(color: textColor) ?? TextStyle(color: textColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ThemeAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final ShapeBorder? shape;

  const ThemeAwareAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.shape,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;
    final bgColor = backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor;
    
    Color? titleColor;
    if (bgColor != null) {
      titleColor = themeManager.getContrastingTextColor(bgColor);
    }
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      shape: shape,
      iconTheme: titleColor != null ? IconThemeData(color: titleColor) : null,
    );
  }
}