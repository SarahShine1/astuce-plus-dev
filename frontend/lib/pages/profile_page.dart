import 'package:flutter/material.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/pages/change_password_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  TabController? _tabController;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  String name = "Loading...";
  String username = "@loading";
  String email = "loading@example.com";
  String bio = "";
  String phone = "";
  String? profileImagePath;
  List<String> userInterests = [];
  List<ProposalItem> userProposals = [];

  ImageProvider? _getProfileImageProvider() {
    if (profileImagePath == null || profileImagePath!.isEmpty) return null;
    if (profileImagePath!.startsWith('http')) {
      return NetworkImage(profileImagePath!);
    } else {
      return FileImage(File(profileImagePath!));
    }
  }

  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic));
    _animationController!.forward();
  }

  Future<void> _loadUserData() async {
    try {
      String? userData = await storage.read(key: 'user_data');
      String? accessToken = await storage.read(key: 'access_token');

      if (userData != null) {
        final u = jsonDecode(userData);
        setState(() {
          name = u['nom'] ?? u['username'] ?? 'User';
          username = '@${u['username']}';
          email = u['email'] ?? '';
          bio = u['bio'] ?? '';
          phone = u['phone'] ?? '';
          if (u['centres_interet'] != null && u['centres_interet'].toString().isNotEmpty) {
            userInterests = u['centres_interet'].toString().split(',').map((e) => e.trim()).toList();
          }
        });
      }

      if (accessToken != null) {
        try {
          final response = await AuthService().getProfile(accessToken);
          if (response.statusCode == 200) {
            final profileData = jsonDecode(response.body);
            setState(() {
              name = profileData['nom'] ?? profileData['username'] ?? 'User';
              username = '@${profileData['username']}';
              email = profileData['email'] ?? '';
              bio = profileData['bio'] ?? '';
            });
            await storage.write(key: 'user_data', value: jsonEncode(profileData));
          }
        } catch (_) {}
      }
    } catch (_) {
      setState(() {
        name = 'Error loading profile';
        username = '@error';
      });
    }
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
        IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: _showSettings),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          "Mon compte",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    String initials = 'U';
    if (name.isNotEmpty && name != 'Loading...') {
      final nameParts = name.split(' ');
      if (nameParts.length >= 2) {
        initials = nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        initials = name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: secondaryBlue,
                  backgroundImage: _getProfileImageProvider(),
                  child: _getProfileImageProvider() == null
                      ? Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBlue)),
                      const SizedBox(height: 2),
                      Text(username, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(bio, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: accentOrange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Modifier profil', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInterestTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestTags() {
    if (userInterests.isEmpty) {
      return Text('Aucun centre d\'intérêt', style: TextStyle(color: Colors.grey[600], fontSize: 12));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userInterests
            .map((interest) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: secondaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: secondaryBlue.withOpacity(0.3))),
                  child: Text(interest, style: const TextStyle(color: secondaryBlue, fontSize: 11, fontWeight: FontWeight.w500)),
                ))
            .toList(),
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
          Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: accentOrange,
              indicatorWeight: 2,
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(text: 'Mes astuces (${userProposals.length})'),
                const Tab(text: 'Évaluations'),
              ],
            ),
          ),
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
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
          Icon(Icons.lightbulb_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Aucune astuce pour le moment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text('Commencez à partager vos astuces !', style: TextStyle(fontSize: 12, color: Colors.grey[500]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addNewProposal,
            style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Ajouter une astuce', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(ProposalItem proposal, int index) {
    return GestureDetector(
      onTap: () => _openProposal(proposal),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: proposal.color, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
              child: Stack(children: [
                _getStatusBadge(proposal.status),
                Positioned(
                  top: 6,
                  left: 6,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
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
                        child: Row(children: [const Icon(Icons.edit, size: 16, color: primaryBlue), const SizedBox(width: 6), const Text('Modifier', style: TextStyle(fontSize: 12))]),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(children: [const Icon(Icons.delete, size: 16, color: Colors.red), const SizedBox(width: 6), const Text('Supprimer', style: TextStyle(fontSize: 12))]),
                      ),
                    ],
                  ),
                ),
                const Center(child: Icon(Icons.restaurant, color: Colors.white, size: 24)),
              ]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(proposal.title, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryBlue, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (proposal.status == ProposalStatus.aiValidated && proposal.averageRating != null)
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text("${proposal.averageRating!.toStringAsFixed(1)}/5", style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ]),
              ]),
            ),
          ),
        ]),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEvaluationsContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildHistoryItem(icon: Icons.star, title: 'Mes évaluations', count: 0, description: 'Consultez tous les avis que vous avez laissés', onTap: _openEvaluations),
      ]),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: secondaryBlue.withOpacity(0.2))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: secondaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: secondaryBlue, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryBlue, fontSize: 14)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(10)), child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 3),
              Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
        ]),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.lock_outline, color: primaryBlue), title: const Text('Changer mot de passe'), trailing: const Icon(Icons.chevron_right), onTap: _changePassword),
          ListTile(leading: const Icon(Icons.notifications_outlined, color: primaryBlue), title: const Text('Gérer notifications'), trailing: const Icon(Icons.chevron_right), onTap: _manageNotifications),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)), trailing: const Icon(Icons.chevron_right, color: Colors.red), onTap: _logout),
        ]),
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
      userProposals.add(ProposalItem('Nouvelle Recette', Colors.indigo[400]!, ProposalStatus.pending, null));
    });
  }

  void _deleteProposal(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer l\'astuce'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette astuce ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                setState(() {
                  userProposals.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Astuce supprimée'), backgroundColor: Colors.red));
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _editProposal(int index) {}
  void _openProposal(ProposalItem proposal) {}
  void _openEvaluations() {}

  void _changePassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
  }

  void _manageNotifications() {
    Navigator.pop(context);
  }

  void _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Se déconnecter', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
    if (confirm == true) {
      await storage.deleteAll();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déconnecté avec succès')));
    }
  }
}

class ProposalItem {
  final String title;
  final Color color;
  final ProposalStatus status;
  final double? averageRating;
  ProposalItem(this.title, this.color, this.status, this.averageRating);
}

enum ProposalStatus { pending, aiValidated, modValidated }
