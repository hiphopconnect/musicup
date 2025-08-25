import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBanner({
    super.key,
    required this.message,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.icon,
  });

  factory StatusBanner.warning(String message) {
    return StatusBanner(
      message: message,
      backgroundColor: Colors.orange[100]!,
      textColor: Colors.orange[800]!,
      icon: Icons.warning,
    );
  }

  factory StatusBanner.error(String message) {
    return StatusBanner(
      message: message,
      backgroundColor: Colors.red[100]!,
      textColor: Colors.red[800]!,
      icon: Icons.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      color: backgroundColor,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
