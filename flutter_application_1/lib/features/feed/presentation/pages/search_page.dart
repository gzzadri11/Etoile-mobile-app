library;

/// Page de recherche (landing page) avec filtres secteur/ville.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';

/// Search / landing page — filtres secteur pour chercheurs.
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

  void _onSearch() {
    final queryParams = <String, String>{};
    if (_selectedSector != null) {
      queryParams['sector'] = _selectedSector!;
    }
    if (_selectedSpecialty != null) {
      queryParams['specialty'] = _selectedSpecialty!;
    }
    context.go(
      Uri(path: AppRoutes.feed, queryParameters: queryParams).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: AppColors.primaryYellow,
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
                    'Sélectionnez un secteur pour découvrir les offres en Île-de-France',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg * 2),

            // Sector filter
            Text(
              'Secteur d\'activité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            DropdownButtonFormField<String>(
              initialValue: _selectedSector,
              decoration: InputDecoration(
                labelText: 'Tous les secteurs',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
              items: SectorConstants.sectorOptions.map((sector) {
                return DropdownMenuItem(
                  value: sector,
                  child: Text(SectorConstants.sectorLabels[sector]!),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selectedSector = value;
                _selectedSpecialty = null;
              }),
            ),

            // Specialty dropdown (conditional on sector)
            if (_selectedSector != null &&
                SectorConstants.getSpecialtiesForSector(_selectedSector).isNotEmpty) ...[
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
                items: SectorConstants.getSpecialtiesForSector(_selectedSector).map((spec) {
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(SectorConstants.getSpecialtyLabel(spec)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSpecialty = value),
              ),
            ],

            const SizedBox(height: AppTheme.spaceLg),

            // Location indicator (fixed for beta)
            Text(
              'Localisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppColors.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Île-de-France',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Zone bêta — bientôt d\'autres régions',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.greyWarm,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

