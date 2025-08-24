import 'package:flutter/material.dart';

/// Reusable voice button widget for voice input functionality
class VoiceButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const VoiceButton({
    super.key,
    this.onPressed,
    this.size = 26,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.mic,
          color: color ?? Colors.blue[600],
          size: size,
        ),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(
          minWidth: size + 10,
          minHeight: size + 10,
        ),
        tooltip: 'Voice Input',
      ),
    );
  }
}
