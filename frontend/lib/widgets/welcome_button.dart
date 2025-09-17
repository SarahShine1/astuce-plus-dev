import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadiusGeometry borderRadius;

  const WelcomeButton({
    super.key,
    required this.buttonText,
    this.onTap,
    this.color ,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(40)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:  BorderRadius.only(topLeft: Radius.circular(40)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
