import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;
  final double fontSize;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final IconData? icon;
  final Color iconColor;
  final double iconSize;
  final double paddingToText;

  const ButtonWithIcon({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.fontSize,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor = Colors.black,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.paddingToText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Wichtiger Trick!
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: iconSize),
                  SizedBox(width: paddingToText), // Abstand zwischen Icon & Text
                ],
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppColors.greyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
