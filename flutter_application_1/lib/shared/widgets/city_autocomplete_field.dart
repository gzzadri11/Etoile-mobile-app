library;

/// Champ d'autocompletion de ville filtre sur l'Ile-de-France.
///
/// Utilise l'API Photon (OpenStreetMap) avec bbox IdF.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Autocompletion ville IdF via Photon API (debounce 400ms).
/// Returns the selected city name via [onCitySelected].
class CityAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onCitySelected;
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

  // Île-de-France bounding box (SW lon, SW lat, NE lon, NE lat)
  static const _idfBbox = '1.44,48.12,3.56,49.24';

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

    if (query.trim().length < 3) {
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
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query,
          'limit': '5',
          'lang': 'fr',
          'bbox': _idfBbox,
        },
      );

      final features = response.data['features'] as List? ?? [];
      final suggestions = <_CitySuggestion>[];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>;
        final city = props['city'] as String? ?? props['name'] as String?;
        if (city == null || city.isEmpty) continue;

        final postcode = props['postcode'] as String?;
        final state = props['state'] as String?;

        // Build display label: "Paris (75001)" or "Creteil (94000)"
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
          state: state,
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

  void _selectSuggestion(_CitySuggestion suggestion) {
    setState(() {
      _controller.text = suggestion.label;
      _suggestions = [];
      _hasSelected = true;
    });
    widget.onCitySelected(suggestion.city);
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
              return 'Selectionnez une ville';
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
  final String? state;

  const _CitySuggestion({
    required this.label,
    required this.city,
    this.postcode,
    this.state,
  });
}
