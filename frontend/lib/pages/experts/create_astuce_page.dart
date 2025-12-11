import 'package:flutter/material.dart';

class CreateAstucePage extends StatefulWidget {
  const CreateAstucePage({super.key});

  @override
  State<CreateAstucePage> createState() => _CreateAstucePageState();
}

class _CreateAstucePageState extends State<CreateAstucePage> {
  final TextEditingController _titreCtrl = TextEditingController();
  final TextEditingController _contenuCtrl = TextEditingController();
  String _categorie = "Général";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une astuce"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titreCtrl,
              decoration: const InputDecoration(labelText: "Titre de l’astuce"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contenuCtrl,
              decoration: const InputDecoration(labelText: "Contenu"),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categorie,
              items: ["Général", "Productivité", "Écologie", "Cuisine"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _categorie = val!),
              decoration: const InputDecoration(labelText: "Catégorie"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Envoi vers backend ou ajout local
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Astuce créée avec succès ✅")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
