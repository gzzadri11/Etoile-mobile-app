import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/city_autocomplete_field.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../../data/models/seeker_profile_model.dart';
import '../bloc/profile_bloc.dart';

/// Page for editing seeker profile (beta: alternance IdF)
class EditSeekerProfilePage extends StatefulWidget {
  const EditSeekerProfilePage({super.key});

  @override
  State<EditSeekerProfilePage> createState() => _EditSeekerProfilePageState();
}

class _EditSeekerProfilePageState extends State<EditSeekerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _schoolController;

  String? _selectedAge;
  String? _selectedStudyLevel;
  String? _selectedDomain;
  String? _selectedCity;

  bool _isInitialized = false;

  static const List<String> _studyLevelOptions = [
    'sans_diplome',
    'cap_bep',
    'bac',
    'bac+1',
    'bac+2',
    'bac+3',
    'bac+4',
    'bac+5',
    'bac+8',
  ];

  static const Map<String, String> _studyLevelLabels = {
    'sans_diplome': 'Sans diplome',
    'cap_bep': 'CAP / BEP',
    'bac': 'Bac',
    'bac+1': 'Bac+1',
    'bac+2': 'Bac+2 (BTS, DUT)',
    'bac+3': 'Bac+3 (Licence)',
    'bac+4': 'Bac+4 (Master 1)',
    'bac+5': 'Bac+5 (Master 2, Ingenieur)',
    'bac+8': 'Bac+8 (Doctorat)',
  };

  static const List<String> _domainOptions = [
    'commerce_vente',
    'restauration_hotellerie',
  ];

  static const Map<String, String> _domainLabels = {
    'commerce_vente': 'Commerce / Vente',
    'restauration_hotellerie': 'Restauration / Hotellerie',
  };

  static final List<String> _ageOptions =
      List.generate(45, (i) => '${i + 16}');

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _schoolController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(SeekerProfile profile) {
    if (_isInitialized) return;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName ?? '';
    _schoolController.text = profile.school ?? '';
    _selectedAge = profile.age;
    _selectedStudyLevel = _studyLevelOptions.contains(profile.studyLevel)
        ? profile.studyLevel
        : null;
    _selectedDomain =
        _domainOptions.contains(profile.domain) ? profile.domain : null;
    _selectedCity = profile.city;

    _isInitialized = true;
  }

  void _onSave(SeekerProfile currentProfile) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: _selectedAge,
      city: _selectedCity ?? '',
      school: _schoolController.text.trim(),
      studyLevel: _selectedStudyLevel,
      domain: _selectedDomain,
    );

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(seekerProfile: updatedProfile),
        );
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
          _initializeFromProfile(profile);

          final isSaving = state is ProfileSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Identity section ---
                  _buildSectionTitle('Identite'),
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

                  DropdownButtonFormField<String>(
                    initialValue: _selectedAge,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _ageOptions.map((age) {
                      return DropdownMenuItem(
                        value: age,
                        child: Text('$age ans'),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() => _selectedAge = value),
                    validator: (v) => v == null ? 'Champ requis' : null,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // --- Studies section ---
                  _buildSectionTitle('Etudes'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _schoolController,
                    label: 'Ecole / Etablissement',
                    prefixIcon: Icons.school_outlined,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedStudyLevel,
                    decoration: InputDecoration(
                      labelText: 'Niveau d\'etude',
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _studyLevelOptions.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(_studyLevelLabels[level]!),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) =>
                            setState(() => _selectedStudyLevel = value),
                    validator: (v) => v == null ? 'Champ requis' : null,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // --- Location section ---
                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'Ile-de-France uniquement',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  CityAutocompleteField(
                    initialValue: _selectedCity,
                    label: 'Ville',
                    onCitySelected: (city) {
                      _selectedCity = city;
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // --- Domain section ---
                  _buildSectionTitle('Domaine recherche'),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedDomain,
                    decoration: InputDecoration(
                      labelText: 'Domaine',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: _domainOptions.map((domain) {
                      return DropdownMenuItem(
                        value: domain,
                        child: Text(_domainLabels[domain]!),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() => _selectedDomain = value),
                    validator: (v) => v == null ? 'Champ requis' : null,
                  ),

                  const SizedBox(height: AppTheme.spaceLg * 1.5),

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
