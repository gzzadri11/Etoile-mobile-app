import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/data/models/recruiter_profile_model.dart';

/// Interactive map widget for adding/removing multiple named markers.
/// Markers are added via a button + address autocomplete dialog.
class LocationPickerWidget extends StatefulWidget {
  final List<MapMarker> initialMarkers;
  final ValueChanged<List<MapMarker>> onMarkersChanged;

  const LocationPickerWidget({
    super.key,
    this.initialMarkers = const [],
    required this.onMarkersChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  static const _defaultLat = 48.8566; // Paris
  static const _defaultLng = 2.3522;

  late final MapController _mapController;
  late List<MapMarker> _markers;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markers = List.from(widget.initialMarkers);
  }

  Future<void> _addMarker() async {
    final result = await showDialog<_AddMarkerResult>(
      context: context,
      builder: (ctx) => const _AddMarkerDialog(),
    );
    if (result == null) return;

    final marker = MapMarker(
      name: result.name,
      latitude: result.latitude,
      longitude: result.longitude,
    );

    setState(() {
      _markers.add(marker);
    });
    widget.onMarkersChanged(List.from(_markers));

    _mapController.move(LatLng(result.latitude, result.longitude), 13);
  }

  void _removeMarker(int index) {
    setState(() {
      _markers.removeAt(index);
    });
    widget.onMarkersChanged(List.from(_markers));
  }

  void _confirmDelete(int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'emplacement ?'),
        content: Text('Voulez-vous supprimer "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeMarker(index);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _mapController.move(const LatLng(_defaultLat, _defaultLng), 13);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _mapController.move(
          LatLng(position.latitude, position.longitude), 13);
    } catch (_) {
      _mapController.move(const LatLng(_defaultLat, _defaultLng), 13);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = _markers.isNotEmpty
        ? LatLng(_markers.first.latitude, _markers.first.longitude)
        : const LatLng(_defaultLat, _defaultLng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: _markers.isNotEmpty ? 13 : 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.etoile.app',
                  ),
                  if (_markers.isNotEmpty)
                    MarkerLayer(
                      markers: _markers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        return Marker(
                          point: LatLng(m.latitude, m.longitude),
                          width: 120,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _confirmDelete(i, m.name),
                            child: _BuildingMarkerPicker(name: m.name),
                          ),
                        );
                      }).toList(),
                    ),
                  const RichAttributionWidget(
                    alignment: AttributionAlignment.bottomRight,
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: AppTheme.spaceSm,
                right: AppTheme.spaceSm,
                child: FloatingActionButton.small(
                  heroTag: 'location_picker_my_location',
                  onPressed: _locating ? null : _goToMyLocation,
                  backgroundColor: AppColors.white,
                  child: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location,
                          color: AppColors.primaryOrange),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),

        // Add marker button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addMarker,
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Ajouter un emplacement'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryOrange,
              side: const BorderSide(color: AppColors.primaryOrange),
            ),
          ),
        ),

        // Marker chips
        if (_markers.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spaceSm),
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            children: _markers.asMap().entries.map((entry) {
              return Chip(
                avatar: const Icon(Icons.domain, size: 16,
                    color: AppColors.primaryOrange),
                label: Text(entry.value.name),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeMarker(entry.key),
                backgroundColor: AppColors.tagBackground,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Result object from the add marker dialog
// ---------------------------------------------------------------------------
class _AddMarkerResult {
  final String name;
  final double latitude;
  final double longitude;

  const _AddMarkerResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// ---------------------------------------------------------------------------
// Address suggestion from Photon API
// ---------------------------------------------------------------------------
class _AddressSuggestion {
  final String label;
  final double latitude;
  final double longitude;

  const _AddressSuggestion({
    required this.label,
    required this.latitude,
    required this.longitude,
  });
}

// ---------------------------------------------------------------------------
// Stateful dialog with address autocomplete
// ---------------------------------------------------------------------------
class _AddMarkerDialog extends StatefulWidget {
  const _AddMarkerDialog();

  @override
  State<_AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<_AddMarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  List<_AddressSuggestion> _suggestions = [];
  _AddressSuggestion? _selectedSuggestion;
  Timer? _debounce;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onAddressChanged(String query) {
    // Clear selection when user types again
    _selectedSuggestion = null;

    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchAddress(query.trim());
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() => _searching = true);

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query,
          'limit': '5',
          'lang': 'fr',
        },
      );

      final features = response.data['features'] as List? ?? [];
      final suggestions = <_AddressSuggestion>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>;
        final coords = feature['geometry']['coordinates'] as List;

        final parts = <String>[];
        if (props['housenumber'] != null) parts.add(props['housenumber'] as String);
        if (props['street'] != null) {
          parts.add(props['street'] as String);
        } else if (props['name'] != null) {
          parts.add(props['name'] as String);
        }
        if (props['postcode'] != null) parts.add(props['postcode'] as String);
        if (props['city'] != null) parts.add(props['city'] as String);
        if (props['state'] != null) parts.add(props['state'] as String);

        if (parts.isEmpty) continue;

        suggestions.add(_AddressSuggestion(
          label: parts.join(', '),
          longitude: (coords[0] as num).toDouble(),
          latitude: (coords[1] as num).toDouble(),
        ));
      }

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectSuggestion(_AddressSuggestion suggestion) {
    setState(() {
      _selectedSuggestion = suggestion;
      _addressController.text = suggestion.label;
      _suggestions = [];
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedSuggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectionnez une adresse dans la liste'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _AddMarkerResult(
        name: _nameController.text.trim(),
        latitude: _selectedSuggestion!.latitude,
        longitude: _selectedSuggestion!.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un emplacement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceLg),

                // Name field
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Ex: Siege social, Agence Lyon...',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Address field
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    hintText: 'Ex: 2 rue du Zephyr, Cesson',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _selectedSuggestion != null
                            ? const Icon(Icons.check_circle,
                                color: AppColors.success)
                            : null,
                  ),
                  onChanged: _onAddressChanged,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Champ requis' : null,
                ),

                // Suggestions list
                if (_suggestions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppColors.greyLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _suggestions[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined,
                              color: AppColors.primaryOrange, size: 20),
                          title: Text(
                            s.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => _selectSuggestion(s),
                        );
                      },
                    ),
                  ),

                if (_selectedSuggestion != null) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 16,
                            color: AppColors.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedSuggestion!.label,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppTheme.spaceLg),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_location_alt, size: 18),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Building marker widget
// ---------------------------------------------------------------------------
class _BuildingMarkerPicker extends StatelessWidget {
  final String name;

  const _BuildingMarkerPicker({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(
          Icons.domain,
          color: AppColors.primaryOrange,
          size: 28,
        ),
      ],
    );
  }
}
