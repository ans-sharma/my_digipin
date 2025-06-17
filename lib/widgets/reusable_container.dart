import 'package:flutter/material.dart';

class ReusableContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Color color;

  const ReusableContainer({
    super.key,
    required this.child,
    this.height = 200,
    this.color = const Color.fromARGB(255, 76, 91, 92),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: height,
      // height: 0,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: child,
    );
  }
}
