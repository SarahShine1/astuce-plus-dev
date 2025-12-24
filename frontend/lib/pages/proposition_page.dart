import 'package:flutter/material.dart';
import 'package:frontend/services/AstuceService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PropositionPage extends StatefulWidget {
  final int propositionId;
  final String? username;

  const PropositionPage({
    Key? key,
    required this.propositionId,
    required this.username,
  }) : super(key: key);

  @override
  State<PropositionPage> createState() => _PropositionPageState();
}

class _PropositionPageState extends State<PropositionPage> {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  final AstuceService _astuceService = AstuceService();
  final storage = const FlutterSecureStorage();
  
  bool isLoading = true;
  Map<String, dynamic>? propositionDetails;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'access_token');
    await _loadPropositionDetails();
  }

  Future<void> _loadPropositionDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final details = await _astuceService.getPropositionDetails(widget.propositionId);
      
      if (details != null) {
        print("📦 Proposition Details: $details");
        
        setState(() {
          propositionDetails = details;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du chargement de la proposition'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error loading proposition: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusColor(String statut) {
    switch (statut) {
      case 'acceptée':
        return 'Acceptée';
      case 'rejetée':
        return 'Rejetée';
      case 'en_revision':
        return 'En révision';
      default:
        return 'En attente';
    }
  }

  Color _getStatusIconColor(String statut) {
    switch (statut) {
      case 'acceptée':
        return Colors.green;
      case 'rejetée':
        return Colors.red;
      case 'en_revision':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Détails de la proposition'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : propositionDetails == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      _buildInfoSection(),
                      _buildStatusSection(),
                      _buildCategoriesSection(),
                      _buildTermesSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Proposition non trouvée',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final prop = propositionDetails;
    final statut = prop?['statut'] ?? 'en_attente';
    final imageUrl = prop?['image_url'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            prop?['titre'] ?? 'Sans titre',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(_getStatusColor(statut)),
            backgroundColor: _getStatusIconColor(statut).withOpacity(0.2),
            labelStyle: TextStyle(
              color: _getStatusIconColor(statut),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final prop = propositionDetails;
    final description = prop?['description'] ?? '';
    final utilisateur = prop?['utilisateur'] ?? 'Anonyme';
    final date = prop?['date'] ?? '';

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Par: $utilisateur',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Date: ${_formatDate(date)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final prop = propositionDetails;
    final statut = prop?['statut'] ?? 'en_attente';
    final raison = prop?['raison_rejet'];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusIconColor(statut),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusColor(statut),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getStatusIconColor(statut),
                ),
              ),
            ],
          ),
          if (raison != null && raison.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Raison du rejet:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    raison,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final prop = propositionDetails;
    final categories = prop?['categories'] as List? ?? [];

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map<Widget>((cat) {
                  final catName = cat is Map ? cat['nom'] ?? 'Catégorie' : cat.toString();
                  return Chip(
                    label: Text(catName),
                    backgroundColor: secondaryBlue.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermesSection() {
    final prop = propositionDetails;
    final termes = prop?['termes'] as List? ?? [];

    if (termes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Termes du dictionnaire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: termes.length,
            itemBuilder: (context, index) {
              final terme = termes[index];
              final termeName = terme is Map ? terme['terme'] ?? 'Terme' : terme.toString();
              final definition = terme is Map ? terme['definition'] ?? '' : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      termeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    if (definition.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        definition,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
