import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';

/// Search / landing page (beta: sector filter + IdF location).
///
/// Users land here instead of the feed. They select a sector and
/// tap "Rechercher" to browse videos filtered by sector.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _selectedSector;

  static const List<String> _sectorOptions = [
    'commerce_vente',
    'restauration_hotellerie',
  ];

  static const Map<String, String> _sectorLabels = {
    'commerce_vente': 'Commerce / Vente',
    'restauration_hotellerie': 'Restauration / Hotellerie',
  };

  void _onSearch() {
    final queryParams = <String, String>{};
    if (_selectedSector != null) {
      queryParams['sector'] = _selectedSector!;
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

            // Illustration / welcome
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/mascotte.png',
                    height: 120,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.search,
                      size: 80,
                      color: AppColors.primaryYellow,
                    ),
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
                    'Selectionnez un secteur pour decouvrir les offres en Ile-de-France',
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
              'Secteur d\'activite',
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
              items: _sectorOptions.map((sector) {
                return DropdownMenuItem(
                  value: sector,
                  child: Text(_sectorLabels[sector]!),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSector = value),
            ),

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
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ile-de-France',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Zone beta — bientot d\'autres regions',
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
              child: TextButton(
                onPressed: () => context.go(AppRoutes.feed),
                child: const Text('Parcourir tout le feed'),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),
          ],
        ),
      ),
    );
  }
}
