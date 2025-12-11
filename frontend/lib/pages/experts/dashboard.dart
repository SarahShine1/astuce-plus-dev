import 'package:flutter/material.dart';
import 'proposal_card.dart';
import 'proposal_details_popup.dart';
import 'create_astuce_page.dart';

class ModeratorDashboard extends StatefulWidget {
  const ModeratorDashboard({super.key});

  @override
  State<ModeratorDashboard> createState() => _ModeratorDashboardState();
}

class _ModeratorDashboardState extends State<ModeratorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _propositions = [
    {
      "titre": "Astuce : Économiser l’eau",
      "auteur": "Utilisateur A",
      "categorie": "Écologie",
      "statut": "à valider",
      "contenu": "Fermer le robinet pendant le brossage des dents."
    },
    {
      "titre": "Astuce : Gérer son temps",
      "auteur": "Utilisateur B",
      "categorie": "Productivité",
      "statut": "validée",
      "contenu": "Utiliser la méthode Pomodoro pour se concentrer."
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Modérateur"),
        backgroundColor: Colors.deepPurple,
        bottom: const TabBar(
          tabs: [
            Tab(text: "À valider"),
            Tab(text: "Validées"),
            Tab(text: "Rejetées"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList("à valider"),
          _buildList("validée"),
          _buildList("rejetée"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Créer une astuce"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAstucePage()),
          );
        },
      ),
    );
  }

  Widget _buildList(String statut) {
    final filtered = _propositions
        .where((p) => p["statut"] == statut)
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text("Aucune proposition dans cette catégorie."),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final prop = filtered[index];
        return ProposalCard(
          titre: prop["titre"],
          auteur: prop["auteur"],
          categorie: prop["categorie"],
          contenu: prop["contenu"],
          onView: () {
            showDialog(
              context: context,
              builder: (_) => ProposalDetailsPopup(
                proposition: prop,
                onDecision: (decision, commentaire) {
                  setState(() {
                    prop["statut"] = decision == "accepter" ? "validée" : "rejetée";
                    prop["commentaire"] = commentaire;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
