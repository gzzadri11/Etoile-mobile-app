import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../../data/models/seeker_profile_model.dart';
import '../bloc/profile_bloc.dart';

/// Page for editing seeker profile
class EditSeekerProfilePage extends StatefulWidget {
  const EditSeekerProfilePage({super.key});

  @override
  State<EditSeekerProfilePage> createState() => _EditSeekerProfilePageState();
}

class _EditSeekerProfilePageState extends State<EditSeekerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _regionController;
  late TextEditingController _postalCodeController;
  late TextEditingController _bioController;

  String? _selectedAvailability;
  String? _selectedExperience;
  List<String> _selectedCategories = [];
  List<String> _selectedContractTypes = [];

  bool _isInitialized = false;

  final List<String> _availabilityOptions = [
    'immediate',
    '1_week',
    '2_weeks',
    '1_month',
    '3_months',
  ];

  final Map<String, String> _availabilityLabels = {
    'immediate': 'Immediate',
    '1_week': 'Sous 1 semaine',
    '2_weeks': 'Sous 2 semaines',
    '1_month': 'Sous 1 mois',
    '3_months': 'Sous 3 mois',
  };

  final List<String> _experienceOptions = [
    'student',
    'junior',
    'intermediate',
    'senior',
    'expert',
  ];

  final Map<String, String> _experienceLabels = {
    'student': 'Etudiant / Stage',
    'junior': 'Junior (0-2 ans)',
    'intermediate': 'Intermediaire (3-5 ans)',
    'senior': 'Senior (5-10 ans)',
    'expert': 'Expert (10+ ans)',
  };

  final List<String> _contractTypeOptions = [
    'cdi',
    'cdd',
    'interim',
    'freelance',
    'alternance',
    'stage',
  ];

  final Map<String, String> _contractTypeLabels = {
    'cdi': 'CDI',
    'cdd': 'CDD',
    'interim': 'Interim',
    'freelance': 'Freelance',
    'alternance': 'Alternance',
    'stage': 'Stage',
  };

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _regionController = TextEditingController();
    _postalCodeController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(SeekerProfile profile) {
    if (_isInitialized) return;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName ?? '';
    _phoneController.text = profile.phone ?? '';
    _cityController.text = profile.city ?? '';
    _regionController.text = profile.region ?? '';
    _postalCodeController.text = profile.postalCode ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedAvailability = profile.availability;
    _selectedExperience = profile.experienceLevel;
    _selectedCategories = List.from(profile.categories);
    _selectedContractTypes = List.from(profile.contractTypes);

    _isInitialized = true;
  }

  void _onSave(SeekerProfile currentProfile) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      region: _regionController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      bio: _bioController.text.trim(),
      availability: _selectedAvailability,
      experienceLevel: _selectedExperience,
      categories: _selectedCategories,
      contractTypes: _selectedContractTypes,
      profileComplete: _isProfileComplete(),
    );

    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(seekerProfile: updatedProfile),
    );
  }

  bool _isProfileComplete() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _selectedCategories.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
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

          if (state is! SeekerProfileLoaded) {
            return const Center(child: Text('Profil non disponible'));
          }

          final profile = state.profile;
          final categories = state.categories;

          _initializeFromProfile(profile);

          final isSaving = state is ProfileSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal info section
                  _buildSectionTitle('Informations personnelles'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _firstNameController,
                    label: 'Prenom',
                    prefixIcon: Icons.person_outline,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    prefixIcon: Icons.person_outline,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _phoneController,
                    label: 'Telephone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: !isSaving,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Location section
                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _cityController,
                    label: 'Ville',
                    prefixIcon: Icons.location_city_outlined,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: EtoileTextField(
                          controller: _regionController,
                          label: 'Region',
                          enabled: !isSaving,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: EtoileTextField(
                          controller: _postalCodeController,
                          label: 'Code postal',
                          keyboardType: TextInputType.number,
                          enabled: !isSaving,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Categories section
                  _buildSectionTitle('Secteurs recherches'),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'Selectionnez jusqu\'a 3 secteurs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  Wrap(
                    spacing: AppTheme.spaceSm,
                    runSpacing: AppTheme.spaceSm,
                    children: categories.map((cat) {
                      final slug = cat['slug'] as String;
                      final name = cat['name'] as String;
                      final isSelected = _selectedCategories.contains(slug);

                      return FilterChip(
                        label: Text(name),
                        selected: isSelected,
                        onSelected: isSaving
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    if (_selectedCategories.length < 3) {
                                      _selectedCategories.add(slug);
                                    }
                                  } else {
                                    _selectedCategories.remove(slug);
                                  }
                                });
                              },
                        selectedColor: AppColors.tagBackground,
                        checkmarkColor: AppColors.primaryOrange,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Contract types section
                  _buildSectionTitle('Types de contrat'),
                  const SizedBox(height: AppTheme.spaceMd),

                  Wrap(
                    spacing: AppTheme.spaceSm,
                    runSpacing: AppTheme.spaceSm,
                    children: _contractTypeOptions.map((type) {
                      final isSelected = _selectedContractTypes.contains(type);

                      return FilterChip(
                        label: Text(_contractTypeLabels[type]!),
                        selected: isSelected,
                        onSelected: isSaving
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedContractTypes.add(type);
                                  } else {
                                    _selectedContractTypes.remove(type);
                                  }
                                });
                              },
                        selectedColor: AppColors.tagBackground,
                        checkmarkColor: AppColors.primaryOrange,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Experience section
                  _buildSectionTitle('Experience'),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    value: _selectedExperience,
                    decoration: InputDecoration(
                      labelText: 'Niveau d\'experience',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _experienceOptions.map((exp) {
                      return DropdownMenuItem(
                        value: exp,
                        child: Text(_experienceLabels[exp]!),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedExperience = value;
                            });
                          },
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Availability section
                  _buildSectionTitle('Disponibilite'),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    value: _selectedAvailability,
                    decoration: InputDecoration(
                      labelText: 'Disponible',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _availabilityOptions.map((avail) {
                      return DropdownMenuItem(
                        value: avail,
                        child: Text(_availabilityLabels[avail]!),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAvailability = value;
                            });
                          },
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Bio section
                  _buildSectionTitle('Presentation'),
                  const SizedBox(height: AppTheme.spaceMd),

                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 500,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      hintText:
                          'Decrivez-vous en quelques mots (competences, motivations...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Save button
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
