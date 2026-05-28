import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color = Colors.pinkAccent,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(color: color, strokeWidth: 3),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: TextStyle(color: color, fontSize: 14)),
        ],
      ],
    );
  }
}
