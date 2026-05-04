library;

/// Page de recherche (landing page) avec filtres secteur/specialite/proximite.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/city_autocomplete_field.dart';
import '../../../../shared/widgets/etoile_button.dart';

/// Search / landing page — filtres secteur, specialite, proximite pour chercheurs.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SeekerSearchView();
  }
}

// ============================================================
// SEEKER SEARCH VIEW
// ============================================================
class _SeekerSearchView extends StatefulWidget {
  const _SeekerSearchView();

  @override
  State<_SeekerSearchView> createState() => _SeekerSearchViewState();
}

class _SeekerSearchViewState extends State<_SeekerSearchView> {
  String? _selectedSector;
  String? _selectedSpecialty;
  String? _selectedStudyLevel; // Task #3
  String? _selectedCity; // Task #3
  String? _selectedRhythm; // Task #3
  double? _selectedProximityKm;
  double? _userLatitude;
  double? _userLongitude;
  bool _gpsChecking = true;
  bool _gpsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  Future<void> _checkGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _gpsChecking = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _gpsChecking = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      if (mounted) {
        setState(() {
          _gpsAvailable = true;
          _gpsChecking = false;
          _userLatitude = position.latitude;
          _userLongitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('GPS error: $e');
      if (mounted) setState(() => _gpsChecking = false);
    }
  }

  void _onSearch() {
    final queryParams = <String, String>{};
    if (_selectedSector != null) {
      queryParams['sector'] = _selectedSector!;
    }
    if (_selectedSpecialty != null) {
      queryParams['specialty'] = _selectedSpecialty!;
    }
    // Task #3: Nouveaux filtres globaux
    if (_selectedStudyLevel != null) {
      queryParams['studyLevel'] = _selectedStudyLevel!;
    }
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      queryParams['city'] = _selectedCity!;
    }
    if (_selectedRhythm != null) {
      queryParams['rhythm'] = _selectedRhythm!;
    }
    if (_selectedProximityKm != null &&
        _userLatitude != null &&
        _userLongitude != null) {
      queryParams['proximityKm'] = _selectedProximityKm!.toInt().toString();
      queryParams['userLat'] = _userLatitude!.toString();
      queryParams['userLng'] = _userLongitude!.toString();
    }
    context.go(
      Uri(path: AppRoutes.feed, queryParameters: queryParams).toString(),
    );
  }

  void _showSectorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SectorPickerSheet(
        selectedSector: _selectedSector,
        onSectorSelected: (sector) {
          setState(() {
            _selectedSector = sector;
            _selectedSpecialty = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialties =
        SectorConstants.getSpecialtiesForSector(_selectedSector);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spaceLg),

            // Welcome illustration
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.search,
                    size: 80,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    'Trouvez votre alternance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'Sélectionnez un secteur pour découvrir les offres',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg * 2),

            // --- Sector picker (same as feed filters) ---
            Text(
              'Secteur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5)),
              ),
              title: Text(
                _selectedSector != null
                    ? SectorConstants.getSectorLabel(_selectedSector)
                    : 'Tous les secteurs',
                style: TextStyle(
                  color: _selectedSector != null ? null : AppColors.textSecondary,
                ),
              ),
              trailing: _selectedSector != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedSector = null;
                          _selectedSpecialty = null;
                        });
                      },
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _showSectorPicker,
            ),

            // --- Specialty chips (conditional) ---
            if (specialties.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                'Spécialité',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Wrap(
                spacing: AppTheme.spaceSm,
                runSpacing: AppTheme.spaceSm,
                children: specialties.map((spec) {
                  final isSelected = _selectedSpecialty == spec;
                  return FilterChip(
                    label: Text(SectorConstants.getSpecialtyLabel(spec)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialty = selected ? spec : null;
                      });
                    },
                    selectedColor: AppColors.accentBg,
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
            ],

            // --- Task #3: Study Level filter ---
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Niveau d\'études',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5)),
              ),
              title: Text(
                _selectedStudyLevel != null
                    ? SectorConstants.studyLevelLabels[_selectedStudyLevel]!
                    : 'Tous les niveaux',
                style: TextStyle(
                  color: _selectedStudyLevel != null ? null : AppColors.textSecondary,
                ),
              ),
              trailing: _selectedStudyLevel != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedStudyLevel = null;
                        });
                      },
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Niveau d\'études',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        ...SectorConstants.studyLevelOptions.map((level) {
                          return ListTile(
                            title: Text(SectorConstants.studyLevelLabels[level]!),
                            trailing: _selectedStudyLevel == level
                                ? const Icon(Icons.check, color: AppColors.accent)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedStudyLevel = level;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }),
                        const SizedBox(height: AppTheme.spaceSm),
                      ],
                    ),
                  ),
                );
              },
            ),

            // --- Task #3: City filter ---
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Ville',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            CityAutocompleteField(
              initialValue: _selectedCity,
              onCitySelected: (cityName, lat, lng) {
                setState(() {
                  _selectedCity = cityName;
                });
              },
              label: 'Rechercher une ville',
            ),

            // --- Task #3: Rhythm filter ---
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Rythme d\'alternance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Wrap(
              spacing: AppTheme.spaceSm,
              runSpacing: AppTheme.spaceSm,
              children: rhythmShortToFull.entries.map((entry) {
                final code = entry.key;
                final label = entry.value;
                final isSelected = _selectedRhythm == code;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRhythm = selected ? code : null;
                    });
                  },
                  selectedColor: AppColors.accentBg,
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
            ),

            // --- Proximity section (same as feed filters) ---
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'À proximité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            if (_gpsChecking)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppTheme.spaceSm),
                    Text('Localisation en cours...'),
                  ],
                ),
              )
            else if (!_gpsAvailable)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                child: Row(
                  children: [
                    const Icon(Icons.location_off,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      'Activez la localisation pour filtrer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: AppTheme.spaceSm,
                runSpacing: AppTheme.spaceSm,
                children: [5.0, 10.0, 15.0, 25.0, 50.0].map((km) {
                  final isSelected = _selectedProximityKm == km;
                  return FilterChip(
                    label: Text('${km.toInt()} km'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedProximityKm = selected ? km : null;
                      });
                    },
                    selectedColor: AppColors.accentBg,
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),

            const SizedBox(height: AppTheme.spaceLg * 2),

            // Search button
            EtoileButton(
              label: 'Rechercher',
              onPressed: _onSearch,
              icon: Icons.search,
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Browse all link
            Center(
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.feed),
                icon: const Icon(Icons.explore),
                label: const Text('Parcourir tout le feed'),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),
          ],
        ),
      ),
    );
  }
}

/// Searchable sector picker bottom sheet (shared with feed_page.dart)
class _SectorPickerSheet extends StatefulWidget {
  final String? selectedSector;
  final ValueChanged<String> onSectorSelected;

  const _SectorPickerSheet({
    required this.selectedSector,
    required this.onSectorSelected,
  });

  @override
  State<_SectorPickerSheet> createState() => _SectorPickerSheetState();
}

class _SectorPickerSheetState extends State<_SectorPickerSheet> {
  final _searchController = TextEditingController();
  List<String> _filtered = SectorConstants.sectorOptions;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = SectorConstants.sectorOptions;
      } else {
        _filtered = SectorConstants.sectorOptions.where((code) {
          final label = SectorConstants.getSectorLabel(code).toLowerCase();
          return label.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Text(
                  'Choisir un secteur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un secteur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spaceSm),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final code = _filtered[index];
                    final isSelected = code == widget.selectedSector;
                    return ListTile(
                      title: Text(SectorConstants.getSectorLabel(code)),
                      trailing: isSelected
                          ? const Icon(Icons.check,
                              color: AppColors.accent)
                          : null,
                      selected: isSelected,
                      onTap: () => widget.onSectorSelected(code),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
