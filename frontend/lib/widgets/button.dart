import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const Button({
    super.key,
    required this.buttonText,
    this.onTap,
    this.color ,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(

      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:  BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          width: 200,
          height: 60,
          alignment: Alignment.center,
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}