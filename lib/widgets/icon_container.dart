import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double marginR;

  const IconContainer({
    super.key,
    required this.child,
    this.color = const Color.fromARGB(255, 221, 221, 221),
    this.marginR = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: marginR),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: child,
    );
  }
}
