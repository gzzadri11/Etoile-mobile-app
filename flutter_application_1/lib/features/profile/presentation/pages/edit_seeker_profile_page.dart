library;

/// Page d'edition du profil chercheur.
///
/// Formulaire complet : identite, date de naissance, photo,
/// ecole, niveau d'etudes, ville (autocompletion IdF), domaine/specialite.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart' show AppRoutes, AppRouter;
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/circle_crop_dialog.dart';
import '../../../../shared/widgets/city_autocomplete_field.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../../../../shared/widgets/mascotte_message.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../data/models/seeker_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
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
  String? _selectedSpecialty;
  String? _selectedCity;

  Uint8List? _pickedPhotoBytes;
  String? _pickedPhotoExtension;
  String? _existingPhotoUrl;

  bool _isInitialized = false;
  bool _dismissedMascotte = false;

  /// Calculates real-time profile completion percentage.
  /// Seeker: photo(20) + identite(prenom+nom+age)(20) + etudes(ecole+niveau)(20) + localisation(ville)(20) + domaine(20)
  int get _completionPercentage {
    int pct = 0;
    // Photo (20%)
    if (_pickedPhotoBytes != null || (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty)) {
      pct += 20;
    }
    // Identite: prenom + nom + age (all 3 required for 20%)
    final hasFirstName = _firstNameController.text.trim().isNotEmpty;
    final hasLastName = _lastNameController.text.trim().isNotEmpty;
    final hasAge = _selectedAge != null;
    if (hasFirstName && hasLastName && hasAge) pct += 20;
    // Etudes: ecole + niveau (both required for 20%)
    final hasSchool = _schoolController.text.trim().isNotEmpty;
    final hasStudyLevel = _selectedStudyLevel != null;
    if (hasSchool && hasStudyLevel) pct += 20;
    // Localisation: ville (required for 20%)
    if (_selectedCity != null && _selectedCity!.isNotEmpty) pct += 20;
    // Domaine (required for 20%)
    if (_selectedDomain != null) pct += 20;
    return pct;
  }

  static final List<String> _ageOptions =
      List.generate(45, (i) => '${i + 16}');

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _schoolController = TextEditingController();

    // Listeners to recalculate completion % in real-time
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _schoolController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFieldChanged);
    _lastNameController.removeListener(_onFieldChanged);
    _schoolController.removeListener(_onFieldChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    // Determine extension — on web, path may not have a proper extension
    String ext = picked.path.split('.').last.toLowerCase();
    if (kIsWeb || ext.length > 5 || !['png', 'jpg', 'jpeg', 'webp'].contains(ext)) {
      // On web, mimeType is available; fallback to jpeg
      final mime = picked.mimeType ?? '';
      if (mime.contains('png')) {
        ext = 'png';
      } else if (mime.contains('webp')) {
        ext = 'webp';
      } else {
        ext = 'jpeg';
      }
    }
    final allowedExt = ext == 'png' || ext == 'webp' ? ext : 'jpeg';

    if (!mounted) return;

    // Open circular crop dialog
    final croppedBytes = await CircleCropDialog.show(context, bytes);
    if (croppedBytes == null) return; // User cancelled

    setState(() {
      _pickedPhotoBytes = croppedBytes;
      _pickedPhotoExtension = allowedExt;
    });
  }

  void _initializeFromProfile(SeekerProfile profile) {
    if (_isInitialized) return;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName ?? '';
    _schoolController.text = profile.school ?? '';
    _selectedAge = profile.age;
    _selectedStudyLevel = SectorConstants.studyLevelOptions.contains(profile.studyLevel)
        ? profile.studyLevel
        : null;
    _selectedDomain =
        SectorConstants.sectorOptions.contains(profile.domain) ? profile.domain : null;
    _selectedSpecialty = (_selectedDomain != null &&
            SectorConstants.getSpecialtiesForSector(_selectedDomain).contains(profile.specialty))
        ? profile.specialty
        : null;
    _selectedCity = profile.city;
    _existingPhotoUrl = profile.photoUrl;

    _isInitialized = true;
  }

  Future<void> _onSave(SeekerProfile currentProfile) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? photoUrl = _existingPhotoUrl;

    // Upload new photo if picked
    if (_pickedPhotoBytes != null && _pickedPhotoExtension != null) {
      try {
        final repo = GetIt.I<ProfileRepository>();
        photoUrl = await repo.uploadSeekerPhoto(
          _pickedPhotoBytes!,
          _pickedPhotoExtension!,
        );
        _existingPhotoUrl = photoUrl;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur upload photo: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: _selectedAge,
      city: _selectedCity ?? '',
      school: _schoolController.text.trim(),
      studyLevel: _selectedStudyLevel,
      domain: _selectedDomain,
      specialty: _selectedSpecialty,
      photoUrl: photoUrl,
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
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour'),
                backgroundColor: AppColors.success,
              ),
            );
            // Gate is updated by ProfileBloc._onUpdateRequested.
            if (AppRouter.isProfileComplete) {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.search);
              }
            }
            // If incomplete, stay on page
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

          return Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _completionPercentage / 100,
                          backgroundColor: AppColors.greyLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryYellow),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      '$_completionPercentage% complet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyWarm,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Mascotte milestone message ---
                  if (!_dismissedMascotte)
                    Builder(builder: (context) {
                      final msg = MascotteMessage.forCompletion(
                        _completionPercentage,
                        onDismiss: () =>
                            setState(() => _dismissedMascotte = true),
                      );
                      return msg ?? const SizedBox.shrink();
                    }),

                  // --- Photo section ---
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isSaving ? null : _pickPhoto,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: AppColors.greyLight,
                                backgroundImage: _pickedPhotoBytes != null
                                    ? MemoryImage(_pickedPhotoBytes!)
                                    : (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty
                                        ? NetworkImage(_existingPhotoUrl!) as ImageProvider
                                        : null),
                                child: (_pickedPhotoBytes == null &&
                                        (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty))
                                    ? const Icon(Icons.person, size: 56, color: AppColors.greyMedium)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryYellow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          'Photo de profil',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (_pickedPhotoBytes == null &&
                            (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty))
                          Text(
                            'Obligatoire pour compléter votre profil',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryOrange,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // --- Identity section ---
                  _buildSectionTitle('Identité'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
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
                      labelText: 'Âge',
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
                  _buildSectionTitle('Études'),
                  const SizedBox(height: AppTheme.spaceMd),

                  EtoileTextField(
                    controller: _schoolController,
                    label: 'École / Établissement',
                    prefixIcon: Icons.school_outlined,
                    enabled: !isSaving,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedStudyLevel,
                    decoration: InputDecoration(
                      labelText: 'Niveau d\'étude',
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    items: SectorConstants.studyLevelOptions.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(SectorConstants.studyLevelLabels[level]!),
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
                    'Île-de-France uniquement',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  CityAutocompleteField(
                    initialValue: _selectedCity,
                    label: 'Ville',
                    onCitySelected: (city) {
                      setState(() {
                        _selectedCity = city;
                      });
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // --- Domain section ---
                  _buildSectionTitle('Domaine recherché'),
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
                    items: SectorConstants.sectorOptions.map((domain) {
                      return DropdownMenuItem(
                        value: domain,
                        child: Text(SectorConstants.sectorLabels[domain]!),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() {
                              _selectedDomain = value;
                              _selectedSpecialty = null;
                            }),
                    validator: (v) => v == null ? 'Champ requis' : null,
                  ),

                  // Specialty dropdown (conditional on domain)
                  if (_selectedDomain != null &&
                      SectorConstants.getSpecialtiesForSector(_selectedDomain).isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSpecialty,
                      decoration: InputDecoration(
                        labelText: 'Spécialité (optionnel)',
                        prefixIcon: const Icon(Icons.star_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      items: SectorConstants.getSpecialtiesForSector(_selectedDomain).map((spec) {
                        return DropdownMenuItem(
                          value: spec,
                          child: Text(SectorConstants.getSpecialtyLabel(spec)),
                        );
                      }).toList(),
                      onChanged: isSaving
                          ? null
                          : (value) => setState(() => _selectedSpecialty = value),
                    ),
                  ],

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
          ),
              ),
            ],
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
