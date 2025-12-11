import 'package:flutter/material.dart';

class ProposalCard extends StatelessWidget {
  final String titre;
  final String auteur;
  final String categorie;
  final String contenu;
  final VoidCallback onView;

  const ProposalCard({
    super.key,
    required this.titre,
    required this.auteur,
    required this.categorie,
    required this.contenu,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: ListTile(
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$categorie • par $auteur"),
        trailing: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: onView,
        ),
      ),
    );
  }
}
