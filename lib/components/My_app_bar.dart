import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed, 
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightgreyTextBox, 
      title: Text(
        title,   
        style: const TextStyle(
          color: AppColors.greyTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
           color: AppColors.greyTextColor,
           size: 32),
        onPressed: onBackPressed ?? () => Navigator.pop(context), 
      ),
      elevation: 0.0, 
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); 
}


