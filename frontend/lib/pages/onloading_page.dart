import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/signup_page.dart';
import 'package:frontend/widgets/welcome_button.dart';
import 'package:frontend/widgets/button.dart';

class OnloadingPage extends StatefulWidget {
  const OnloadingPage({super.key});

  @override
  State<OnloadingPage> createState() => _OnloadingPageState();
}

class _OnloadingPageState extends State<OnloadingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/img1.png",
      "title": "Astuces au quotidien",
      "subtitle":
      "Trouve chaque jour des conseils pratiques et simples pour gagner du temps, économiser de l’énergie et rendre ta vie plus facile.",
    },
    {
      "image": "assets/images/img2.png",
      "title": "Fiables et validées",
      "subtitle":
      "Toutes les astuces sont analysées par l’IA et vérifiées par nos modérateurs afin de garantir leur qualité et leur fiabilité.",
    },
    {
      "image": "assets/images/img3.png",
      "title": "Partage tes trouvailles",
      "subtitle":
      "Publie tes propres astuces, reçois des avis de la communauté et contribue à créer une bibliothèque collective d’idées utiles.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053F5C),

      body: Column(
        children: [

          const SizedBox(height: 40),
          // Swipeable content
          Flexible(
            flex: 4,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Image.asset(
                        page["image"]!,
                        height: MediaQuery.of(context).size.height * 0.28,
                        width: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        page["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24, // titre plus visible
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        page["subtitle"]!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Page indicators
          Row(

            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _currentPage == index ? Colors.amber : Colors.white30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),



          const Spacer(), // 🔽 pousse les boutons tout en bas

          // Buttons at the very bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: WelcomeButton(
                      buttonText: "Continuer en invité",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 60,

                    child: WelcomeButton(
                      buttonText: "Se connecter/S'inscrire",
                      color: const Color(0xFFF7AD19),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
