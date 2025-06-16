import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;
  final String? lastText;
  final double fontSize;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final String? dateTime;

  const ChatButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.fontSize,
    this.lastText,
    this.margin = const EdgeInsets.symmetric(horizontal: 0),
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor = Colors.black,
    this.dateTime
  });

  String _formatDateTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), 
              offset: Offset(0, 2),                  
              blurRadius: 4,                         
              spreadRadius: 1,                       
            ),
          ],
        ),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                 padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                 child: Text(
                    buttonText,
                    style: TextStyle(
                      color: AppColors.greyTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                if (dateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: Text(
                      dateTime!,
                      style: TextStyle(
                        color:  AppColors.greyTextColor,
                        fontWeight: FontWeight.normal,
                        fontSize: fontSize - 4,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Zweite Zeile: lastText (falls vorhanden)
            if (lastText != null)
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  lastText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:  AppColors.greyTextColor,
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize - 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
