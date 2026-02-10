import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../../data/models/recruiter_profile_model.dart';
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
  late TextEditingController _locationController;

  String? _selectedSector;
  String? _selectedCompanySize;
  List<String> _locations = [];

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
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
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
    _locations = List.from(profile.locations);

    _isInitialized = true;
  }

  void _addLocation() {
    final location = _locationController.text.trim();
    if (location.isEmpty) return;
    if (_locations.contains(location)) return;

    setState(() {
      _locations.add(location);
      _locationController.clear();
    });
  }

  void _removeLocation(String location) {
    setState(() {
      _locations.remove(location);
    });
  }

  void _onSave(RecruiterProfile currentProfile) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedProfile = currentProfile.copyWith(
      companyName: _companyNameController.text.trim(),
      description: _descriptionController.text.trim(),
      website: _websiteController.text.trim(),
      sector: _selectedSector,
      companySize: _selectedCompanySize,
      locations: _locations,
    );

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(recruiterProfile: updatedProfile),
        );
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
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Form(
              key: _formKey,
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
                    value: _selectedSector,
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
                    value: _selectedCompanySize,
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

                  // === Localisations ===
                  _buildSectionTitle('Localisations'),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'Ajoutez les villes ou vous recrutez',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  Row(
                    children: [
                      Expanded(
                        child: EtoileTextField(
                          controller: _locationController,
                          label: 'Ajouter une ville',
                          prefixIcon: Icons.location_on_outlined,
                          enabled: !isSaving,
                          onSubmitted: (_) => _addLocation(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      IconButton(
                        onPressed: isSaving ? null : _addLocation,
                        icon: const Icon(Icons.add_circle),
                        color: AppColors.primaryOrange,
                        iconSize: 32,
                      ),
                    ],
                  ),

                  if (_locations.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    Wrap(
                      spacing: AppTheme.spaceSm,
                      runSpacing: AppTheme.spaceSm,
                      children: _locations.map((loc) {
                        return Chip(
                          label: Text(loc),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted:
                              isSaving ? null : () => _removeLocation(loc),
                          backgroundColor: AppColors.tagBackground,
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],

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
          );
        },
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
}
