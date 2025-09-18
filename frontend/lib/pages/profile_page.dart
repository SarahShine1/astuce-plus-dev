import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  TabController? _tabController;

  // Palette de couleurs
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      padding: const EdgeInsets.all(20.0),
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
      padding: const EdgeInsets.all(20.0),
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
                child: Text(
                  'TA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasya Aulianza',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@tasyaaauz',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
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
    final interests = ['Cuisine', 'Photographie', 'Voyages', 'Food'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) => Container(
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
          Tab(text: 'Mes astuces'),

          Tab(text: 'Évaluations'),
        ],
      ),
    );
  }

  Widget _buildAstucesContent() {
    final proposals = [
      ProposalItem('Shrimp with Garlic', 186, Colors.orange[400]!, ProposalStatus.pending),
      ProposalItem('Spicy Sausage', 503, Colors.teal[400]!, ProposalStatus.aiValidated),
      ProposalItem('Thai Basil Pork', 799, Colors.purple[400]!, ProposalStatus.modValidated),
      ProposalItem('Thai Basil Pork', 799, Colors.pink[400]!, ProposalStatus.pending),
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          return _buildProposalCard(proposals[index]);
        },
      ),
    );
  }

  Widget _buildProposalCard(ProposalItem proposal) {
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
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: proposal.color,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: _getStatusBadge(proposal.status),
              ),
            ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              '${proposal.views}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.more_horiz, color: Colors.grey[600]),
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

  void _editProfile() {
    print('Modifier profil');
  }

  void _openProposal(ProposalItem proposal) {
    print('Ouvrir proposition: ${proposal.title}');
  }



  void _openEvaluations() {
    print('Ouvrir évaluations');
  }


  void _changePassword() {
    Navigator.pop(context);
    print('Changer mot de passe');
  }

  void _manageNotifications() {
    Navigator.pop(context);
    print('Gérer notifications');
  }
}

// Classes de données
class ProposalItem {
  final String title;
  final int views;
  final Color color;
  final ProposalStatus status;

  ProposalItem(this.title, this.views, this.color, this.status);
}

enum ProposalStatus {
  pending,
  aiValidated,
  modValidated,
}