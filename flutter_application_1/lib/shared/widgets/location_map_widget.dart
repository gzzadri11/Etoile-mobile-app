library;

/// Widget carte en lecture seule avec marqueurs nommes.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../features/profile/data/models/recruiter_profile_model.dart';

/// Carte OpenStreetMap avec marqueurs (siege entreprise).
class LocationMapWidget extends StatelessWidget {
  final List<MapMarker> markers;
  final double height;
  final double zoom;

  const LocationMapWidget({
    super.key,
    required this.markers,
    this.height = 200,
    this.zoom = 13,
  });

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) return const SizedBox.shrink();

    // Center on first marker, or compute bounds
    final center = LatLng(markers.first.latitude, markers.first.longitude);
    final initialZoom = markers.length == 1 ? zoom : 6.0;

    return SizedBox(
      height: height,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: initialZoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.etoile.app',
          ),
          MarkerLayer(
            markers: markers.map((m) {
              return Marker(
                point: LatLng(m.latitude, m.longitude),
                width: 120,
                height: 50,
                child: _BuildingMarker(name: m.name),
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
    );
  }
}

class _BuildingMarker extends StatelessWidget {
  final String name;

  const _BuildingMarker({required this.name});

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
