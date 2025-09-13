import 'package:flutter/material.dart';
import 'package:frontend/widgets/welcome_button.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build (BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF053F5C),
      appBar: AppBar( backgroundColor: Color(0xFF053F5C),),
      body: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 36.0,
            ),
            child: Center(child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Bienvenue sur Astuce+ !\n',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    )
                  ),
                  TextSpan(text: '\nvos astuces pratiques au quotidien',
                      style: TextStyle(
                        fontSize: 19,

                      ))
                ],
              ),
            )),
          )),
         const Flexible(
             flex: 1,
             child: Align(
               alignment: Alignment.bottomRight,
               child: Row(
                           children: [
                Expanded(child: WelcomeButtoon(
                  buttonText: 'S inscrir',
                )),
                Expanded(child: WelcomeButtoon(
                  buttonText: 'Se connecter',
                )),
                           ],
                         ),
             ))
        ],
      ),
    );
  }
}