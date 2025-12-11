import 'package:flutter/material.dart';

class ProposalDetailsPopup extends StatefulWidget {
  final Map<String, dynamic> proposition;
  final Function(String decision, String commentaire) onDecision;

  const ProposalDetailsPopup({
    super.key,
    required this.proposition,
    required this.onDecision,
  });

  @override
  State<ProposalDetailsPopup> createState() => _ProposalDetailsPopupState();
}

class _ProposalDetailsPopupState extends State<ProposalDetailsPopup> {
  final TextEditingController _commentaireCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prop = widget.proposition;

    return AlertDialog(
      title: Text(prop["titre"]),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Auteur : ${prop["auteur"]}"),
            Text("Catégorie : ${prop["categorie"]}"),
            const SizedBox(height: 10),
            Text("Contenu : ${prop["contenu"]}"),
            const SizedBox(height: 20),
            TextField(
              controller: _commentaireCtrl,
              decoration: const InputDecoration(
                labelText: "Commentaire (optionnel)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDecision("rejeter", _commentaireCtrl.text);
            Navigator.pop(context);
          },
          child: const Text("Rejeter", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDecision("accepter", _commentaireCtrl.text);
            Navigator.pop(context);
          },
          child: const Text("Accepter"),
        ),
      ],
    );
  }
}
