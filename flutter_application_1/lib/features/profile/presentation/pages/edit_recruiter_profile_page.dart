import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../../../../shared/widgets/location_picker_widget.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../bloc/profile_bloc.dart';

/// Page for editing recruiter company profile
class EditRecruiterProfilePage extends StatefulWidget {
  const EditRecruiterProfilePage({super.key});

  @override
  State<EditRecruiterProfilePage> createState() =>
      _EditRecruiterProfilePageState();
}

class _EditRecruiterProfilePageState extends State<EditRecruiterProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;

  String? _selectedSector;
  String? _selectedCompanySize;

  // Logo state
  Uint8List? _pickedLogoBytes;
  String? _pickedLogoExtension;
  String? _existingLogoUrl;

  // Cover state
  Uint8List? _pickedCoverBytes;
  String? _pickedCoverExtension;
  String? _existingCoverUrl;

  // Map markers
  List<MapMarker> _mapMarkers = [];

  // Document upload state
  Uint8List? _pickedDocBytes;
  String? _pickedDocExtension;
  String? _pickedDocType;
  bool _isUploadingDoc = false;

  bool _isInitialized = false;

  // Sectors d'activite
  static const List<String> _sectorOptions = [
    'BTP',
    'Informatique / Tech',
    'Commerce / Distribution',
    'Sante / Medical',
    'Restauration / Hotellerie',
    'Transport / Logistique',
    'Industrie / Production',
    'Finance / Banque / Assurance',
    'Education / Formation',
    'Services aux entreprises',
    'Immobilier',
    'Communication / Marketing',
    'Agriculture / Agroalimentaire',
    'Energie / Environnement',
    'Art / Culture / Spectacle',
    'Autre',
  ];

  // Taille entreprise
  static const Map<String, String> _companySizeLabels = {
    '1-10': '1 a 10 salaries',
    '11-50': '11 a 50 salaries',
    '51-200': '51 a 200 salaries',
    '201-500': '201 a 500 salaries',
    '500+': 'Plus de 500 salaries',
  };

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(RecruiterProfile profile) {
    if (_isInitialized) return;

    _companyNameController.text = profile.companyName;
    _descriptionController.text = profile.description ?? '';
    _websiteController.text = profile.website ?? '';
    _selectedSector = _sectorOptions.contains(profile.sector)
        ? profile.sector
        : null;
    _selectedCompanySize = _companySizeLabels.containsKey(profile.companySize)
        ? profile.companySize
        : null;
    _existingLogoUrl = profile.logoUrl;
    _existingCoverUrl = profile.coverUrl;
    _mapMarkers = List.from(profile.mapMarkers);

    _isInitialized = true;
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();

    setState(() {
      _pickedLogoBytes = bytes;
      _pickedLogoExtension = (ext == 'png') ? 'png' : 'jpeg';
    });
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();

    setState(() {
      _pickedCoverBytes = bytes;
      _pickedCoverExtension = (ext == 'png') ? 'png' : 'jpeg';
    });
  }

  Future<void> _pickDocument() async {
    // Show bottom sheet to select document type
    final docType = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de document',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Extrait Kbis'),
              onTap: () => Navigator.pop(ctx, 'Kbis'),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Carte professionnelle'),
              onTap: () => Navigator.pop(ctx, 'Carte professionnelle'),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Autre justificatif'),
              onTap: () => Navigator.pop(ctx, 'Autre'),
            ),
            const SizedBox(height: AppTheme.spaceSm),
          ],
        ),
      ),
    );

    if (docType == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();

    setState(() {
      _pickedDocBytes = bytes;
      _pickedDocExtension = (ext == 'png') ? 'png' : 'jpeg';
      _pickedDocType = docType;
    });
  }

  Future<void> _uploadDocument() async {
    if (_pickedDocBytes == null) return;

    setState(() => _isUploadingDoc = true);

    try {
      final repo = GetIt.I<ProfileRepository>();
      await repo.uploadDocument(
        _pickedDocBytes!,
        _pickedDocExtension ?? 'jpeg',
        documentType: _pickedDocType ?? 'Autre',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document envoye avec succes'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload profile to show updated document status
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
        setState(() {
          _pickedDocBytes = null;
          _pickedDocExtension = null;
          _pickedDocType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur upload document: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
  }

  Future<void> _onSave(RecruiterProfile currentProfile) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = GetIt.I<ProfileRepository>();

    // Upload logo if a new one was picked
    String? logoUrl = currentProfile.logoUrl;
    if (_pickedLogoBytes != null) {
      try {
        logoUrl = await repo.uploadLogo(
          _pickedLogoBytes!,
          _pickedLogoExtension ?? 'jpeg',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur upload logo: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    // Upload cover if a new one was picked
    String? coverUrl = currentProfile.coverUrl;
    if (_pickedCoverBytes != null) {
      try {
        coverUrl = await repo.uploadCover(
          _pickedCoverBytes!,
          _pickedCoverExtension ?? 'jpeg',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur upload couverture: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    final updatedProfile = currentProfile.copyWith(
      companyName: _companyNameController.text.trim(),
      description: _descriptionController.text.trim(),
      website: _websiteController.text.trim(),
      sector: _selectedSector,
      companySize: _selectedCompanySize,
      mapMarkers: _mapMarkers,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
    );

    if (mounted) {
      context.read<ProfileBloc>().add(
            ProfileUpdateRequested(recruiterProfile: updatedProfile),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil entreprise'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis a jour'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! RecruiterProfileLoaded) {
            return const Center(child: Text('Profil non disponible'));
          }

          final profile = state.profile;
          _initializeFromProfile(profile);

          final isSaving = state is ProfileSaving;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Cover + Logo header ===
                  _buildHeaderSection(isSaving),
                  const SizedBox(height: AppTheme.spaceLg),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                  // === Informations entreprise ===
                  _buildSectionTitle('Informations entreprise'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _companyNameController,
                    label: 'Nom de l\'entreprise',
                    prefixIcon: Icons.business,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _websiteController,
                    label: 'Site web (optionnel)',
                    prefixIcon: Icons.language,
                    keyboardType: TextInputType.url,
                    enabled: !isSaving,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Secteur d'activite ===
                  _buildSectionTitle('Secteur d\'activite'),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedSector,
                    decoration: InputDecoration(
                      labelText: 'Selectionnez un secteur',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _sectorOptions.map((sector) {
                      return DropdownMenuItem(
                        value: sector,
                        child: Text(sector),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedSector = value;
                            });
                          },
                    validator: (v) => v == null ? 'Champ requis' : null,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Taille entreprise ===
                  _buildSectionTitle('Taille de l\'entreprise'),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCompanySize,
                    decoration: InputDecoration(
                      labelText: 'Nombre de salaries',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _companySizeLabels.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCompanySize = value;
                            });
                          },
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Localisations sur la carte ===
                  _buildSectionTitle('Localisations'),
                  const SizedBox(height: AppTheme.spaceMd),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LocationPickerWidget(
                      initialMarkers: _mapMarkers,
                      onMarkersChanged: (markers) {
                        setState(() {
                          _mapMarkers = markers;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Description ===
                  _buildSectionTitle('Description de l\'entreprise'),
                  const SizedBox(height: AppTheme.spaceMd),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      hintText:
                          'Decrivez votre entreprise, votre culture, vos valeurs...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Document justificatif ===
                  _buildDocumentSection(profile),

                  const SizedBox(height: AppTheme.spaceLg),

                  // === Bouton sauvegarder ===
                  EtoileButton(
                    label: 'Enregistrer',
                    onPressed: isSaving ? null : () => _onSave(profile),
                    isLoading: isSaving,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(bool isSaving) {
    final hasPickedLogo = _pickedLogoBytes != null;
    final hasExistingLogo =
        _existingLogoUrl != null && _existingLogoUrl!.isNotEmpty;
    final hasPickedCover = _pickedCoverBytes != null;
    final hasExistingCover =
        _existingCoverUrl != null && _existingCoverUrl!.isNotEmpty;

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover photo
          GestureDetector(
            onTap: isSaving ? null : _pickCover,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                image: hasPickedCover
                    ? DecorationImage(
                        image: MemoryImage(_pickedCoverBytes!),
                        fit: BoxFit.cover,
                      )
                    : hasExistingCover
                        ? DecorationImage(
                            image: NetworkImage(_existingCoverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: (!hasPickedCover && !hasExistingCover)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_outlined,
                              size: 36, color: AppColors.greyWarm),
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            'Ajouter une couverture',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.greyWarm),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          // Cover edit badge
          Positioned(
            top: AppTheme.spaceSm,
            right: AppTheme.spaceSm,
            child: GestureDetector(
              onTap: isSaving ? null : _pickCover,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.edit, size: 18, color: AppColors.white),
              ),
            ),
          ),
          // Logo
          Positioned(
            bottom: 0,
            left: AppTheme.spaceMd,
            child: GestureDetector(
              onTap: isSaving ? null : _pickLogo,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.tagBackground,
                      backgroundImage: hasPickedLogo
                          ? MemoryImage(_pickedLogoBytes!)
                          : hasExistingLogo
                              ? NetworkImage(_existingLogoUrl!)
                              : null,
                      child: (!hasPickedLogo && !hasExistingLogo)
                          ? const Icon(Icons.business,
                              size: 36, color: AppColors.greyWarm)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDocumentSection(RecruiterProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Document de verification'),
        const SizedBox(height: AppTheme.spaceSm),

        // Verified state
        if (profile.isVerified) ...[
          _buildDocStatusCard(
            icon: Icons.verified,
            iconColor: AppColors.success,
            borderColor: AppColors.success,
            title: 'Compte verifie',
            subtitle: profile.verifiedAt != null
                ? 'Verifie le ${_formatDate(profile.verifiedAt!)}'
                : 'Votre compte est verifie',
          ),
        ]
        // Rejected state
        else if (profile.isRejected) ...[
          _buildDocStatusCard(
            icon: Icons.error,
            iconColor: AppColors.error,
            borderColor: AppColors.error,
            title: 'Verification rejetee',
            subtitle: profile.rejectionReason ?? 'Motif non precise',
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Vous pouvez soumettre un nouveau document.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _buildDocumentPicker(),
        ]
        // Document already uploaded, pending review
        else if (profile.documentUrl != null &&
            profile.documentUrl!.isNotEmpty &&
            _pickedDocBytes == null) ...[
          _buildDocStatusCard(
            icon: Icons.hourglass_top,
            iconColor: AppColors.warning,
            borderColor: AppColors.warning,
            title:
                'Document envoye${profile.documentType != null ? ' (${profile.documentType})' : ''}',
            subtitle: profile.documentUploadedAt != null
                ? 'Envoye le ${_formatDate(profile.documentUploadedAt!)} — En attente de verification'
                : 'En attente de verification par un administrateur',
          ),
        ]
        // No document yet
        else ...[
          if (_pickedDocBytes == null) ...[
            Text(
              'Uploadez un justificatif (Kbis, carte pro) pour faire verifier votre compte.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
          ],
          _buildDocumentPicker(),
        ],
      ],
    );
  }

  Widget _buildDocStatusCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      children: [
        // Preview if picked
        if (_pickedDocBytes != null) ...[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.success.withAlpha(80)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _pickedDocBytes!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pickedDocType ?? 'Document',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          'Pret a envoyer',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _pickedDocBytes = null;
                      _pickedDocExtension = null;
                      _pickedDocType = null;
                    }),
                    icon: const Icon(Icons.close, color: AppColors.greyWarm),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploadingDoc ? null : _uploadDocument,
              icon: _isUploadingDoc
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                  _isUploadingDoc ? 'Envoi en cours...' : 'Envoyer le document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Choisir un fichier'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
