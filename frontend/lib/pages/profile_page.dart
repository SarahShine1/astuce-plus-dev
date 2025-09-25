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
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

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

  // Couleurs cohérentes avec SavedPage et PostPage
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Liste des propositions de l'utilisateur (dynamique)
  List<ProposalItem> userProposals = [
    ProposalItem('Shrimp with Garlic', Colors.orange[400]!, ProposalStatus.pending, null),
    ProposalItem('Spicy Sausage', Colors.teal[400]!, ProposalStatus.aiValidated, 4.2),
    ProposalItem('Thai Basil Pork', Colors.purple[400]!, ProposalStatus.modValidated, 4.8),
    ProposalItem('Pad Thai Special', Colors.pink[400]!, ProposalStatus.pending, null),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic));
    _animationController!.forward();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                  child: SlideTransition(
                    position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                    child: Column(
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 12),
                        _buildTabSection(),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettings(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Mon compte",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue,
                secondaryBlue,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar et informations
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: secondaryBlue,
                  backgroundImage: _getProfileImageProvider(),
                  child: _getProfileImageProvider() == null
                      ? Text(
                    'TA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (bio.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          bio,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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

            SizedBox(height: 16),

            // Bouton modifier profil
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentOrange, accentOrange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _editProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Modifier profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Tags d'intérêts
            _buildInterestTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestTags() {
    if (userInterests.isEmpty) {
      return Text(
        'Aucun centre d\'intérêt',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userInterests.map((interest) => Container(
          margin: EdgeInsets.only(right: 6),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: secondaryBlue.withOpacity(0.3)),
          ),
          child: Text(
            interest,
            style: TextStyle(
              color: secondaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTabSection() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
      child: Column(
        children: [
          // TabBar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: accentOrange,
              indicatorWeight: 2,
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(text: 'Mes astuces (${userProposals.length})'),
                Tab(text: 'Évaluations'),
              ],
            ),
          ),

          // TabBarView avec hauteur fixe
          Container(
            height: 400,
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
    );
  }

  Widget _buildAstucesContent() {
    if (userProposals.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
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
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'Aucune astuce pour le moment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Commencez à partager vos astuces !',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _addNewProposal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ajouter une astuce',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
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
                      top: 6,
                      left: 6,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 18,
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
                                Icon(Icons.edit, size: 16, color: primaryBlue),
                                SizedBox(width: 6),
                                Text('Modifier', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 6),
                                Text('Supprimer', style: TextStyle(fontSize: 12)),
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
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Partie basse avec titre + moyenne des avis si validée
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      proposal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Affichage de la moyenne si validée par IA
                    if (proposal.status == ProposalStatus.aiValidated && proposal.averageRating != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 3),
                          Text(
                            "${proposal.averageRating!.toStringAsFixed(1)}/5",
                            style: TextStyle(
                              fontSize: 10,
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
      top: 6,
      right: 6,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationsContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: secondaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: secondaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: secondaryBlue, size: 20),
            ),
            SizedBox(width: 12),
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
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
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
    setState(() {
      userProposals.add(
        ProposalItem(
            'Nouvelle Recette',
            Colors.indigo[400]!,
            ProposalStatus.pending,
            null
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
  final double? averageRating;

  ProposalItem(this.title, this.color, this.status, this.averageRating);
}

enum ProposalStatus {
  pending,
  aiValidated,
  modValidated,
}