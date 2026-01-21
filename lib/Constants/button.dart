import 'package:flutter/material.dart';
import 'package:fluttrr/Constants/utils.dart';

class Button extends StatelessWidget {
  final child;
  final double? height;
  final onTap;
  final double? width;
  final borderRadius;
  const Button({
    super.key,
    required this.child,
    required this.onTap,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        // color: Colors.white.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: borderRadius, gradient: lefttorightgradient),
          child: child,
        ),
      ),
    );
  }
}
