import 'package:flutter/material.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/pages/change_password_page.dart';
import 'package:frontend/pages/astuce_page.dart';
import 'package:frontend/pages/proposition_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/UserService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  final UserService _userService = UserService();
  
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
  List<Map<String, dynamic>> userAstuces = [];
  List<Map<String, dynamic>> userPropositions = [];
  List<Map<String, dynamic>> userEvaluations = [];
  
  bool _isLoadingAstuces = true;
  bool _isLoadingPropositions = true;
  bool _isLoadingEvaluations = true;

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
  // Helper pour afficher image astuce/proposition avec fallback
  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.lightbulb_outline,
                color: Colors.grey[400],
                size: 40,
              ),
            ),
          );
        },
      );
    }
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.lightbulb_outline,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserAstuces();
    _loadUserPropositions();
    _loadUserEvaluations();
    
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut)
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), 
      end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic)
    );
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
          final profileData = await _userService.getProfile(accessToken);
          if (profileData != null) {
            setState(() {
              name = profileData['nom'] ?? profileData['username'] ?? 'User';
              username = '@${profileData['username']}';
              email = profileData['email'] ?? '';
              bio = profileData['bio'] ?? '';
              phone = profileData['phone'] ?? '';
              // Load avatar from profile
              if (profileData['avatar'] != null && profileData['avatar'].toString().isNotEmpty) {
                profileImagePath = profileData['avatar'];
              }
              if (profileData['centres_interet'] != null && 
                  profileData['centres_interet'].toString().isNotEmpty) {
                userInterests = profileData['centres_interet']
                    .toString()
                    .split(',')
                    .map((e) => e.trim())
                    .toList();
              }
            });
            await storage.write(key: 'user_data', value: jsonEncode(profileData));
          }
        } catch (e) {
          print('❌ Error loading profile: $e');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        name = 'Error loading profile';
        username = '@error';
      });
    }
  }

  Future<void> _loadUserAstuces() async {
    setState(() {
      _isLoadingAstuces = true;
    });
    
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        final astuces = await _userService.getUserAstuces(accessToken);
        if (astuces != null) {
          setState(() {
            userAstuces = astuces.cast<Map<String, dynamic>>();
            _isLoadingAstuces = false;
          });
          print('✅ Loaded ${userAstuces.length} astuces');
        } else {
          setState(() {
            _isLoadingAstuces = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading astuces: $e');
      setState(() {
        _isLoadingAstuces = false;
      });
    }
  }

  Future<void> _loadUserPropositions() async {
    setState(() {
      _isLoadingPropositions = true;
    });
    
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        final propositions = await _userService.getUserPropositions(accessToken);
        if (propositions != null) {
          setState(() {
            userPropositions = propositions.cast<Map<String, dynamic>>();
            _isLoadingPropositions = false;
          });
          print('✅ Loaded ${userPropositions.length} propositions');
        } else {
          setState(() {
            _isLoadingPropositions = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading propositions: $e');
      setState(() {
        _isLoadingPropositions = false;
      });
    }
  }

  Future<void> _loadUserEvaluations() async {
    setState(() {
      _isLoadingEvaluations = true;
    });
    
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        final evaluations = await _userService.getUserEvaluations(accessToken);
        if (evaluations != null) {
          setState(() {
            userEvaluations = evaluations.cast<Map<String, dynamic>>();
            _isLoadingEvaluations = false;
          });
          print('✅ Loaded ${userEvaluations.length} evaluations');
        } else {
          setState(() {
            _isLoadingEvaluations = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading evaluations: $e');
      setState(() {
        _isLoadingEvaluations = false;
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
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
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
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _showSettings
        ),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          "Mon compte",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
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
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          )
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue
                        )
                      ),
                      const SizedBox(height: 2),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14
                        )
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          bio,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                        ),
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
                  boxShadow: [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3)
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                  ),
                  child: const Text(
                    'Modifier profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    )
                  ),
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
      return Text(
        'Aucun centre d\'intérêt',
        style: TextStyle(color: Colors.grey[600], fontSize: 12)
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userInterests
            .map((interest) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: secondaryBlue.withOpacity(0.3))
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: secondaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w500
                    )
                  ),
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: accentOrange,
              indicatorWeight: 2,
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14
              ),
              tabs: [
                Tab(text: 'Mes astuces (${userAstuces.length})'),
                Tab(text: 'Propositions (${userPropositions.length})'),
                Tab(text: 'Évaluations (${userEvaluations.length})'),
              ],
            ),
          ),
          SizedBox(
            height: 400, // Fixed height for TabBarView
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAstucesContent(),
                _buildPropositionsContent(),
                _buildEvaluationsContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstucesContent() {
    if (_isLoadingAstuces) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (userAstuces.isEmpty) {
      return _buildEmptyState();
    }
    
    return SizedBox(
      height: 350, // Fixed height for GridView
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85
          ),
          itemCount: userAstuces.length,
          itemBuilder: (context, index) {
            return _buildAstuceCard(userAstuces[index]);
          },
        ),
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
          Text(
            'Aucune astuce pour le moment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            )
          ),
          const SizedBox(height: 6),
          Text(
            'Vos astuces créées apparaîtront ici',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildAstuceCard(Map<String, dynamic> astuce) {
    final bool valide = astuce['valide'] ?? false;
    final double scoreNote = (astuce['score_fiabilite'] ?? 0.0) / 20.0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AstucePage(
              astuceId: astuce['id'],
              username: username,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: valide ? Colors.green[400] : Colors.orange[400],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)
                  )
                ),
                child: Stack(
                  children: [
                    _buildImageWidget(astuce['image_url']),
                    _getStatusBadge(valide),
                  ]
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      astuce['titre'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                        fontSize: 12
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                    ),
                    if (valide && scoreNote > 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            "${scoreNote.toStringAsFixed(1)}/5",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500
                            )
                          ),
                        ]
                      ),
                  ]
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  Widget _getStatusBadge(bool valide) {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: valide ? Colors.green[100] : Colors.orange[100],
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(
          valide ? 'Validée' : 'En attente',
          style: TextStyle(
            color: valide ? Colors.green[800] : Colors.orange[800],
            fontSize: 8,
            fontWeight: FontWeight.w500
          )
        ),
      ),
    );
  }

  Widget _buildPropositionsContent() {
    if (_isLoadingPropositions) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (userPropositions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucune proposition pour le moment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]
              )
            ),
            const SizedBox(height: 6),
            Text(
              'Vos propositions créées apparaîtront ici',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      height: 350, // Fixed height for GridView
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85
          ),
          itemCount: userPropositions.length,
          itemBuilder: (context, index) {
            return _buildPropositionCard(userPropositions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPropositionCard(Map<String, dynamic> proposition) {
    final String statut = proposition['statut'] ?? 'en_attente';
    final bool accepted = statut == 'acceptée';
    final bool rejected = statut == 'rejetée';
    
    // Status color based on state
    Color statusColor = Colors.orange[400]!;
    String statusText = 'En attente';
    
    if (accepted) {
      statusColor = Colors.green[400]!;
      statusText = 'Acceptée';
    } else if (rejected) {
      statusColor = Colors.red[400]!;
      statusText = 'Rejetée';
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropositionPage(
              propositionId: proposition['id'],
              username: username,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)
                  )
                ),
                child: Stack(
                  children: [
                    _buildImageWidget(proposition['image_url']),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor.withOpacity(0.8),
                            fontSize: 8,
                            fontWeight: FontWeight.w500
                          )
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      proposition['titre'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 12
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                    ),
                    if (proposition['description'] != null && proposition['description'].toString().isNotEmpty)
                      Text(
                        proposition['description'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                      ),
                  ]
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildEvaluationsContent() {
  if (_isLoadingEvaluations) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (userEvaluations.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Aucune évaluation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            )
          ),
        ],
      ),
    );
  }
  
  return SizedBox(
    height: 350, // Fixed height for ListView
    child: ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: userEvaluations.length,
      itemBuilder: (context, index) {
        final eval = userEvaluations[index];
        // 🔥 FIX: Safely handle astuce which might be null or a map
        final astuce = eval['astuce'];
        final astuceTitle = astuce is Map<String, dynamic> 
            ? (astuce['titre'] ?? 'Astuce supprimée') 
            : 'Astuce supprimée';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: secondaryBlue,
              child: Text(
                '${eval['note'] ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            title: Text(
              astuceTitle,
              style: const TextStyle(fontWeight: FontWeight.w600)
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eval['commentaire'] != null && eval['commentaire'].toString().isNotEmpty)
                  Text(
                    eval['commentaire'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(eval['date']?.toString()),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    ),
  );
}

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: primaryBlue),
              title: const Text('Changer mot de passe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: primaryBlue),
              title: const Text('Gérer notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _manageNotifications
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red)
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: _logout
            ),
          ]
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
          initialInterests: userInterests.join(', '),  // 🆕 ADDED
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
        // 🆕 ADDED - Parse interests
        if (updatedData['interests'] != null && updatedData['interests'].toString().isNotEmpty) {
           userInterests = updatedData['interests'].toString().split(',').map((e) => e.trim()).toList();
      }
      });
      _loadUserData(); // Reload from backend
    }
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage())
    );
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red)
              )
            ),
          ],
        );
      },
    );
    
    if (confirm == true) {
      await storage.deleteAll();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnecté avec succès'))
      );
    }
  }
}