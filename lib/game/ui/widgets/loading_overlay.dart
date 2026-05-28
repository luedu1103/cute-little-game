import 'package:flutter/material.dart';
import 'loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(child: LoadingIndicator(message: message)),
    );
  }
}
