import 'package:flutter/material.dart';

class WelcomeButtoon extends StatelessWidget{
  const WelcomeButtoon({super.key, this.buttonText});
  final String? buttonText;
  @override
  Widget build(BuildContext context) {

    return Container(
        decoration: BoxDecoration(
          color: Color(0xFFF7AD19),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
          )
        ),
        child:  Text( buttonText!,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ));
  }
}