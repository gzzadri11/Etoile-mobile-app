library;

/// Champ d'autocompletion de ville filtre sur la France metropolitaine.
///
/// Utilise l'API Adresse du gouvernement francais (api-adresse.data.gouv.fr).

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Autocompletion ville France via API Adresse gouv.fr (debounce 400ms).
/// Returns the selected city display label (+ optional lat/lng) via [onCitySelected].
class CityAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final void Function(String city, double? lat, double? lng) onCitySelected;
  final String label;

  const CityAutocompleteField({
    super.key,
    this.initialValue,
    required this.onCitySelected,
    this.label = 'Ville',
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<_CitySuggestion> _suggestions = [];
  bool _searching = false;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
      _hasSelected = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String query) {
    _hasSelected = false;
    _debounce?.cancel();

    if (query.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchCity(query.trim());
    });
  }

  Future<void> _searchCity(String query) async {
    setState(() => _searching = true);

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api-adresse.data.gouv.fr/search/',
        queryParameters: {
          'q': query,
          'type': 'municipality',
          'limit': '5',
        },
      );

      final features = response.data['features'] as List? ?? [];
      final suggestions = <_CitySuggestion>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>;
        final city = props['city'] as String? ?? props['name'] as String?;
        if (city == null || city.isEmpty) continue;

        final postcode = props['postcode'] as String?;
        final ctx = props['context'] as String?;

        // Extract coordinates from GeoJSON (lon, lat)
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        final coords = geometry?['coordinates'] as List<dynamic>?;
        final double? lng = coords != null && coords.length >= 2
            ? (coords[0] as num).toDouble()
            : null;
        final double? lat = coords != null && coords.length >= 2
            ? (coords[1] as num).toDouble()
            : null;

        // Build display label: "Créteil (94000)"
        final label = StringBuffer(city);
        if (postcode != null && postcode.isNotEmpty) {
          label.write(' ($postcode)');
        }

        // Avoid duplicates
        final labelStr = label.toString();
        if (suggestions.any((s) => s.label == labelStr)) continue;

        suggestions.add(_CitySuggestion(
          label: labelStr,
          city: city,
          postcode: postcode,
          context: ctx,
          latitude: lat,
          longitude: lng,
        ));
      }

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _searching = false;
        });
      }
    } catch (e) {
      debugPrint('City search error: $e');
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectSuggestion(_CitySuggestion suggestion) {
    setState(() {
      _controller.text = suggestion.label;
      _suggestions = [];
      _hasSelected = true;
    });
    widget.onCitySelected(
        suggestion.label, suggestion.latitude, suggestion.longitude);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Tapez pour rechercher...',
            prefixIcon:
                const Icon(Icons.location_on_outlined, color: Colors.grey),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _hasSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
          ),
          onChanged: _onTextChanged,
          validator: (value) {
            if (value == null || value.isEmpty || !_hasSelected) {
              return 'Sélectionnez une ville';
            }
            return null;
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _suggestions.map((s) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 20),
                  title: Text(s.label),
                  subtitle: s.context != null ? Text(s.context!) : null,
                  onTap: () => _selectSuggestion(s),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CitySuggestion {
  final String label;
  final String city;
  final String? postcode;
  final String? context;
  final double? latitude;
  final double? longitude;

  const _CitySuggestion({
    required this.label,
    required this.city,
    this.postcode,
    this.context,
    this.latitude,
    this.longitude,
  });
}
