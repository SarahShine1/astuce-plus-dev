import 'package:flutter/material.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/pages/change_password_page.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  TabController? _tabController;
  String name = "Tasya Aulianza";
  String username = "@tasyaaauz";
  String email = "tasya@example.com";
  String bio = "Passionnée par la cuisine 🍳";
  String phone = "+213 555 123 456";
  String? profileImagePath;
  List<String> userInterests = ['Cuisine', 'Photographie', 'Voyages', 'Food'];

  // Helper pour l'image de profil
  ImageProvider? _getProfileImageProvider() {
    if (profileImagePath == null || profileImagePath!.isEmpty) return null;
    if (profileImagePath!.startsWith('http')) {
      return NetworkImage(profileImagePath!);
    } else {
      return FileImage(File(profileImagePath!));
    }
  }

  // Palette de couleurs originale
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);

  // Liste des propositions de l'utilisateur (dynamique)
  List<ProposalItem> userProposals = [
    ProposalItem('Shrimp with Garlic', Colors.orange[400]!, ProposalStatus.pending,null),
    ProposalItem('Spicy Sausage', Colors.teal[400]!, ProposalStatus?.aiValidated,3.2),
    ProposalItem('Thai Basil Pork', Colors.purple[400]!, ProposalStatus.modValidated,2),
    ProposalItem('Pad Thai Special', Colors.pink[400]!, ProposalStatus.pending,null),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileSection(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAstucesContent(),
                  _buildEvaluationsContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(

      padding: const EdgeInsets.all(15.0),
      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mon compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: primaryBlue),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: secondaryBlue,
                backgroundImage: _getProfileImageProvider(),
                child: _getProfileImageProvider() == null
                    ? Text(
                  'TA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      username,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        bio,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _editProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Modifier profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          _buildInterestTags(),
        ],
      ),
    );
  }

  Widget _buildInterestTags() {
    if (userInterests.isEmpty) {
      return Text(
        'Aucun centre d\'intérêt',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userInterests.map((interest) => Container(
          margin: EdgeInsets.only(right: 8), // espace entre les éléments
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: secondaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            interest,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
      ),
    );

  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: accentOrange,
        indicatorWeight: 2,
        labelColor: primaryBlue,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: 'Mes astuces (${userProposals.length})'),
          Tab(text: 'Évaluations'),
        ],
      ),
    );
  }

  Widget _buildAstucesContent() {
    if (userProposals.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: userProposals.length,
        itemBuilder: (context, index) {
          return _buildProposalCard(userProposals[index], index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucune astuce pour le moment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez à partager vos astuces !',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _addNewProposal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ajouter une astuce',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(ProposalItem proposal, int index) {
    return GestureDetector(
      onTap: () => _openProposal(proposal),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partie haute avec couleur + badge + menu
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: proposal.color,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    _getStatusBadge(proposal.status),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteProposal(index);
                          } else if (value == 'edit') {
                            _editProposal(index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: primaryBlue),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Partie basse avec titre + moyenne des avis si validée et partagée
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      proposal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ✅ Affichage de la moyenne uniquement si partagé et validé
                    if ( proposal?.status == ProposalStatus.aiValidated)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            proposal.averageRating!.toStringAsFixed(1) + "/5",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _getStatusBadge(ProposalStatus status) {
    String text;
    Color bgColor;
    Color textColor;

    switch (status) {
      case ProposalStatus.pending:
        text = 'En attente';
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case ProposalStatus.aiValidated:
        text = 'Validée IA';
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case ProposalStatus.modValidated:
        text = 'Validée';
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationsContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildHistoryItem(
            icon: Icons.star,
            title: 'Mes évaluations',
            count: 25,
            description: 'Consultez tous les avis que vous avez laissés',
            onTap: () => _openEvaluations(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required int count,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: secondaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: secondaryBlue, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Méthodes d'action
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.lock_outline, color: primaryBlue),
              title: Text('Changer mot de passe'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _changePassword(),
            ),
            ListTile(
              leading: Icon(Icons.notifications_outlined, color: primaryBlue),
              title: Text('Gérer notifications'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _manageNotifications(),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: name,
          initialUsername: username,
          initialEmail: email,
          initialBio: bio,
          initialPhone: phone,
          initialProfileImage: profileImagePath,
        ),
      ),
    );

    if (updatedData != null && updatedData is Map<String, dynamic>) {
      setState(() {
        name = updatedData['name'] ?? name;
        username = updatedData['username'] ?? username;
        email = updatedData['email'] ?? email;
        bio = updatedData['bio'] ?? bio;
        phone = updatedData['phone'] ?? phone;
        profileImagePath = updatedData['profileImage'];
      });
    }
  }

  void _addNewProposal() {
    // Ajouter une nouvelle proposition (pour démo)
    setState(() {
      userProposals.add(
        ProposalItem(
            'Nouvelle Recette',
            Colors.indigo[400]!,
            ProposalStatus.pending,
            4.2
        ),
      );
    });
  }

  void _deleteProposal(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer l\'astuce'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette astuce ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userProposals.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Astuce supprimée'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editProposal(int index) {
    print('Modifier proposition: ${userProposals[index].title}');
  }

  void _openProposal(ProposalItem proposal) {
    print('Ouvrir proposition: ${proposal.title}');
  }

  void _openEvaluations() {
    print('Ouvrir évaluations');
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
    );
  }

  void _manageNotifications() {
    Navigator.pop(context);
    print('Gérer notifications');
  }
}

// Classes de données
class ProposalItem {
  final String title;
  final Color color;
  final ProposalStatus status;
  final double? averageRating; // null si pas d’avis


  ProposalItem(this.title, this.color, this.status ,this.averageRating);
}

enum ProposalStatus {
  pending,
  aiValidated,
  modValidated,
}